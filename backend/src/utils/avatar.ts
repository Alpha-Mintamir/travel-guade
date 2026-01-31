/**
 * DiceBear Avatar Utility
 * Generates random avatar URLs using the free DiceBear API
 * https://www.dicebear.com/
 */

// Avatar styles categorized by gender tendency
export const FEMININE_STYLES = [
  'lorelei',         // Elegant, artistic avatars (feminine)
  'lorelei-neutral', // Elegant neutral style
  'big-ears',        // Cute cartoon style (great for women)
  'big-ears-neutral', // Cute neutral style
  'avataaars',       // Cartoon-style (diverse, good female options)
  'open-peeps',      // Open source diverse illustrations
] as const;

export const MASCULINE_STYLES = [
  'adventurer',      // Cool illustrated avatars (masculine leaning)
  'adventurer-neutral', // Neutral adventurer style
  'micah',           // Simple, modern illustrated avatars
  'personas',        // Diverse avatar illustrations
  'avataaars',       // Cartoon-style (diverse, good male options)
  'notionists',      // Notion-style avatars
] as const;

export const NEUTRAL_STYLES = [
  'bottts',          // Fun robot avatars (gender neutral)
  'pixel-art',       // Retro pixel art avatars
  'fun-emoji',       // Fun emoji-style avatars
  'notionists-neutral', // Neutral notion style
  'thumbs',          // Thumbs up style
  'big-smile',       // Big smile cartoon style
] as const;

// All styles combined for the picker
export const AVATAR_STYLES = [
  ...FEMININE_STYLES,
  ...MASCULINE_STYLES.filter(s => !FEMININE_STYLES.includes(s as any)),
  ...NEUTRAL_STYLES,
] as const;

export type AvatarStyle = string;

/**
 * Generate a DiceBear avatar URL
 * @param seed - Unique seed for consistent avatar (usually user ID or email)
 * @param style - Avatar style from AVATAR_STYLES
 * @param size - Image size in pixels (default 200)
 * @returns Avatar URL
 */
export function generateAvatarUrl(
  seed: string,
  style: AvatarStyle = 'adventurer',
  size: number = 200
): string {
  const encodedSeed = encodeURIComponent(seed);
  return `https://api.dicebear.com/8.x/${style}/png?seed=${encodedSeed}&size=${size}`;
}

/**
 * Generate a random avatar URL with a random style
 * @param seed - Unique seed for consistent avatar
 * @param size - Image size in pixels
 * @returns Avatar URL with random style
 */
export function generateRandomAvatarUrl(seed: string, size: number = 200): string {
  const randomStyle = AVATAR_STYLES[Math.floor(Math.random() * AVATAR_STYLES.length)];
  return generateAvatarUrl(seed, randomStyle, size);
}

export type Gender = 'MALE' | 'FEMALE' | null;

/**
 * Generate a gender-appropriate avatar URL
 * @param seed - Unique seed for consistent avatar
 * @param gender - User's gender (MALE or FEMALE)
 * @param size - Image size in pixels
 * @returns Avatar URL with appropriate style for gender
 */
export function generateGenderedAvatarUrl(
  seed: string,
  gender: Gender,
  size: number = 200
): string {
  let styles: readonly string[];
  
  switch (gender) {
    case 'FEMALE':
      styles = FEMININE_STYLES;
      break;
    case 'MALE':
      styles = MASCULINE_STYLES;
      break;
    default:
      // If no gender specified, pick from all styles
      styles = AVATAR_STYLES;
      break;
  }
  
  const randomStyle = styles[Math.floor(Math.random() * styles.length)];
  return generateAvatarUrl(seed, randomStyle, size);
}

/**
 * Get all available avatar URLs for a given seed (for avatar picker)
 * @param seed - Unique seed
 * @param size - Image size
 * @returns Array of avatar URLs with their styles
 */
export function getAllAvatarOptions(seed: string, size: number = 200): Array<{ style: AvatarStyle; url: string }> {
  return AVATAR_STYLES.map(style => ({
    style,
    url: generateAvatarUrl(seed, style, size),
  }));
}
