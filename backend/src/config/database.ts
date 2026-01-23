import { PrismaClient } from '@prisma/client';
import { logger } from '../utils/logger';

const prisma = new PrismaClient({
  log: [
    { level: 'query', emit: 'event' },
    { level: 'error', emit: 'event' },
    { level: 'warn', emit: 'event' },
  ],
});

// Log queries in development
if (process.env.NODE_ENV === 'development') {
  prisma.$on('query', (e: any) => {
    logger.debug({ query: e.query, duration: `${e.duration}ms` }, 'Prisma Query');
  });
}

prisma.$on('error', (e: any) => {
  logger.error({ error: e }, 'Prisma Error');
});

prisma.$on('warn', (e: any) => {
  logger.warn({ warning: e }, 'Prisma Warning');
});

export { prisma };

export async function connectDatabase() {
  try {
    await prisma.$connect();
    logger.info('✅ Database connected successfully');
  } catch (error) {
    logger.error({ error }, '❌ Database connection failed');
    process.exit(1);
  }
}

export async function disconnectDatabase() {
  await prisma.$disconnect();
  logger.info('Database disconnected');
}
