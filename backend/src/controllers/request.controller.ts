import { Request, Response, NextFunction } from 'express';
import { RequestService } from '../services/request.service';
import { ApiResponse } from '../utils/response';

export class RequestController {
  static async createRequest(req: Request, res: Response, next: NextFunction) {
    try {
      const tripId = req.params.tripId as string;
      const userId = req.user!.userId;
      const { message } = req.body;

      const request = await RequestService.createRequest(tripId, userId, message);
      ApiResponse.success(res, request, 'Request sent successfully', 201);
    } catch (error) {
      next(error);
    }
  }

  static async getRequestsForTrip(req: Request, res: Response, next: NextFunction) {
    try {
      const tripId = req.params.tripId as string;
      const userId = req.user!.userId;

      const requests = await RequestService.getRequestsForTrip(tripId, userId);
      ApiResponse.success(res, requests);
    } catch (error) {
      next(error);
    }
  }

  static async respondToRequest(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id as string;
      const userId = req.user!.userId;
      const { status } = req.body;

      const request = await RequestService.respondToRequest(id, userId, status);
      ApiResponse.success(res, request, 'Request updated successfully');
    } catch (error) {
      next(error);
    }
  }

  static async getSentRequests(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.userId;
      const requests = await RequestService.getSentRequests(userId);
      ApiResponse.success(res, requests);
    } catch (error) {
      next(error);
    }
  }

  static async getReceivedRequests(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.userId;
      const requests = await RequestService.getReceivedRequests(userId);
      ApiResponse.success(res, requests);
    } catch (error) {
      next(error);
    }
  }

  static async getMessages(req: Request, res: Response, next: NextFunction) {
    try {
      const requestId = req.params.id as string;
      const userId = req.user!.userId;
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 50;

      const result = await RequestService.getMessages(requestId, userId, page, limit);
      ApiResponse.success(res, result);
    } catch (error) {
      next(error);
    }
  }

  static async getConversations(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.userId;
      const conversations = await RequestService.getConversations(userId);
      ApiResponse.success(res, conversations);
    } catch (error) {
      next(error);
    }
  }

  static async getRequestByTripAndUser(req: Request, res: Response, next: NextFunction) {
    try {
      const tripId = req.params.tripId as string;
      const userId = req.user!.userId;
      const request = await RequestService.getRequestByTripAndUser(tripId, userId);
      ApiResponse.success(res, request);
    } catch (error) {
      next(error);
    }
  }
}
