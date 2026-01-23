import { prisma } from '../config/database';
import { DestinationType } from '@prisma/client';
import { NotFoundError } from '../utils/errors';

export class DestinationService {
  static async getAllDestinations(filters?: {
    region?: string;
    type?: DestinationType;
  }) {
    const destinations = await prisma.destination.findMany({
      where: {
        ...(filters?.region && { region: filters.region }),
        ...(filters?.type && { type: filters.type }),
      },
      orderBy: {
        name: 'asc',
      },
    });

    return destinations;
  }

  static async getDestinationById(id: number) {
    const destination = await prisma.destination.findUnique({
      where: { id },
    });

    if (!destination) {
      throw new NotFoundError('Destination not found');
    }

    return destination;
  }
}
