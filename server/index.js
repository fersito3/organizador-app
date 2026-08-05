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
let ownerId = 446191311;

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
    
    const dateString = requestedDate.toISOString().replace(/\.\d+Z$/, 'Z');

    console.log(`Buscando transacciones en Mercado Pago desde: ${dateString} (Límite: ${limit})`);

    // Hacemos dos peticiones en paralelo para traer tanto ingresos (donde somos recolectores) como egresos (donde somos pagadores)
    const [ingresosResponse, egresosResponse] = await Promise.all([
      axios.get('https://api.mercadopago.com/v1/payments/search', {
        headers: {
          Authorization: `Bearer ${MP_ACCESS_TOKEN}`
        },
        params: {
          range: 'date_created',
          begin_date: dateString,
          end_date: 'NOW',
          sort: 'date_created',
          criteria: 'desc',
          limit: limit
        }
      }).catch(err => {
        console.error('❌ Error al buscar ingresos de MP:', err.response ? err.response.data : err.message);
        return { data: { results: [] } };
      }),
      ownerId ? axios.get('https://api.mercadopago.com/v1/payments/search', {
        headers: {
          Authorization: `Bearer ${MP_ACCESS_TOKEN}`
        },
        params: {
          'payer.id': ownerId,
          range: 'date_created',
          begin_date: dateString,
          end_date: 'NOW',
          sort: 'date_created',
          criteria: 'desc',
          limit: limit
        }
      }).catch(err => {
        console.error('❌ Error al buscar egresos de MP:', err.response ? err.response.data : err.message);
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

    // Mapeamos y filtramos los pagos aprobados
    const mappedTransactions = results
      .filter(payment => payment.status === 'approved')
      .map(payment => {
        // Extraemos los IDs reales de Mercado Pago
        // 1. Payer ID (en las búsquedas de MP es payment.payer_id o payment.payer.id)
        const payerId = payment.payer_id || (payment.payer ? payment.payer.id : null);
        
        // 2. Collector ID (en las búsquedas de MP es payment.collector.id o payment.collector_id)
        const collectorId = payment.collector ? payment.collector.id : payment.collector_id;

        const myIdStr = ownerId ? String(ownerId) : '446191311';
        const payerIdStr = payerId ? String(payerId) : null;
        const collectorIdStr = collectorId ? String(collectorId) : null;

        // Determinamos el tipo (ingreso o egreso) y el ID de la contraparte
        let tipo = 'egreso';
        let contraparteMpId = null;

        if (payerIdStr === myIdStr) {
          // Tu cuenta pagó -> Es un EGRESO -> La contraparte es el colector (quien recibió la plata)
          tipo = 'egreso';
          contraparteMpId = (collectorIdStr && collectorIdStr !== myIdStr) ? collectorIdStr : null;
        } else if (collectorIdStr === myIdStr) {
          // Tu cuenta recibió -> Es un INGRESO -> La contraparte es el pagador (quien te envió la plata)
          tipo = 'ingreso';
          contraparteMpId = (payerIdStr && payerIdStr !== myIdStr) ? payerIdStr : null;
        } else {
          // Fallback
          tipo = 'egreso';
          if (collectorIdStr && collectorIdStr !== myIdStr) {
            contraparteMpId = collectorIdStr;
          } else if (payerIdStr && payerIdStr !== myIdStr) {
            contraparteMpId = payerIdStr;
          }
        }

        // Determinamos el nombre de destinatario / emisor para visualización
        let destinatarioEmisor = 'Mercado Pago';
        if (tipo === 'ingreso') {
          const p = payment.payer || {};
          const fullName = `${p.first_name || ''} ${p.last_name || ''}`.trim();
          destinatarioEmisor = fullName || p.email || 'Remitente MP';
        } else {
          const poi = payment.point_of_interaction || {};
          const td = poi.transaction_data || {};
          const bt = td.bank_transfer || {};
          const counterpart = td.counterpart || {};
          
          let recipientName = '';
          if (td.receiver && typeof td.receiver === 'object') {
            recipientName = td.receiver.name || td.receiver.description || '';
          }
          if (!recipientName && bt.receiver && typeof bt.receiver === 'object') {
            recipientName = bt.receiver.name || bt.receiver.description || '';
          }
          if (!recipientName && counterpart.name) {
            recipientName = counterpart.name;
          }
          destinatarioEmisor = recipientName || payment.description || 'Destinatario MP';
        }
        
        let descripcion = payment.description || (tipo === 'egreso' ? 'Gasto Mercado Pago' : 'Ingreso Mercado Pago');
        if (descripcion.toLowerCase().trim() === 'varios') {
          descripcion = 'Transferencia';
        }

        return {
          mpPaymentId: payment.id.toString(),
          descripcion: descripcion,
          monto: parseFloat(payment.transaction_amount),
          fecha: payment.date_approved || payment.date_created,
          tipo: tipo, // 'ingreso' o 'egreso'
          destinatarioEmisor: destinatarioEmisor,
          contraparteMpId: contraparteMpId,
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

// 3. Crear una Preferencia de Pago / Cobro en Mercado Pago
app.post('/api/mercadopago/preference', async (req, res) => {
  if (!MP_ACCESS_TOKEN) {
    return res.status(500).json({ error: 'Token de Mercado Pago no configurado en el servidor.' });
  }

  try {
    const { title, amount } = req.body;
    const itemAmount = Number(amount) || 100;
    const itemTitle = title || 'Cobro de Deuda';

    console.log(`Generando link de cobro MP para: "${itemTitle}" - $${itemAmount}`);

    const preferenceBody = {
      items: [
        {
          title: itemTitle,
          unit_price: itemAmount,
          quantity: 1,
          currency_id: 'ARS',
        }
      ],
      back_urls: {
        success: 'https://organizador-app.onrender.com/',
        failure: 'https://organizador-app.onrender.com/',
        pending: 'https://organizador-app.onrender.com/'
      },
      auto_return: 'approved'
    };

    const response = await axios.post('https://api.mercadopago.com/checkout/preferences', preferenceBody, {
      headers: {
        Authorization: `Bearer ${MP_ACCESS_TOKEN}`,
        'Content-Type': 'application/json'
      }
    });

    console.log(`✅ Link de cobro generado con éxito. ID: ${response.data.id}`);

    res.json({
      id: response.data.id,
      init_point: response.data.init_point, // Link oficial web de cobro MP
      sandbox_init_point: response.data.sandbox_init_point
    });

  } catch (error) {
    console.error('❌ Error al crear preferencia de cobro en Mercado Pago:', error.response ? error.response.data : error.message);
    res.status(500).json({
      error: 'Error al generar preferencia de cobro en Mercado Pago',
      details: error.response ? error.response.data : error.message
    });
  }
});

// Levantar el servidor
app.listen(PORT, () => {
  console.log(`🚀 Servidor backend corriendo en http://localhost:${PORT}`);
});
