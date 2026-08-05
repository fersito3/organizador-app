const express = require('express');
const cors = require('cors');
const axios = require('axios');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;
const MP_ACCESS_TOKEN = process.env.MP_ACCESS_TOKEN;

app.use(cors());
app.use(express.json());

// Guardamos en memoria el ID de la cuenta dueña de la credencial
let ownerId = null;

// Helper para obtener el ID de la propia cuenta usando el token de acceso
async function fetchOwnerId() {
  if (!MP_ACCESS_TOKEN) {
    console.warn('⚠️ ADVERTENCIA: MP_ACCESS_TOKEN no está definido en las variables de entorno.');
    return null;
  }
  
  try {
    const response = await axios.get('https://api.mercadopago.com/users/me', {
      headers: {
        Authorization: `Bearer ${MP_ACCESS_TOKEN}`
      }
    });
    ownerId = response.data.id;
    console.log(`✅ Conectado a Mercado Pago. ID de Cuenta del Propietario: ${ownerId}`);
    return ownerId;
  } catch (error) {
    console.error('❌ Error al obtener el ID del propietario de Mercado Pago:', error.message);
    if (error.response) {
      console.error('Detalles del error:', error.response.data);
    }
    return null;
  }
}

// Intentamos obtener el ID al iniciar
fetchOwnerId();

// 1. Healthcheck / Ping
app.get('/', (req, res) => {
  res.json({
    status: 'ok',
    message: 'Organizador App API proxy de Mercado Pago activa',
    connected_to_mp: ownerId !== null
  });
});

