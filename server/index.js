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
    
    // Si no se envía fecha de inicio, por defecto buscamos los últimos 30 días
    let dateFilter = begin_date;
    if (!dateFilter) {
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
      dateFilter = thirtyDaysAgo.toISOString();
    }

    console.log(`Buscando transacciones en Mercado Pago desde: ${dateFilter} (Límite: ${limit})`);

    // Llamamos a la API de búsqueda de pagos de Mercado Pago
    // Documentación: https://www.mercadopago.com.ar/developers/es/reference/payments/_payments_search/get
    const response = await axios.get('https://api.mercadopago.com/v1/payments/search', {
      headers: {
        Authorization: `Bearer ${MP_ACCESS_TOKEN}`
      },
      params: {
        begin_date: dateFilter,
        sort: 'date_created',
        criteria: 'desc',
        limit: limit
      }
    });

    const results = response.data.results || [];
    
    // Mapeamos y filtramos los pagos aprobados
    const mappedTransactions = results
      .filter(payment => payment.status === 'approved')
      .map(payment => {
        // Determinamos si es un ingreso o egreso
        // Si el pagador (payer) tiene el ID de nuestra propia cuenta, es un gasto (egreso)
        const isPayerOwner = ownerId && payment.payer && payment.payer.id === ownerId;
        const tipo = isPayerOwner ? 'egreso' : 'ingreso';

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
