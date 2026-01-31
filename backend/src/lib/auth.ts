import { prisma } from "../config/database";
import { EmailService } from "../services/email.service";

// Use dynamic import for ESM module
let authInstance: any = null;

export async function getAuth() {
  if (authInstance) return authInstance;
  
  const { betterAuth } = await import("better-auth");
  const { prismaAdapter } = await import("better-auth/adapters/prisma");
  
  authInstance = betterAuth({
    appName: "Travel Buddy",
    database: prismaAdapter(prisma, {
      provider: "postgresql",
    }),
    emailAndPassword: {
      enabled: true,
      requireEmailVerification: false, // Disable for easier testing
      sendResetPassword: async ({ user, url }: { user: any; url: string }) => {
        const token = url.split("token=")[1];
        await EmailService.sendPasswordResetEmail(user.email, token);
      },
    },
    emailVerification: {
      sendOnSignUp: false, // Disable for easier testing
      sendVerificationEmail: async ({ user, url }: { user: any; url: string }) => {
        const token = url.split("token=")[1];
        await EmailService.sendVerificationEmail(user.email, token);
      },
    },
    session: {
      expiresIn: 60 * 60 * 24 * 7, // 7 days
      updateAge: 60 * 60 * 24, // 1 day
      cookieCache: {
        enabled: true,
        maxAge: 60 * 15, // 15 minutes
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
        return crypto.randomUUID();
      },
    },
    trustedOrigins: process.env.ALLOWED_ORIGINS?.split(",") || ["*"],
  });
  
  return authInstance;
}

// For backwards compatibility, export a lazy-loaded auth
export const auth = {
  async handler(req: any) {
    const authInst = await getAuth();
    return authInst.handler(req);
  },
  api: {
    async getSession(options: any) {
      const authInst = await getAuth();
      return authInst.api.getSession(options);
    },
  },
};

export type Session = any;
