import { prisma } from '../config/database';
import { NotificationType } from '@prisma/client';
import { NotFoundError } from '../utils/errors';

interface CreateNotificationData {
  userId: string;
  type: NotificationType;
  title: string;
  body: string;
  data?: any;
}

export class NotificationService {
  static async createNotification(data: CreateNotificationData) {
    const notification = await prisma.notification.create({
      data,
    });

    return notification;
  }

  static async getUserNotifications(userId: string) {
    const notifications = await prisma.notification.findMany({
      where: { userId },
      orderBy: {
        createdAt: 'desc',
      },
      take: 50,
    });

    return notifications;
  }

  static async markAsRead(notificationId: string, userId: string) {
    const notification = await prisma.notification.findUnique({
      where: { id: notificationId },
    });

    if (!notification) {
      throw new NotFoundError('Notification not found');
    }

    if (notification.userId !== userId) {
      throw new NotFoundError('Notification not found');
    }

    const updatedNotification = await prisma.notification.update({
      where: { id: notificationId },
      data: { isRead: true },
    });

    return updatedNotification;
  }

  static async markAllAsRead(userId: string) {
    await prisma.notification.updateMany({
      where: {
        userId,
        isRead: false,
      },
      data: { isRead: true },
    });

    return { message: 'All notifications marked as read' };
  }
}
