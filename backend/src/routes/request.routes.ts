import { Router } from 'express';
import { RequestController } from '../controllers/request.controller';
import { authenticate } from '../middleware/auth.middleware';
import { validate } from '../middleware/validate.middleware';
import { createRequestSchema, respondToRequestSchema } from '../schemas/request.schema';

const router = Router();

// All request routes require authentication
router.use(authenticate);

router.post('/trips/:tripId/requests', validate(createRequestSchema), RequestController.createRequest);
router.get('/trips/:tripId/requests', RequestController.getRequestsForTrip);
router.patch('/:id/respond', validate(respondToRequestSchema), RequestController.respondToRequest);
router.get('/sent', RequestController.getSentRequests);
router.get('/received', RequestController.getReceivedRequests);

export default router;