// 2. Sincronización de transacciones
app.get('/api/mercadopago/transactions', async (req, res) => {
  if (!MP_ACCESS_TOKEN) {
    return res.status(500).json({
      error: 'Token de Mercado Pago no configurado en el servidor.'
    });
  }

  // Si no pudimos obtener el ownerId al arrancar, lo intentamos recuperar ahora
  if (!ownerId) {
    await fetchOwnerId();
  }

  try {
    const { begin_date, limit = 50 } = req.query;
    
    // Fecha límite de corte: 4 de agosto de 2026 a las 23:35 hs (UTC-3) -> 2026-08-05T02:35:00.000Z
    const CUTOFF_DATE = new Date('2026-08-05T02:35:00.000Z');
    
    let requestedDate = begin_date ? new Date(begin_date) : null;
    
    // Si no se pide fecha o la fecha pedida es anterior al corte, forzamos el límite
    if (!requestedDate || requestedDate < CUTOFF_DATE) {
      requestedDate = CUTOFF_DATE;
    }
    
    const dateString = requestedDate.toISOString();

    console.log(`Buscando transacciones en Mercado Pago desde: ${dateString} (Límite: ${limit})`);

    // Hacemos dos peticiones en paralelo para traer tanto ingresos (donde somos recolectores) como egresos (donde somos pagadores)
    const [ingresosResponse, egresosResponse] = await Promise.all([
      axios.get('https://api.mercadopago.com/v1/payments/search', {
        headers: {
          Authorization: `Bearer ${MP_ACCESS_TOKEN}`
        },
        params: {
          begin_date: dateString,
          sort: 'date_created',
          criteria: 'desc',
          limit: limit
        }
      }).catch(err => {
        console.error('❌ Error al buscar ingresos de MP:', err.message);
        return { data: { results: [] } };
      }),
      ownerId ? axios.get('https://api.mercadopago.com/v1/payments/search', {
        headers: {
          Authorization: `Bearer ${MP_ACCESS_TOKEN}`
        },
        params: {
          'payer.id': ownerId,
          begin_date: dateString,
          sort: 'date_created',
          criteria: 'desc',
          limit: limit
        }
      }).catch(err => {
        console.error('❌ Error al buscar egresos de MP:', err.message);
        return { data: { results: [] } };
      }) : Promise.resolve({ data: { results: [] } })
    ]);

    const ingresosResults = ingresosResponse.data.results || [];
    const egresosResults = egresosResponse.data.results || [];

    // Combinamos las listas eliminando duplicados por ID de pago
    const allResultsMap = new Map();
    ingresosResults.forEach(item => allResultsMap.set(item.id, item));
    egresosResults.forEach(item => allResultsMap.set(item.id, item));

    const results = Array.from(allResultsMap.values());

    console.log(`[DEBUG] Resultados crudos combinados obtenidos de MP (Ingresos: ${ingresosResults.length}, Egresos: ${egresosResults.length}): ${results.length} transacciones.`);
    if (results.length > 0) {
      console.log(`[DEBUG] Primera transacción cruda combinada: ID=${results[0].id}, Estado=${results[0].status}, PayerID=${results[0].payer?.id}, CollectorID=${results[0].collector_id}, Monto=${results[0].transaction_amount}`);
    }
    
    // Mapeamos y filtramos los pagos aprobados
    const mappedTransactions = results
      .filter(payment => payment.status === 'approved')
      .map(payment => {
        // Determinamos si es un ingreso o egreso de forma ultra robusta
        const isCollectorMe = ownerId && payment.collector_id && String(payment.collector_id) === String(ownerId);
        const isPayerMe = ownerId && payment.payer && payment.payer.id && String(payment.payer.id) === String(ownerId);
        
        let tipo = 'egreso'; // Por defecto
        if (isCollectorMe && !isPayerMe) {
          tipo = 'ingreso';
        } else if (isPayerMe && !isCollectorMe) {
          tipo = 'egreso';
        } else {
          tipo = isCollectorMe ? 'ingreso' : 'egreso';
        }

        console.log(`[DEBUG] Clasificando pago ${payment.id}: tipo=${tipo}, amount=${payment.transaction_amount}, collector=${payment.collector_id}, payer=${payment.payer?.id}, isCollectorMe=${isCollectorMe}, isPayerMe=${isPayerMe}`);

        // Determinamos la persona o entidad involucrada (destinatario o emisor)
        let destinatarioEmisor = 'Mercado Pago';
        
        if (tipo === 'ingreso') {
          // Si es un ingreso, nos pagó/transfirió otra persona (payer)
          const p = payment.payer || {};
          const fullName = `${p.first_name || ''} ${p.last_name || ''}`.trim();
          destinatarioEmisor = fullName || p.email || 'Remitente MP';
        } else {
          // Si es un egreso, gastamos plata. El destinatario suele estar en la descripción de la compra
          // o podemos verificar los metadatos de la contraparte
          destinatarioEmisor = payment.description || 'Mercado Pago';
        }

        return {
          mpPaymentId: payment.id.toString(),
          descripcion: payment.description || (tipo === 'egreso' ? 'Gasto Mercado Pago' : 'Ingreso Mercado Pago'),
          monto: parseFloat(payment.transaction_amount),
          fecha: payment.date_approved || payment.date_created,
          tipo: tipo, // 'ingreso' o 'egreso'
          destinatarioEmisor: destinatarioEmisor,
          proveedor: 'MP'
        };
      });

    // Ordenar las transacciones combinadas por fecha descendente (más recientes primero)
    mappedTransactions.sort((a, b) => new Date(b.fecha) - new Date(a.fecha));

    console.log(`[DEBUG] Transacciones aprobadas mapeadas y enviadas al cliente: ${mappedTransactions.length}`);

    res.json({
      count: mappedTransactions.length,
      transactions: mappedTransactions
    });

  } catch (error) {
    console.error('❌ Error al buscar transacciones de Mercado Pago:', error.message);
    if (error.response) {
      console.error('Detalles del error:', error.response.data);
      return res.status(error.response.status).json({
        error: 'Error de la API de Mercado Pago',
        details: error.response.data
      });
    }
    res.status(500).json({
      error: 'Error interno del servidor',
      message: error.message
    });
  }
});

// Levantar el servidor
app.listen(PORT, () => {
  console.log(`🚀 Servidor backend corriendo en http://localhost:${PORT}`);
});
