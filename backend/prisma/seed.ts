import { PrismaClient, DestinationType } from '@prisma/client';

const prisma = new PrismaClient();

const ethiopianDestinations = [
  {
    name: 'Addis Ababa',
    region: 'Addis Ababa',
    type: DestinationType.CITY,
    latitude: 9.0320,
    longitude: 38.7469,
    isHeritageSite: false,
    description: 'The capital city of Ethiopia, a vibrant hub of culture, history, and modernity.',
    imageUrl: 'https://images.unsplash.com/photo-1611348524140-53c9a25263d6?w=800',
  },
  {
    name: 'Lalibela',
    region: 'Amhara',
    type: DestinationType.HISTORICAL,
    latitude: 12.0316,
    longitude: 39.0473,
    isHeritageSite: true,
    description: 'Famous for its rock-hewn churches, a UNESCO World Heritage Site.',
    imageUrl: 'https://images.unsplash.com/photo-1609137144813-7d9921338f24?w=800',
  },
  {
    name: 'Gondar',
    region: 'Amhara',
    type: DestinationType.HISTORICAL,
    latitude: 12.6,
    longitude: 37.4667,
    isHeritageSite: true,
    description: 'Known for its medieval castles and the royal enclosure of Emperor Fasilides.',
    imageUrl: 'https://images.unsplash.com/photo-1568632234157-ce7aecd03d0d?w=800',
  },
  {
    name: 'Axum',
    region: 'Tigray',
    type: DestinationType.HISTORICAL,
    latitude: 14.1212,
    longitude: 38.7167,
    isHeritageSite: true,
    description: 'Ancient city with towering obelisks and rich archaeological heritage.',
    imageUrl: 'https://images.unsplash.com/photo-1578898886926-a9b4e54087fe?w=800',
  },
  {
    name: 'Hawassa',
    region: 'Sidama',
    type: DestinationType.CITY,
    latitude: 7.0521,
    longitude: 38.4762,
    isHeritageSite: false,
    description: 'Lakeside city with beautiful scenery and relaxing atmosphere.',
    imageUrl: 'https://images.unsplash.com/photo-1590523741831-ab7e8b8f9c7f?w=800',
  },
  {
    name: 'Bahir Dar',
    region: 'Amhara',
    type: DestinationType.CITY,
    latitude: 11.5742,
    longitude: 37.3615,
    isHeritageSite: false,
    description: 'Gateway to Lake Tana and the Blue Nile Falls.',
    imageUrl: 'https://images.unsplash.com/photo-1611348589818-091e5a4e4f5d?w=800',
  },
  {
    name: 'Jimma',
    region: 'Oromia',
    type: DestinationType.CITY,
    latitude: 7.6667,
    longitude: 36.8333,
    isHeritageSite: false,
    description: 'Coffee capital of Ethiopia with lush green landscapes.',
    imageUrl: 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=800',
  },
  {
    name: 'Arba Minch',
    region: 'SNNPR',
    type: DestinationType.NATURE,
    latitude: 6.0333,
    longitude: 37.55,
    isHeritageSite: false,
    description: 'Known for its twin lakes and abundant wildlife in Nechisar National Park.',
    imageUrl: 'https://images.unsplash.com/photo-1516426122078-c23e76319801?w=800',
  },
  {
    name: 'Harar',
    region: 'Harari',
    type: DestinationType.HISTORICAL,
    latitude: 9.3103,
    longitude: 42.1178,
    isHeritageSite: true,
    description: 'Walled city with unique Islamic architecture and vibrant markets.',
    imageUrl: 'https://images.unsplash.com/photo-1588416936097-41850ab3d86d?w=800',
  },
  {
    name: 'Simien Mountains',
    region: 'Amhara',
    type: DestinationType.NATURE,
    latitude: 13.25,
    longitude: 38.0,
    isHeritageSite: true,
    description: 'Dramatic mountain scenery with endemic wildlife like Gelada baboons.',
    imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
  },
  {
    name: 'Bale Mountains',
    region: 'Oromia',
    type: DestinationType.NATURE,
    latitude: 6.9,
    longitude: 39.7333,
    isHeritageSite: false,
    description: 'Home to the Ethiopian wolf and stunning Afro-alpine landscapes.',
    imageUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800',
  },
  {
    name: 'Danakil Depression',
    region: 'Afar',
    type: DestinationType.NATURE,
    latitude: 14.2417,
    longitude: 40.3,
    isHeritageSite: false,
    description: 'One of the hottest places on Earth with colorful sulfur springs and salt flats.',
    imageUrl: 'https://images.unsplash.com/photo-1595433707802-6b2626ef1c91?w=800',
  },
  {
    name: 'Omo Valley',
    region: 'SNNPR',
    type: DestinationType.CULTURAL,
    latitude: 5.95,
    longitude: 36.4,
    isHeritageSite: true,
    description: 'Home to diverse indigenous tribes with rich cultural traditions.',
    imageUrl: 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?w=800',
  },
  {
    name: 'Lake Tana',
    region: 'Amhara',
    type: DestinationType.NATURE,
    latitude: 12.0,
    longitude: 37.3167,
    isHeritageSite: false,
    description: 'Ethiopia\'s largest lake with ancient island monasteries.',
    imageUrl: 'https://images.unsplash.com/photo-1580711508484-fe5241ee0dc3?w=800',
  },
];

async function main() {
  console.log('🌱 Starting seed...');

  // Clear existing destinations
  await prisma.destination.deleteMany({});
  console.log('Cleared existing destinations');

  // Seed destinations
  for (const destination of ethiopianDestinations) {
    await prisma.destination.create({
      data: destination,
    });
    console.log(`✅ Created destination: ${destination.name}`);
  }

  console.log('🌱 Seed completed successfully!');
}

main()
  .catch((e) => {
    console.error('❌ Seed failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
