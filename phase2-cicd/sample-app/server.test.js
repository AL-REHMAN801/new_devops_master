const request = require('supertest');
const app = require('./server');

describe('API Endpoints', () => {
    describe('GET /', () => {
        it('should return welcome message', async () => {
            const res = await request(app).get('/');
            expect(res.statusCode).toBe(200);
            expect(res.body).toHaveProperty('message');
            expect(res.body.message).toContain('Welcome');
        });
    });

    describe('GET /health', () => {
        it('should return health status', async () => {
            const res = await request(app).get('/health');
            expect(res.statusCode).toBe(200);
            expect(res.body).toHaveProperty('status');
            expect(res.body.status).toBe('healthy');
        });
    });

    describe('GET /api/info', () => {
        it('should return application info', async () => {
            const res = await request(app).get('/api/info');
            expect(res.statusCode).toBe(200);
            expect(res.body).toHaveProperty('app');
            expect(res.body).toHaveProperty('version');
        });
    });

    describe('POST /api/echo', () => {
        it('should echo the request body', async () => {
            const testData = { test: 'data' };
            const res = await request(app)
                .post('/api/echo')
                .send(testData);
            expect(res.statusCode).toBe(200);
            expect(res.body).toHaveProperty('received');
            expect(res.body.received).toEqual(testData);
        });
    });

    describe('GET /nonexistent', () => {
        it('should return 404 for unknown routes', async () => {
            const res = await request(app).get('/nonexistent');
            expect(res.statusCode).toBe(404);
            expect(res.body).toHaveProperty('error');
        });
    });
});
