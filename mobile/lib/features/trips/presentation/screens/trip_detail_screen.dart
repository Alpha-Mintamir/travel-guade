import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/constants/strings.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/widgets/skeleton_loaders.dart';
import '../../../../../shared/models/trip.dart';  // For TripExtensions
import '../../../../../shared/models/trip_request.dart';
import '../../providers/trips_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../requests/providers/requests_provider.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  final String tripId;

  const TripDetailScreen({super.key, required this.tripId});

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  bool _isDeleting = false;

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

  Future<void> _deleteTrip(Trip trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Trip'),
        content: Text(
          'Are you sure you want to delete your trip to ${trip.destinationName}? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isDeleting = true);
      
      try {
        await ref.read(tripsNotifierProvider.notifier).deleteTrip(trip.id);
        await ref.read(myTripsNotifierProvider.notifier).deleteTrip(trip.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trip deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete trip: $e'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isDeleting = false);
        }
      }
    }
  }

  void _editTrip(Trip trip) {
    context.push('/edit-trip', extra: trip);
  }

  bool _isOwner(Trip trip) {
    final currentUser = ref.read(authStateProvider).valueOrNull;
    return currentUser != null && trip.userId == currentUser.id;
  }

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(tripByIdProvider(widget.tripId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.tripDetails),
        actions: [
          tripAsync.whenOrNull(
            data: (trip) => _isOwner(trip)
                ? PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editTrip(trip);
                      } else if (value == 'delete') {
                        _deleteTrip(trip);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined),
                            SizedBox(width: 12),
                            Text('Edit Trip'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            const SizedBox(width: 12),
                            Text(
                              'Delete Trip',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : null,
          ) ?? const SizedBox.shrink(),
        ],
      ),
      body: _isDeleting
          ? const Center(child: CircularProgressIndicator())
          : tripAsync.when(
        data: (trip) => SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trip Photo with Hero animation
              Hero(
                tag: 'trip-image-${trip.id}',
                child: trip.photoUrl != null
                    ? CachedNetworkImage(
                        imageUrl: trip.photoUrl!,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            height: 250,
                            color: Colors.white,
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          height: 250,
                          color: AppColors.softTeal,
                          child: const Icon(Icons.image_not_supported, size: 64),
                        ),
                      )
                    : Container(
                        height: 200,
                        color: AppColors.softTeal,
                        child: const Center(
                          child: Icon(Icons.photo, size: 64, color: Colors.white54),
                        ),
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
                    
                    // Request button - built separately for cleaner code
                    _TripActionButton(trip: trip, tripId: widget.tripId),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const TripDetailSkeleton(),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: AppTheme.spacingMD),
              Text('Error: $error'),
              const SizedBox(height: AppTheme.spacingMD),
              ElevatedButton(
                onPressed: () => ref.invalidate(tripByIdProvider(widget.tripId)),
                child: const Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Action button widget that shows different states based on user's relationship to the trip
class _TripActionButton extends ConsumerStatefulWidget {
  final Trip trip;
  final String tripId;

  const _TripActionButton({required this.trip, required this.tripId});

  @override
  ConsumerState<_TripActionButton> createState() => _TripActionButtonState();
}

class _TripActionButtonState extends ConsumerState<_TripActionButton> {
  bool _isSubmitting = false;

  Future<void> _showRequestDialog() async {
    final messageController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request to Join'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Send a request to join this trip to ${widget.trip.destinationName}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppTheme.spacingMD),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Message (optional)',
                hintText: 'Introduce yourself...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send Request'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      setState(() => _isSubmitting = true);
      
      try {
        await ref.read(requestActionsNotifierProvider.notifier).createRequest(
          tripId: widget.tripId,
          message: messageController.text.isNotEmpty ? messageController.text : null,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Request sent successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send request: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
    
    messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).valueOrNull;
    final myRequestAsync = ref.watch(myRequestForTripProvider(widget.tripId));

    // If user is the trip creator, don't show request button
    if (currentUser != null && widget.trip.userId == currentUser.id) {
      return const SizedBox.shrink();
    }

    return myRequestAsync.when(
      data: (request) {
        if (request == null) {
          // No existing request - show "Request to Join" button
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _showRequestDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warmCoral,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Request to Join'),
            ),
          );
        }

        // Existing request - show status
        switch (request.status) {
          case RequestStatus.pending:
            return _buildStatusCard(
              context,
              icon: Icons.hourglass_top,
              color: Colors.orange,
              title: 'Request Pending',
              subtitle: 'Waiting for the trip creator to respond',
            );
          
          case RequestStatus.accepted:
            return Column(
              children: [
                _buildStatusCard(
                  context,
                  icon: Icons.check_circle,
                  color: Colors.green,
                  title: 'Request Accepted',
                  subtitle: 'You can now chat with the trip creator',
                ),
                const SizedBox(height: AppTheme.spacingMD),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push('/chat/${request.id}');
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('Open Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warmCoral,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            );
          
          case RequestStatus.rejected:
            return _buildStatusCard(
              context,
              icon: Icons.cancel,
              color: Colors.red,
              title: 'Request Declined',
              subtitle: 'The trip creator declined your request',
            );
          
          case RequestStatus.cancelled:
            return _buildStatusCard(
              context,
              icon: Icons.cancel_outlined,
              color: Colors.grey,
              title: 'Request Cancelled',
              subtitle: 'This request was cancelled',
            );
        }
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacingMD),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _showRequestDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.warmCoral,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Request to Join'),
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
        ),
        subtitle: Text(subtitle),
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
