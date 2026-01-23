import { betterAuth } from "better-auth";
import { prismaAdapter } from "better-auth/adapters/prisma";
import { prisma } from "../config/database";
import { EmailService } from "../services/email.service";

export const auth = betterAuth({
  appName: "TravelBro",
  database: prismaAdapter(prisma, {
    provider: "postgresql",
  }),
  emailAndPassword: {
    enabled: true,
    requireEmailVerification: true,
    sendResetPassword: async ({ user, url }) => {
      const token = url.split("token=")[1];
      await EmailService.sendPasswordResetEmail(user.email, token);
    },
  },
  emailVerification: {
    sendOnSignUp: true,
    sendVerificationEmail: async ({ user, url }) => {
      const token = url.split("token=")[1];
      await EmailService.sendVerificationEmail(user.email, token);
    },
  },
  session: {
    expiresIn: 60 * 60 * 24 * 7, // 7 days
    updateAge: 60 * 60 * 24, // 1 day
    cookieCache: {
      enabled: true,
      maxAge: 60 * 15, // 15 minutes (match JWT expiry)
    },
  },
  user: {
    additionalFields: {
      fullName: {
        type: "string",
        required: true,
        fieldName: "full_name",
      },
      profilePhotoUrl: {
        type: "string",
        required: false,
        fieldName: "profile_photo_url",
      },
      cityOfResidence: {
        type: "string",
        required: false,
        fieldName: "city_of_residence",
      },
      bio: {
        type: "string",
        required: false,
      },
      travelPreferences: {
        type: "string",
        required: false,
        fieldName: "travel_preferences",
      },
    },
  },
  advanced: {
    useSecureCookies: process.env.NODE_ENV === "production",
    generateId: () => {
      // Use UUID v4 for consistency with existing schema
      return crypto.randomUUID();
    },
  },
  trustedOrigins: process.env.ALLOWED_ORIGINS?.split(",") || [],
});

export type Session = typeof auth.$Infer.Session;
