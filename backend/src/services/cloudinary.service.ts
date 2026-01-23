import cloudinary from '../config/cloudinary';
import { logger } from '../utils/logger';

export class CloudinaryService {
  static async uploadImage(
    buffer: Buffer,
    folder: string = 'profile-photos'
  ): Promise<string> {
    return new Promise((resolve, reject) => {
      const uploadStream = cloudinary.uploader.upload_stream(
        {
          folder,
          resource_type: 'image',
          transformation: [
            { width: 500, height: 500, crop: 'fill', gravity: 'face' },
            { quality: 'auto', fetch_format: 'auto' },
          ],
        },
        (error, result) => {
          if (error) {
            logger.error({ error }, 'Cloudinary upload failed');
            reject(error);
          } else {
            logger.info({ url: result?.secure_url }, 'Image uploaded to Cloudinary');
            resolve(result!.secure_url);
          }
        }
      );

      uploadStream.end(buffer);
    });
  }

  static async deleteImage(publicId: string): Promise<void> {
    try {
      await cloudinary.uploader.destroy(publicId);
      logger.info({ publicId }, 'Image deleted from Cloudinary');
    } catch (error) {
      logger.error({ error, publicId }, 'Failed to delete image from Cloudinary');
      throw error;
    }
  }
}
