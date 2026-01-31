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
import '../../../../../shared/models/user.dart';
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
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.location_on,
                            size: 24,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
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
                    
                    // Quick Stats Grid - Dates and People
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.calendar_today,
                            label: 'Dates',
                            value: trip.formattedDateRange,
                            iconColor: AppColors.deepTeal,
                            backgroundColor: AppColors.softTeal,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingSM),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.people,
                            label: 'Looking for',
                            value: '${trip.peopleNeeded} ${trip.peopleNeeded == 1 ? 'person' : 'people'}',
                            iconColor: AppColors.warmCoral,
                            backgroundColor: AppColors.warmCoral,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingMD),
                    
                    // Budget and Travel Style Chips
                    Wrap(
                      spacing: AppTheme.spacingSM,
                      runSpacing: AppTheme.spacingSM,
                      children: [
                        _StyledChip(
                          icon: Icons.attach_money,
                          label: trip.budgetLevel,
                          iconColor: AppColors.goldenAmber,
                          backgroundColor: AppColors.goldenAmber,
                        ),
                        _StyledChip(
                          icon: Icons.explore,
                          label: trip.travelStyle,
                          iconColor: AppColors.deepTeal,
                          backgroundColor: AppColors.softTeal,
                        ),
                      ],
                    ),
                    
                    // Description section
                    if (trip.description != null) ...[
                      const SizedBox(height: AppTheme.spacingLG),
                      _SectionHeader(title: 'About This Trip', accentColor: AppColors.goldenAmber),
                      const SizedBox(height: AppTheme.spacingSM),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppTheme.spacingMD),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).dividerColor.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          trip.description!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: AppTheme.spacingLG),
                    
                    // Creator Section
                    _SectionHeader(title: 'Trip Creator', accentColor: AppColors.deepTeal),
                    const SizedBox(height: AppTheme.spacingSM),
                    _CreatorCard(creator: trip.creator),
                    
                    const SizedBox(height: AppTheme.spacingLG),
                    
                    // Contact Section
                    _SectionHeader(title: 'Get in Touch', accentColor: AppColors.warmCoral),
                    const SizedBox(height: AppTheme.spacingSM),
                    _ContactButtons(
                      instagramUsername: trip.instagramUsername,
                      phoneNumber: trip.phoneNumber,
                      telegramUsername: trip.telegramUsername,
                      onInstagramTap: () => _openInstagram(trip.instagramUsername),
                      onPhoneTap: trip.phoneNumber != null 
                          ? () => _callPhone(trip.phoneNumber!) 
                          : null,
                      onTelegramTap: trip.telegramUsername != null 
                          ? () => _openTelegram(trip.telegramUsername!) 
                          : null,
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

/// Styled stat card for the 2x2 grid layout
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color backgroundColor;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: backgroundColor.withOpacity(isDark ? 0.3 : 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(isDark ? 0.2 : 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? backgroundColor : iconColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSM),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Styled chip for budget and travel style
class _StyledChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color backgroundColor;

  const _StyledChip({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMD,
        vertical: AppTheme.spacingSM,
      ),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(isDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: backgroundColor.withOpacity(isDark ? 0.4 : 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? backgroundColor : iconColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? backgroundColor : iconColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Section header with accent color bar
class _SectionHeader extends StatelessWidget {
  final String title;
  final Color accentColor;

  const _SectionHeader({
    required this.title,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Enhanced creator card with larger avatar and better styling
class _CreatorCard extends StatelessWidget {
  final User creator;

  const _CreatorCard({required this.creator});

  IconData? _getGenderIcon(String? genderShort) {
    switch (genderShort) {
      case 'M':
        return Icons.male;
      case 'F':
        return Icons.female;
      default:
        return null;
    }
  }

  Color _getGenderColor(String? genderShort) {
    switch (genderShort) {
      case 'M':
        return AppColors.deepTeal;
      case 'F':
        return AppColors.warmCoral;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasAge = creator.age != null;
    final hasGender = creator.genderShort != null;
    final genderIcon = _getGenderIcon(creator.genderShort);
    final genderColor = _getGenderColor(creator.genderShort);
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with accent ring
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.warmCoral,
                  AppColors.goldenAmber,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Theme.of(context).cardColor,
              backgroundImage: creator.profilePhotoUrl != null
                  ? CachedNetworkImageProvider(creator.profilePhotoUrl!)
                  : null,
              child: creator.profilePhotoUrl == null
                  ? Text(
                      creator.fullName.substring(0, 1).toUpperCase(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepTeal,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMD),
          // Creator info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        creator.fullName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Age and gender badge
                    if (hasAge || hasGender) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: genderColor.withOpacity(isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: genderColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (hasAge) ...[
                              Text(
                                '${creator.age}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: genderColor,
                                ),
                              ),
                              if (hasGender) const SizedBox(width: 4),
                            ],
                            if (hasGender && genderIcon != null)
                              Icon(
                                genderIcon,
                                size: 16,
                                color: genderColor,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                if (creator.cityOfResidence != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          creator.cityOfResidence!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Contact action buttons - horizontal layout with brand colors
class _ContactButtons extends StatelessWidget {
  final String instagramUsername;
  final String? phoneNumber;
  final String? telegramUsername;
  final VoidCallback onInstagramTap;
  final VoidCallback? onPhoneTap;
  final VoidCallback? onTelegramTap;

  const _ContactButtons({
    required this.instagramUsername,
    this.phoneNumber,
    this.telegramUsername,
    required this.onInstagramTap,
    this.onPhoneTap,
    this.onTelegramTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhone = phoneNumber != null;
    final hasTelegram = telegramUsername != null;
    
    return Column(
      children: [
        // First row - Instagram (always) and Phone (if available)
        Row(
          children: [
            Expanded(
              child: _ContactActionButton(
                icon: Icons.camera_alt,
                label: 'Instagram',
                subtitle: instagramUsername,
                color: AppColors.warmCoral,
                onTap: onInstagramTap,
              ),
            ),
            if (hasPhone) ...[
              const SizedBox(width: AppTheme.spacingSM),
              Expanded(
                child: _ContactActionButton(
                  icon: Icons.phone,
                  label: 'Call',
                  subtitle: phoneNumber!,
                  color: AppColors.deepTeal,
                  onTap: onPhoneTap!,
                ),
              ),
            ],
          ],
        ),
        // Second row - Telegram (if available)
        if (hasTelegram) ...[
          const SizedBox(height: AppTheme.spacingSM),
          _ContactActionButton(
            icon: Icons.send,
            label: 'Telegram',
            subtitle: telegramUsername!,
            color: const Color(0xFF0088CC), // Telegram blue
            onTap: onTelegramTap!,
            fullWidth: true,
          ),
        ],
      ],
    );
  }
}

/// Individual contact action button
class _ContactActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool fullWidth;

  const _ContactActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: fullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMD,
            vertical: AppTheme.spacingSM + 4,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(isDark ? 0.3 : 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(isDark ? 0.25 : 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isDark ? color.withOpacity(0.9) : color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? color.withOpacity(0.9) : color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: color.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
