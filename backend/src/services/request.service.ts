import { prisma } from '../config/database';
import { RequestStatus } from '@prisma/client';
import { NotFoundError, ForbiddenError, ConflictError, BadRequestError } from '../utils/errors';
import { NotificationService } from './notification.service';

export class RequestService {
  static async createRequest(tripId: string, requesterId: string, message?: string) {
    // Check if trip exists
    const trip = await prisma.trip.findUnique({
      where: { id: tripId },
      include: {
        creator: {
          select: {
            id: true,
            fullName: true,
          },
        },
      },
    });

    if (!trip) {
      throw new NotFoundError('Trip not found');
    }

    // Can't request to join your own trip
    if (trip.userId === requesterId) {
      throw new BadRequestError('You cannot request to join your own trip');
    }

    // Check if request already exists
    const existingRequest = await prisma.tripRequest.findUnique({
      where: {
        tripId_requesterId: {
          tripId,
          requesterId,
        },
      },
    });

    if (existingRequest) {
      throw new ConflictError('You have already sent a request for this trip');
    }

    // Create request
    const request = await prisma.tripRequest.create({
      data: {
        tripId,
        requesterId,
        message,
      },
      include: {
        trip: {
          include: {
            creator: {
              select: {
                id: true,
                fullName: true,
                profilePhotoUrl: true,
              },
            },
          },
        },
        requester: {
          select: {
            id: true,
            fullName: true,
            profilePhotoUrl: true,
            cityOfResidence: true,
            bio: true,
          },
        },
      },
    });

    // Create notification for trip owner
    await NotificationService.createNotification({
      userId: trip.userId,
      type: 'TRIP_REQUEST',
      title: 'New Trip Request',
      body: `${request.requester.fullName} wants to join your trip to ${trip.destinationName}`,
      data: {
        requestId: request.id,
        tripId: trip.id,
        requesterId: requesterId,
      },
    });

    return request;
  }

  static async getRequestsForTrip(tripId: string, userId: string) {
    // Check if user is the trip owner
    const trip = await prisma.trip.findUnique({
      where: { id: tripId },
    });

    if (!trip) {
      throw new NotFoundError('Trip not found');
    }

    if (trip.userId !== userId) {
      throw new ForbiddenError('You can only view requests for your own trips');
    }

    const requests = await prisma.tripRequest.findMany({
      where: { tripId },
      include: {
        requester: {
          select: {
            id: true,
            fullName: true,
            profilePhotoUrl: true,
            cityOfResidence: true,
            bio: true,
            travelPreferences: true,
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    return requests;
  }

  static async respondToRequest(
    requestId: string,
    userId: string,
    status: RequestStatus
  ) {
    const request = await prisma.tripRequest.findUnique({
      where: { id: requestId },
      include: {
        trip: true,
        requester: {
          select: {
            id: true,
            fullName: true,
          },
        },
      },
    });

    if (!request) {
      throw new NotFoundError('Request not found');
    }

    // Check if user is the trip owner
    if (request.trip.userId !== userId) {
      throw new ForbiddenError('You can only respond to requests for your own trips');
    }

    // Update request status
    const updatedRequest = await prisma.tripRequest.update({
      where: { id: requestId },
      data: { status },
      include: {
        trip: {
          include: {
            creator: {
              select: {
                id: true,
                fullName: true,
                profilePhotoUrl: true,
              },
            },
          },
        },
        requester: {
          select: {
            id: true,
            fullName: true,
            profilePhotoUrl: true,
            cityOfResidence: true,
            bio: true,
          },
        },
      },
    });

    // Create notification for requester
    const notificationType = status === RequestStatus.ACCEPTED ? 'REQUEST_ACCEPTED' : 'REQUEST_REJECTED';
    const notificationBody =
      status === RequestStatus.ACCEPTED
        ? `Your request to join the trip to ${request.trip.destinationName} was accepted!`
        : `Your request to join the trip to ${request.trip.destinationName} was declined.`;

    await NotificationService.createNotification({
      userId: request.requesterId,
      type: notificationType,
      title: status === RequestStatus.ACCEPTED ? 'Request Accepted' : 'Request Declined',
      body: notificationBody,
      data: {
        requestId: request.id,
        tripId: request.tripId,
      },
    });

    return updatedRequest;
  }

  static async getSentRequests(userId: string) {
    const requests = await prisma.tripRequest.findMany({
      where: { requesterId: userId },
      include: {
        trip: {
          include: {
            creator: {
              select: {
                id: true,
                fullName: true,
                profilePhotoUrl: true,
              },
            },
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    return requests;
  }

  static async getReceivedRequests(userId: string) {
    const requests = await prisma.tripRequest.findMany({
      where: {
        trip: {
          userId,
        },
      },
      include: {
        trip: true,
        requester: {
          select: {
            id: true,
            fullName: true,
            profilePhotoUrl: true,
            cityOfResidence: true,
            bio: true,
            travelPreferences: true,
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    return requests;
  }
}
