import { Router } from 'express';
import { DestinationController } from '../controllers/destination.controller';

const router = Router();

router.get('/', DestinationController.getAllDestinations);
router.get('/:id', DestinationController.getDestinationById);

export default router;
