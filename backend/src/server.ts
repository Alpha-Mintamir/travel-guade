import http from 'http';
import app from './app';
import { env } from './config/env';
import { logger } from './utils/logger';
import { connectDatabase, disconnectDatabase } from './config/database';
import { initializeSocketIO } from './socket';

const PORT = parseInt(env.PORT);

// Export app for Vercel serverless
export default app;

// Create HTTP server (for local development)
const httpServer = http.createServer(app);

// Initialize Socket.io (for local development)
let io: ReturnType<typeof initializeSocketIO> | null = null;

// Only start server in non-serverless environment
if (process.env.VERCEL !== '1') {
  io = initializeSocketIO(httpServer);

  // Graceful shutdown handler
  const gracefulShutdown = async (signal: string) => {
    logger.info(`${signal} received, starting graceful shutdown`);

    // Close HTTP server
    httpServer.close(async () => {
      logger.info('HTTP server closed');

      // Close Socket.io
      if (io) {
        io.close(() => {
          logger.info('Socket.io closed');
        });
      }

      // Disconnect database
      await disconnectDatabase();

      logger.info('Graceful shutdown completed');
      process.exit(0);
    });

    // Force shutdown after 10 seconds
    setTimeout(() => {
      logger.error('Forced shutdown after timeout');
      process.exit(1);
    }, 10000);
  };

  // Start server
  async function startServer() {
    try {
      // Connect to database
      await connectDatabase();

      // Start HTTP server
      httpServer.listen(PORT, '0.0.0.0', () => {
        logger.info(`🚀 Server running on http://0.0.0.0:${PORT}`);
        logger.info(`📝 Environment: ${env.NODE_ENV}`);
        logger.info(`🔌 Socket.io ready for connections`);
      });

      // Register shutdown handlers
      process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
      process.on('SIGINT', () => gracefulShutdown('SIGINT'));
    } catch (error) {
      logger.error({ error }, 'Failed to start server');
      process.exit(1);
    }
  }

  // Handle uncaught errors
  process.on('uncaughtException', (error) => {
    logger.error({ error }, 'Uncaught exception');
    process.exit(1);
  });

  process.on('unhandledRejection', (reason, promise) => {
    logger.error({ reason, promise }, 'Unhandled rejection');
    process.exit(1);
  });

  startServer();
}

export { io };
