const express = require('express');
const router = express.Router();
const db = require('../config/database');

// Health check endpoint
router.get('/', async (req, res) => {
    try {
        const healthCheck = {
            status: 'OK',
            timestamp: new Date().toISOString(),
            uptime: process.uptime(),
            environment: process.env.NODE_ENV || 'development',
            version: process.env.npm_package_version || '1.0.0',
            services: {}
        };

        // Check database connection
        try {
            await db.execute('SELECT 1');
            healthCheck.services.database = {
                status: 'OK',
                message: 'Database connection successful'
            };
        } catch (error) {
            healthCheck.services.database = {
                status: 'ERROR',
                message: 'Database connection failed',
                error: error.message
            };
            healthCheck.status = 'ERROR';
        }

        // Check memory usage
        const memUsage = process.memoryUsage();
        healthCheck.services.memory = {
            status: 'OK',
            rss: Math.round(memUsage.rss / 1024 / 1024) + ' MB',
            heapTotal: Math.round(memUsage.heapTotal / 1024 / 1024) + ' MB',
            heapUsed: Math.round(memUsage.heapUsed / 1024 / 1024) + ' MB',
            external: Math.round(memUsage.external / 1024 / 1024) + ' MB'
        };

        // Check CPU usage
        const cpuUsage = process.cpuUsage();
        healthCheck.services.cpu = {
            status: 'OK',
            user: cpuUsage.user,
            system: cpuUsage.system
        };

        const statusCode = healthCheck.status === 'OK' ? 200 : 503;
        res.status(statusCode).json(healthCheck);

    } catch (error) {
        res.status(503).json({
            status: 'ERROR',
            timestamp: new Date().toISOString(),
            message: 'Health check failed',
            error: error.message
        });
    }
});

// Detailed health check
router.get('/detailed', async (req, res) => {
    try {
        const detailedHealth = {
            status: 'OK',
            timestamp: new Date().toISOString(),
            uptime: process.uptime(),
            environment: process.env.NODE_ENV || 'development',
            version: process.env.npm_package_version || '1.0.0',
            nodeVersion: process.version,
            platform: process.platform,
            arch: process.arch,
            pid: process.pid,
            services: {}
        };

        // Database detailed check
        try {
            const startTime = Date.now();
            await db.execute('SELECT 1');
            const responseTime = Date.now() - startTime;
            
            detailedHealth.services.database = {
                status: 'OK',
                responseTime: responseTime + 'ms',
                message: 'Database connection successful'
            };
        } catch (error) {
            detailedHealth.services.database = {
                status: 'ERROR',
                message: 'Database connection failed',
                error: error.message
            };
            detailedHealth.status = 'ERROR';
        }

        // Memory detailed check
        const memUsage = process.memoryUsage();
        detailedHealth.services.memory = {
            status: 'OK',
            rss: Math.round(memUsage.rss / 1024 / 1024) + ' MB',
            heapTotal: Math.round(memUsage.heapTotal / 1024 / 1024) + ' MB',
            heapUsed: Math.round(memUsage.heapUsed / 1024 / 1024) + ' MB',
            external: Math.round(memUsage.external / 1024 / 1024) + ' MB',
            arrayBuffers: Math.round(memUsage.arrayBuffers / 1024 / 1024) + ' MB'
        };

        // CPU detailed check
        const cpuUsage = process.cpuUsage();
        detailedHealth.services.cpu = {
            status: 'OK',
            user: cpuUsage.user,
            system: cpuUsage.system
        };

        // Environment variables check (without sensitive data)
        detailedHealth.services.environment = {
            status: 'OK',
            nodeEnv: process.env.NODE_ENV,
            port: process.env.PORT,
            dbHost: process.env.DB_HOST,
            dbName: process.env.DB_NAME,
            corsOrigin: process.env.CORS_ORIGIN
        };

        const statusCode = detailedHealth.status === 'OK' ? 200 : 503;
        res.status(statusCode).json(detailedHealth);

    } catch (error) {
        res.status(503).json({
            status: 'ERROR',
            timestamp: new Date().toISOString(),
            message: 'Detailed health check failed',
            error: error.message
        });
    }
});

// Readiness check (for load balancers)
router.get('/ready', async (req, res) => {
    try {
        // Check if application is ready to serve requests
        await db.execute('SELECT 1');
        
        res.status(200).json({
            status: 'READY',
            timestamp: new Date().toISOString(),
            message: 'Application is ready to serve requests'
        });
    } catch (error) {
        res.status(503).json({
            status: 'NOT_READY',
            timestamp: new Date().toISOString(),
            message: 'Application is not ready',
            error: error.message
        });
    }
});

// Liveness check (for container orchestration)
router.get('/live', (req, res) => {
    res.status(200).json({
        status: 'ALIVE',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        message: 'Application is alive'
    });
});

module.exports = router;
