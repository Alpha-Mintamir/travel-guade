import { Router } from 'express';
import { UserController } from '../controllers/user.controller';
import { authenticate } from '../middleware/auth.middleware';
import { validate } from '../middleware/validate.middleware';
import { upload } from '../middleware/upload.middleware';
import { updateProfileSchema } from '../schemas/user.schema';

const router = Router();

// All user routes require authentication
router.use(authenticate);

router.get('/me', UserController.getCurrentUser);
router.patch('/me', validate(updateProfileSchema), UserController.updateProfile);
router.post('/me/photo', upload.single('photo'), UserController.uploadProfilePhoto);
router.get('/:id', UserController.getUserById);

export default router;
