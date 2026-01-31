import { prisma } from '../config/database';
import { RequestStatus, TripStatus } from '@prisma/client';
import { NotFoundError, ForbiddenError, ConflictError, BadRequestError } from '../utils/errors';
import { NotificationService } from './notification.service';

export class RequestService {
  // Helper method to check if a user is blocked
  private static async isBlocked(blockerId: string, blockedId: string): Promise<boolean> {
    const block = await prisma.block.findUnique({
      where: {
        blockerId_blockedId: {
          blockerId,
          blockedId,
        },
      },
    });
    return !!block;
  }

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

    // Check if trip is active
    if (trip.status !== TripStatus.ACTIVE) {
      throw new BadRequestError('This trip is no longer accepting requests');
    }

    // Can't request to join your own trip
    if (trip.userId === requesterId) {
      throw new BadRequestError('You cannot request to join your own trip');
    }

    // Check if either user has blocked the other
    const [requesterBlockedOwner, ownerBlockedRequester] = await Promise.all([
      this.isBlocked(requesterId, trip.userId),
      this.isBlocked(trip.userId, requesterId),
    ]);

    if (requesterBlockedOwner || ownerBlockedRequester) {
      throw new ForbiddenError('You cannot send a request to this trip');
    }

    // Check if trip is already full (count accepted requests)
    const acceptedCount = await prisma.tripRequest.count({
      where: {
        tripId,
        status: RequestStatus.ACCEPTED,
      },
    });

    if (acceptedCount >= trip.peopleNeeded) {
      throw new BadRequestError('This trip is already full');
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
    // Use a transaction to prevent race conditions when accepting requests
    const result = await prisma.$transaction(async (tx) => {
      const request = await tx.tripRequest.findUnique({
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

      // Check if request has already been responded to
      if (request.status !== RequestStatus.PENDING) {
        throw new BadRequestError('This request has already been responded to');
      }

      // If accepting, check capacity
      if (status === RequestStatus.ACCEPTED) {
        const acceptedCount = await tx.tripRequest.count({
          where: {
            tripId: request.tripId,
            status: RequestStatus.ACCEPTED,
          },
        });

        if (acceptedCount >= request.trip.peopleNeeded) {
          throw new BadRequestError('This trip is already full. Cannot accept more requests.');
        }
      }

      // Update request status
      const updatedRequest = await tx.tripRequest.update({
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

      return { updatedRequest, request };
    });

    // Create notification for requester (outside transaction for better performance)
    const notificationType = status === RequestStatus.ACCEPTED ? 'REQUEST_ACCEPTED' : 'REQUEST_REJECTED';
    const notificationBody =
      status === RequestStatus.ACCEPTED
        ? `Your request to join the trip to ${result.request.trip.destinationName} was accepted!`
        : `Your request to join the trip to ${result.request.trip.destinationName} was declined.`;

    await NotificationService.createNotification({
      userId: result.request.requesterId,
      type: notificationType,
      title: status === RequestStatus.ACCEPTED ? 'Request Accepted' : 'Request Declined',
      body: notificationBody,
      data: {
        requestId: result.request.id,
        tripId: result.request.tripId,
      },
    });

    return result.updatedRequest;
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

  static async getMessages(requestId: string, userId: string, page: number = 1, limit: number = 50) {
    // Get the request and verify user has access
    const request = await prisma.tripRequest.findUnique({
      where: { id: requestId },
      include: {
        trip: {
          select: {
            userId: true,
          },
        },
      },
    });

    if (!request) {
      throw new NotFoundError('Request not found');
    }

    // Only requester or trip owner can access messages
    if (request.requesterId !== userId && request.trip.userId !== userId) {
      throw new ForbiddenError('You do not have access to these messages');
    }

    // Messages are only accessible for accepted requests
    if (request.status !== RequestStatus.ACCEPTED) {
      throw new ForbiddenError('Messages are only available for accepted requests');
    }

    const skip = (page - 1) * limit;

    const [messages, total] = await Promise.all([
      prisma.message.findMany({
        where: { tripRequestId: requestId },
        include: {
          sender: {
            select: {
              id: true,
              fullName: true,
              profilePhotoUrl: true,
            },
          },
        },
        orderBy: {
          createdAt: 'desc',
        },
        skip,
        take: limit,
      }),
      prisma.message.count({
        where: { tripRequestId: requestId },
      }),
    ]);

    return {
      messages: messages.reverse(), // Return in chronological order
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  static async getConversations(userId: string) {
    // Get all accepted requests where user is requester or trip owner
    const requests = await prisma.tripRequest.findMany({
      where: {
        status: 'ACCEPTED',
        OR: [
          { requesterId: userId },
          { trip: { userId } },
        ],
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
          },
        },
        messages: {
          orderBy: {
            createdAt: 'desc',
          },
          take: 1,
          include: {
            sender: {
              select: {
                id: true,
                fullName: true,
              },
            },
          },
        },
      },
      orderBy: {
        updatedAt: 'desc',
      },
    });

    // Add unread count for each conversation
    const conversationsWithUnread = await Promise.all(
      requests.map(async (request) => {
        const unreadCount = await prisma.message.count({
          where: {
            tripRequestId: request.id,
            receiverId: userId,
            isRead: false,
          },
        });

        return {
          ...request,
          unreadCount,
          lastMessage: request.messages[0] || null,
        };
      })
    );

    return conversationsWithUnread;
  }

  static async getRequestByTripAndUser(tripId: string, userId: string) {
    const request = await prisma.tripRequest.findUnique({
      where: {
        tripId_requesterId: {
          tripId,
          requesterId: userId,
        },
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
          },
        },
      },
    });

    return request;
  }
}
