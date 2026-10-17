const PORT = process.env.PORT || '3000';
const PUBLIC_URL = (process.env.PUBLIC_URL || '').replace(/\/$/, '');

const SERVERS = [
   ...(PUBLIC_URL ? [{ url: PUBLIC_URL, description: 'Public' }] : []),
   { url: '/', description: 'This host (relative)' },
   { url: 'http://localhost:' + PORT, description: 'Local' },
];

const Transaction = {
   type: 'object',
   properties: {
      trxId: { type: 'string', example: 'TRX-K3F9Q2A7X1B4' },
      status: { type: 'string', enum: ['PENDING', 'PAID', 'EXPIRED'], example: 'PENDING' },
      amount: { type: 'integer', example: 50000 },
      fee: { type: 'integer', example: 2500 },
      amountToPay: { type: 'integer', example: 52500 },
      qrString: { type: 'string', example: '00020101021226...5802ID...6304ABCD' },
      qrImageUrl: { type: 'string', example: 'https://pay.ronpay.id/api/payment/TRX-xxx/qr.png' },
      callbackUrl: { type: 'string', nullable: true },
      metadata: { nullable: true, example: { orderId: 1042 } },
      createdAt: { type: 'string', format: 'date-time' },
      expiresAt: { type: 'string', format: 'date-time' },
      paidAt: { type: 'string', format: 'date-time', nullable: true },
      webhook: {
         type: 'object', nullable: true,
         properties: {
            state: { type: 'string', enum: ['PENDING', 'SENT'] },
            attempts: { type: 'integer' },
            nextAttemptAt: { type: 'string', format: 'date-time', nullable: true },
            lastError: { type: 'string', nullable: true },
         },
      },
   },
};

const Error = {
   type: 'object',
   properties: {
      success: { type: 'boolean', example: false },
      error: { type: 'string' },
   },
};

function ok(schema) {
   return {
      type: 'object',
      properties: { success: { type: 'boolean', example: true }, data: schema },
   };
}

export const openApiSpec = {
   openapi: '3.0.3',
   info: {
      title: 'Ronpay Payment Gateway',
      version: '1.0.0',
      description: 'Self-hosted QRIS payment gateway.',
      license: { name: 'MIT' },
   },
   servers: SERVERS,
   components: {
      securitySchemes: {
         ApiKeyAuth: { type: 'apiKey', in: 'header', name: 'X-API-Key' },
      },
      schemas: { Transaction, Error },
   },
   paths: {
      '/api/payment/create': {
         post: {
            summary: 'Create a payment',
            security: [{ ApiKeyAuth: [] }],
            parameters: [{
               name: 'Idempotency-Key', in: 'header', required: false,
               schema: { type: 'string' },
            }],
            requestBody: {
               required: true,
               content: {
                  'application/json': {
                     schema: {
                        type: 'object', required: ['amount'],
                        properties: {
                           amount: { type: 'integer', minimum: 1, maximum: 1000000000, example: 50000 },
                           fee: { type: 'integer', minimum: 0, example: 2500 },
                           trxId: { type: 'string', pattern: '^[\\w.-]{1,64}$', example: 'ORDER-1042' },
                           callbackUrl: { type: 'string', example: 'https://shop.example.com/hook' },
                           callbackSecret: { type: 'string', minLength: 8, maxLength: 256 },
                           expireMinutes: { type: 'integer', example: 10 },
                           metadata: { example: { orderId: 1042 } },
                           idempotencyKey: { type: 'string' },
                        },
                     },
                  },
               },
            },
            responses: {
               201: { description: 'Created', content: { 'application/json': { schema: ok({ $ref: '#/components/schemas/Transaction' }) } } },
               200: { description: 'Idempotent hit' },
               400: { description: 'Bad input' },
               401: { description: 'Unauthorized' },
               409: { description: 'trxId exists' },
            },
         },
      },
      '/api/payment/{trxId}': {
         get: {
            summary: 'Check payment by trxId',
            security: [{}, { ApiKeyAuth: [] }],
            parameters: [{ name: 'trxId', in: 'path', required: true, schema: { type: 'string' } }],
            responses: {
               200: { description: 'OK', content: { 'application/json': { schema: ok({ $ref: '#/components/schemas/Transaction' }) } } },
               404: { description: 'Not found' },
            },
         },
      },
      '/api/payment/{trxId}/qr.png': {
         get: {
            summary: 'QRIS image (PNG)',
            parameters: [{ name: 'trxId', in: 'path', required: true, schema: { type: 'string' } }],
            responses: {
               200: { description: 'PNG', content: { 'image/png': {} } },
               404: { description: 'Not found' },
            },
         },
      },
      '/api/payment/{trxId}/cancel': {
         post: {
            summary: 'Cancel pending payment',
            security: [{ ApiKeyAuth: [] }],
            parameters: [{ name: 'trxId', in: 'path', required: true, schema: { type: 'string' } }],
            responses: { 200: { description: 'Cancelled' }, 404: { description: 'Not found' }, 409: { description: 'Not pending' } },
         },
      },
      '/api/payments': {
         get: {
            summary: 'List payments',
            security: [{ ApiKeyAuth: [] }],
            parameters: [
               { name: 'status', in: 'query', schema: { type: 'string', enum: ['PENDING', 'PAID', 'EXPIRED'] } },
               { name: 'limit', in: 'query', schema: { type: 'integer', default: 50, maximum: 200 } },
               { name: 'offset', in: 'query', schema: { type: 'integer', default: 0 } },
            ],
            responses: { 200: { description: 'OK' } },
         },
      },
      '/api/history': {
         get: {
            summary: 'GoBiz history',
            security: [{ ApiKeyAuth: [] }],
            parameters: [
               { name: 'matched', in: 'query', schema: { type: 'boolean' } },
               { name: 'limit', in: 'query', schema: { type: 'integer', default: 50 } },
               { name: 'offset', in: 'query', schema: { type: 'integer', default: 0 } },
            ],
            responses: { 200: { description: 'OK' } },
         },
      },
      '/api/admin/poll': {
         get: {
            summary: 'Run poll cycle (cron)',
            security: [{ ApiKeyAuth: [] }],
            responses: { 200: { description: 'Done' }, 401: { description: 'Unauthorized' } },
         },
         post: {
            summary: 'Run poll cycle (cron)',
            security: [{ ApiKeyAuth: [] }],
            responses: { 200: { description: 'Done' }, 401: { description: 'Unauthorized' } },
         },
      },
      '/api/admin/stats': {
         get: {
            summary: 'Dashboard aggregates',
            security: [{ ApiKeyAuth: [] }],
            parameters: [{ name: 'days', in: 'query', schema: { type: 'integer', default: 14 } }],
            responses: { 200: { description: 'OK' }, 401: { description: 'Unauthorized' } },
         },
      },
      '/api/health': {
         get: {
            summary: 'Health check',
            security: [{}, { ApiKeyAuth: [] }],
            responses: {
               200: { description: 'Healthy' },
               503: { description: 'Degraded' },
            },
         },
      },
   },
};
