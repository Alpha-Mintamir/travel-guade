import { Router } from 'express';
import { TripController } from '../controllers/trip.controller';
import { authenticate } from '../middleware/auth.middleware';
import { validate } from '../middleware/validate.middleware';
import { upload } from '../middleware/upload.middleware';
import { createTripSchema, updateTripSchema, getTripsSchema } from '../schemas/trip.schema';

const router = Router();

// Public routes
router.get('/', validate(getTripsSchema), TripController.getTrips);

// Protected routes
router.use(authenticate);
router.get('/my-trips', TripController.getMyTrips); // Must come before /:id
router.post('/', validate(createTripSchema), TripController.createTrip);
router.post('/upload-photo', upload.single('photo'), TripController.uploadTripPhoto);
router.patch('/:id', validate(updateTripSchema), TripController.updateTrip);
router.delete('/:id', TripController.deleteTrip);

// Public trip detail (after protected routes to avoid conflict)
router.get('/:id', TripController.getTripById);

export default router;
