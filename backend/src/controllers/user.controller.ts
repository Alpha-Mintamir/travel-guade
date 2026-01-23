import { Request, Response, NextFunction } from 'express';
import { UserService } from '../services/user.service';
import { ApiResponse } from '../utils/response';
import { BadRequestError } from '../utils/errors';

export class UserController {
  static async getCurrentUser(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.userId;
      const user = await UserService.getCurrentUser(userId);
      ApiResponse.success(res, user);
    } catch (error) {
      next(error);
    }
  }

  static async updateProfile(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.userId;
      const user = await UserService.updateProfile(userId, req.body);
      ApiResponse.success(res, user, 'Profile updated successfully');
    } catch (error) {
      next(error);
    }
  }

  static async uploadProfilePhoto(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.userId;
      
      if (!req.file) {
        throw new BadRequestError('No file uploaded');
      }

      const result = await UserService.uploadProfilePhoto(userId, req.file);
      ApiResponse.success(res, result, 'Profile photo uploaded successfully');
    } catch (error) {
      next(error);
    }
  }

  static async getUserById(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id as string;
      const user = await UserService.getUserById(id);
      ApiResponse.success(res, user);
    } catch (error) {
      next(error);
    }
  }
}
