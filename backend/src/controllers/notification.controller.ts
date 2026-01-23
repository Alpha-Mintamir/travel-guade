import { Request, Response, NextFunction } from 'express';
import { NotificationService } from '../services/notification.service';
import { ApiResponse } from '../utils/response';

export class NotificationController {
  static async getUserNotifications(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.userId;
      const notifications = await NotificationService.getUserNotifications(userId);
      ApiResponse.success(res, notifications);
    } catch (error) {
      next(error);
    }
  }

  static async markAsRead(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id as string;
      const userId = req.user!.userId;
      const notification = await NotificationService.markAsRead(id, userId);
      ApiResponse.success(res, notification);
    } catch (error) {
      next(error);
    }
  }

  static async markAllAsRead(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.userId;
      const result = await NotificationService.markAllAsRead(userId);
      ApiResponse.success(res, result);
    } catch (error) {
      next(error);
    }
  }
}
