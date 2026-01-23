import { Request, Response, NextFunction } from 'express';
import { TripService } from '../services/trip.service';
import { CloudinaryService } from '../services/cloudinary.service';
import { ApiResponse } from '../utils/response';

export class TripController {
  static async createTrip(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.userId;
      const trip = await TripService.createTrip(userId, req.body);
      ApiResponse.success(res, trip, 'Trip created successfully', 201);
    } catch (error) {
      next(error);
    }
  }

  static async getTrips(req: Request, res: Response, next: NextFunction) {
    try {
      const { trips, total, page, limit } = await TripService.getTrips(req.query);
      ApiResponse.paginated(res, trips, page, limit, total);
    } catch (error) {
      next(error);
    }
  }

  static async getTripById(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id as string;
      const trip = await TripService.getTripById(id);
      ApiResponse.success(res, trip);
    } catch (error) {
      next(error);
    }
  }

  static async updateTrip(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id as string;
      const userId = req.user!.userId;
      const trip = await TripService.updateTrip(id, userId, req.body);
      ApiResponse.success(res, trip, 'Trip updated successfully');
    } catch (error) {
      next(error);
    }
  }

  static async deleteTrip(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id as string;
      const userId = req.user!.userId;
      const result = await TripService.deleteTrip(id, userId);
      ApiResponse.success(res, result);
    } catch (error) {
      next(error);
    }
  }

  static async getMyTrips(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.userId;
      const trips = await TripService.getMyTrips(userId);
      ApiResponse.success(res, trips);
    } catch (error) {
      next(error);
    }
  }

  static async uploadTripPhoto(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.file) {
        ApiResponse.error(res, 'No photo uploaded', 400);
        return;
      }

      const photoUrl = await CloudinaryService.uploadImage(
        req.file.buffer,
        'trip-photos'
      );

      ApiResponse.success(res, { photoUrl }, 'Photo uploaded successfully');
    } catch (error) {
      next(error);
    }
  }
}
