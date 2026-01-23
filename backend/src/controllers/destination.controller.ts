import { Request, Response, NextFunction } from 'express';
import { DestinationService } from '../services/destination.service';
import { ApiResponse } from '../utils/response';
import { DestinationType } from '@prisma/client';

export class DestinationController {
  static async getAllDestinations(req: Request, res: Response, next: NextFunction) {
    try {
      const { region, type } = req.query;
      
      const destinations = await DestinationService.getAllDestinations({
        region: region as string | undefined,
        type: type as DestinationType | undefined,
      });
      
      ApiResponse.success(res, destinations);
    } catch (error) {
      next(error);
    }
  }

  static async getDestinationById(req: Request, res: Response, next: NextFunction) {
    try {
      const id = parseInt(req.params.id as string);
      const destination = await DestinationService.getDestinationById(id);
      ApiResponse.success(res, destination);
    } catch (error) {
      next(error);
    }
  }
}
