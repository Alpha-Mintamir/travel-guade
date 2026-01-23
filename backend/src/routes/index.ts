import { Router } from 'express';
import authRoutes from './auth.routes';
import userRoutes from './user.routes';
import destinationRoutes from './destination.routes';
import tripRoutes from './trip.routes';
import requestRoutes from './request.routes';
import notificationRoutes from './notification.routes';

const router = Router();

// Mount routes
router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/destinations', destinationRoutes);
router.use('/trips', tripRoutes);
router.use('/requests', requestRoutes);
router.use('/notifications', notificationRoutes);

// Health check
router.get('/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

export default router;
