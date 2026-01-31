import { prisma } from '../config/database';
import { NotFoundError } from '../utils/errors';
import { CloudinaryService } from './cloudinary.service';

export class UserService {
  static async getCurrentUser(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        name: true,
        fullName: true,
        profilePhotoUrl: true,
        image: true,
        cityOfResidence: true,
        bio: true,
        travelPreferences: true,
        interests: true,
        emailVerified: true,
        createdAt: true,
      },
    });

    if (!user) {
      throw new NotFoundError('User not found');
    }

    // Return consistent format
    return {
      id: user.id,
      email: user.email,
      fullName: user.fullName || user.name,
      profilePhotoUrl: user.profilePhotoUrl || user.image,
      cityOfResidence: user.cityOfResidence,
      bio: user.bio,
      travelPreferences: user.travelPreferences,
      interests: user.interests,
      emailVerified: user.emailVerified,
      createdAt: user.createdAt,
    };
  }

  static async updateProfile(
    userId: string,
    data: {
      fullName?: string;
      cityOfResidence?: string;
      bio?: string;
      travelPreferences?: string;
      interests?: string;
    }
  ) {
    const user = await prisma.user.update({
      where: { id: userId },
      data: {
        ...data,
        // Also update name field for Better Auth compatibility
        ...(data.fullName && { name: data.fullName }),
      },
      select: {
        id: true,
        email: true,
        name: true,
        fullName: true,
        profilePhotoUrl: true,
        image: true,
        cityOfResidence: true,
        bio: true,
        travelPreferences: true,
        interests: true,
        emailVerified: true,
        createdAt: true,
      },
    });

    return {
      id: user.id,
      email: user.email,
      fullName: user.fullName || user.name,
      profilePhotoUrl: user.profilePhotoUrl || user.image,
      cityOfResidence: user.cityOfResidence,
      bio: user.bio,
      travelPreferences: user.travelPreferences,
      interests: user.interests,
      emailVerified: user.emailVerified,
      createdAt: user.createdAt,
    };
  }

  static async uploadProfilePhoto(userId: string, file: Express.Multer.File) {
    // Upload to Cloudinary
    const photoUrl = await CloudinaryService.uploadImage(
      file.buffer,
      'profile-photos'
    );

    // Update user profile (both fields for compatibility)
    await prisma.user.update({
      where: { id: userId },
      data: {
        profilePhotoUrl: photoUrl,
        image: photoUrl, // Better Auth field
      },
    });

    return { photoUrl };
  }

  static async getUserById(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        name: true,
        fullName: true,
        profilePhotoUrl: true,
        image: true,
        cityOfResidence: true,
        bio: true,
        travelPreferences: true,
        interests: true,
        createdAt: true,
      },
    });

    if (!user) {
      throw new NotFoundError('User not found');
    }

    return {
      id: user.id,
      fullName: user.fullName || user.name,
      profilePhotoUrl: user.profilePhotoUrl || user.image,
      cityOfResidence: user.cityOfResidence,
      bio: user.bio,
      travelPreferences: user.travelPreferences,
      interests: user.interests,
      createdAt: user.createdAt,
    };
  }
}
