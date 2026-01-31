// import { Resend } from 'resend';
import { env } from '../config/env';
import { logger } from '../utils/logger';

// TODO: Uncomment when you have a Resend API key and domain
// const resend = new Resend(env.RESEND_API_KEY);

export class EmailService {
  static async sendVerificationEmail(email: string, token: string) {
    // Token is the full verification URL from Better Auth, extract just the token part
    const actualToken = token.includes('?') ? token.split('token=')[1] || token : token;
    const verificationUrl = `${env.FRONTEND_URL}/verify-email?token=${actualToken}`;
    
    // EMAIL SENDING DISABLED - Log the verification URL instead
    // When you have an email service configured, uncomment the code below
    logger.info({ email, verificationUrl, token: actualToken }, 
      '📧 EMAIL DISABLED - Verification email would be sent. Use this URL to verify:');
    console.log(`\n🔗 VERIFICATION LINK for ${email}:\n${verificationUrl}\n`);
    
    /* TODO: Uncomment when email service is configured
    try {
      await resend.emails.send({
        from: env.EMAIL_FROM,
        to: email,
        subject: 'Verify your Travel Buddy account',
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h2 style="color: #1D3557;">Welcome to Travel Buddy! 🌍</h2>
            <p>Thank you for joining Travel Buddy, the Ethiopian travel companion platform.</p>
            <p>Please verify your email address by clicking the button below:</p>
            <div style="text-align: center; margin: 30px 0;">
              <a href="${verificationUrl}" 
                 style="background-color: #1D3557; color: white; padding: 12px 30px; 
                        text-decoration: none; border-radius: 5px; display: inline-block;">
                Verify Email
              </a>
            </div>
            <p style="color: #666; font-size: 14px;">
              Or copy and paste this link into your browser:<br>
              <a href="${verificationUrl}">${verificationUrl}</a>
            </p>
            <p style="color: #666; font-size: 12px; margin-top: 30px;">
              If you didn't create this account, you can safely ignore this email.
            </p>
          </div>
        `,
      });
      
      logger.info({ email }, 'Verification email sent');
    } catch (error) {
      logger.error({ error, email }, 'Failed to send verification email');
      throw error;
    }
    */
  }

  static async sendPasswordResetEmail(email: string, token: string) {
    // Token is the full reset URL from Better Auth, extract just the token part
    const actualToken = token.includes('?') ? token.split('token=')[1] || token : token;
    const resetUrl = `${env.FRONTEND_URL}/reset-password?token=${actualToken}`;
    
    // EMAIL SENDING DISABLED - Log the reset URL instead
    // When you have an email service configured, uncomment the code below
    logger.info({ email, resetUrl, token: actualToken }, 
      '📧 EMAIL DISABLED - Password reset email would be sent. Use this URL to reset:');
    console.log(`\n🔗 PASSWORD RESET LINK for ${email}:\n${resetUrl}\n`);
    
    /* TODO: Uncomment when email service is configured
    try {
      await resend.emails.send({
        from: env.EMAIL_FROM,
        to: email,
        subject: 'Reset your Travel Buddy password',
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h2 style="color: #1D3557;">Password Reset Request</h2>
            <p>We received a request to reset your password for your Travel Buddy account.</p>
            <p>Click the button below to reset your password:</p>
            <div style="text-align: center; margin: 30px 0;">
              <a href="${resetUrl}" 
                 style="background-color: #E73947; color: white; padding: 12px 30px; 
                        text-decoration: none; border-radius: 5px; display: inline-block;">
                Reset Password
              </a>
            </div>
            <p style="color: #666; font-size: 14px;">
              Or copy and paste this link into your browser:<br>
              <a href="${resetUrl}">${resetUrl}</a>
            </p>
            <p style="color: #666; font-size: 14px; margin-top: 20px;">
              This link will expire in 1 hour.
            </p>
            <p style="color: #666; font-size: 12px; margin-top: 30px;">
              If you didn't request a password reset, you can safely ignore this email.
            </p>
          </div>
        `,
      });
      
      logger.info({ email }, 'Password reset email sent');
    } catch (error) {
      logger.error({ error, email }, 'Failed to send password reset email');
      throw error;
    }
    */
  }
}
