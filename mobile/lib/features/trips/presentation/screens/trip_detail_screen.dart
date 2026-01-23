import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/constants/strings.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/services/providers.dart';
import '../../../../../shared/models/trip.dart';

class TripDetailScreen extends ConsumerWidget {
  final String tripId;

  const TripDetailScreen({super.key, required this.tripId});

  Future<void> _openInstagram(String username) async {
    // Remove @ if present
    final cleanUsername = username.startsWith('@') 
        ? username.substring(1) 
        : username;
    final uri = Uri.parse('https://instagram.com/$cleanUsername');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openTelegram(String username) async {
    final cleanUsername = username.startsWith('@') 
        ? username.substring(1) 
        : username;
    final uri = Uri.parse('https://t.me/$cleanUsername');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(
      FutureProvider((ref) => ref.read(apiServiceProvider).getTrip(tripId)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.tripDetails),
      ),
      body: tripAsync.when(
        data: (trip) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trip Photo
              if (trip.photoUrl != null)
                CachedNetworkImage(
                  imageUrl: trip.photoUrl!,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              else
                Container(
                  height: 200,
                  color: AppColors.softTeal,
                  child: const Center(
                    child: Icon(Icons.photo, size: 64, color: Colors.white54),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMD),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Destination name
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 24,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            trip.destinationName,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingLG),
                    
                    // Dates
                    _DetailRow(
                      icon: Icons.calendar_today,
                      label: 'Dates',
                      value: trip.formattedDateRange,
                    ),
                    const SizedBox(height: AppTheme.spacingMD),
                    
                    // People needed
                    _DetailRow(
                      icon: Icons.people,
                      label: 'People Needed',
                      value: '${trip.peopleNeeded}',
                    ),
                    const SizedBox(height: AppTheme.spacingMD),
                    
                    // Budget
                    _DetailRow(
                      icon: Icons.attach_money,
                      label: 'Budget',
                      value: trip.budgetLevel,
                    ),
                    const SizedBox(height: AppTheme.spacingMD),
                    
                    // Travel style
                    _DetailRow(
                      icon: Icons.explore,
                      label: 'Travel Style',
                      value: trip.travelStyle,
                    ),
                    
                    if (trip.description != null) ...[
                      const SizedBox(height: AppTheme.spacingLG),
                      Text(
                        AppStrings.description,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: AppTheme.spacingSM),
                      Text(
                        trip.description!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    
                    const SizedBox(height: AppTheme.spacingLG),
                    
                    // Creator info
                    Text(
                      'Trip Creator',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacingSM),
                    Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: trip.creator.profilePhotoUrl != null
                              ? CachedNetworkImageProvider(trip.creator.profilePhotoUrl!)
                              : null,
                          child: trip.creator.profilePhotoUrl == null
                              ? Text(trip.creator.fullName.substring(0, 1).toUpperCase())
                              : null,
                        ),
                        title: Text(trip.creator.fullName),
                        subtitle: trip.creator.cityOfResidence != null
                            ? Text(trip.creator.cityOfResidence!)
                            : null,
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.spacingLG),
                    
                    // Contact Information
                    Text(
                      'Contact Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacingSM),
                    Card(
                      child: Column(
                        children: [
                          // Instagram (always shown)
                          ListTile(
                            leading: const Icon(Icons.camera_alt_outlined),
                            title: const Text('Instagram'),
                            subtitle: Text(trip.instagramUsername),
                            trailing: IconButton(
                              icon: const Icon(Icons.open_in_new),
                              onPressed: () => _openInstagram(trip.instagramUsername),
                            ),
                          ),
                          
                          // Phone (if provided)
                          if (trip.phoneNumber != null) ...[
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.phone_outlined),
                              title: const Text('Phone'),
                              subtitle: Text(trip.phoneNumber!),
                              trailing: IconButton(
                                icon: const Icon(Icons.call),
                                onPressed: () => _callPhone(trip.phoneNumber!),
                              ),
                            ),
                          ],
                          
                          // Telegram (if provided)
                          if (trip.telegramUsername != null) ...[
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.send_outlined),
                              title: const Text('Telegram'),
                              subtitle: Text(trip.telegramUsername!),
                              trailing: IconButton(
                                icon: const Icon(Icons.open_in_new),
                                onPressed: () => _openTelegram(trip.telegramUsername!),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.spacingXL),
                    
                    // Request button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _openInstagram(trip.instagramUsername),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warmCoral,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Connect on Instagram'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: AppTheme.spacingMD),
              Text('Error: $error'),
              const SizedBox(height: AppTheme.spacingMD),
              ElevatedButton(
                onPressed: () => ref.invalidate(
                  FutureProvider((ref) => ref.read(apiServiceProvider).getTrip(tripId)),
                ),
                child: const Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
