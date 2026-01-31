import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/trip_request.dart';
import '../../providers/requests_provider.dart';

class RequestsScreen extends ConsumerStatefulWidget {
  const RequestsScreen({super.key});

  @override
  ConsumerState<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends ConsumerState<RequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Requests'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.warmCoral,
          indicatorWeight: 3,
          labelColor: AppColors.warmCoral,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_outlined, size: 18),
                  const SizedBox(width: 8),
                  const Text('Sent'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 18),
                  const SizedBox(width: 8),
                  const Text('Received'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _SentRequestsTab(),
          _ReceivedRequestsTab(),
        ],
      ),
    );
  }
}

class _SentRequestsTab extends ConsumerWidget {
  const _SentRequestsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(sentRequestsNotifierProvider);

    return requestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return _buildEmptyState(
            context,
            icon: Icons.send_outlined,
            title: 'No sent requests',
            subtitle: 'When you request to join trips, they will appear here',
            color: AppColors.deepTeal,
          );
        }

        return RefreshIndicator(
          color: AppColors.warmCoral,
          onRefresh: () => ref.read(sentRequestsNotifierProvider.notifier).refresh(),
          child: ListView.builder(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return _SentRequestCard(request: request);
            },
          ),
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(color: AppColors.warmCoral),
      ),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 48, color: AppColors.error),
            ),
            const SizedBox(height: AppTheme.spacingMD),
            Text('Error: $error'),
            const SizedBox(height: AppTheme.spacingMD),
            ElevatedButton(
              onPressed: () => ref.invalidate(sentRequestsNotifierProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warmCoral,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceivedRequestsTab extends ConsumerWidget {
  const _ReceivedRequestsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(receivedRequestsNotifierProvider);

    return requestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return _buildEmptyState(
            context,
            icon: Icons.inbox_outlined,
            title: 'No received requests',
            subtitle: 'When people request to join your trips, they will appear here',
            color: AppColors.warmCoral,
          );
        }

        return RefreshIndicator(
          color: AppColors.warmCoral,
          onRefresh: () => ref.read(receivedRequestsNotifierProvider.notifier).refresh(),
          child: ListView.builder(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return _ReceivedRequestCard(request: request);
            },
          ),
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(color: AppColors.warmCoral),
      ),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 48, color: AppColors.error),
            ),
            const SizedBox(height: AppTheme.spacingMD),
            Text('Error: $error'),
            const SizedBox(height: AppTheme.spacingMD),
            ElevatedButton(
              onPressed: () => ref.invalidate(receivedRequestsNotifierProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warmCoral,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildEmptyState(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
  required Color color,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.15 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: color,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLG),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSM),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class _SentRequestCard extends StatelessWidget {
  final TripRequest request;

  const _SentRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final trip = request.trip;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMD),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: trip != null ? () => context.push('/trip/${trip.id}') : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Trip creator avatar with accent ring
                    if (trip?.creator != null)
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppColors.deepTeal, AppColors.softTeal],
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: Theme.of(context).cardColor,
                          backgroundImage: trip!.creator.profilePhotoUrl != null
                              ? CachedNetworkImageProvider(trip.creator.profilePhotoUrl!)
                              : null,
                          child: trip.creator.profilePhotoUrl == null
                              ? Text(
                                  trip.creator.fullName.substring(0, 1).toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.deepTeal,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    const SizedBox(width: AppTheme.spacingMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 16, color: AppColors.warmCoral),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  trip?.destinationName ?? 'Unknown Destination',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (trip?.creator != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'By ${trip!.creator.fullName}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    _StatusChip(status: request.status),
                  ],
                ),
                if (request.message != null) ...[
                  const SizedBox(height: AppTheme.spacingSM),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingSM),
                    decoration: BoxDecoration(
                      color: AppColors.softTeal.withOpacity(isDark ? 0.1 : 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.format_quote, size: 16, color: AppColors.deepTeal.withOpacity(0.5)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            request.message!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: isDark ? AppColors.softTeal : AppColors.charcoal,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (request.status == RequestStatus.accepted) ...[
                  const SizedBox(height: AppTheme.spacingMD),
                  _ChatButton(
                    onTap: () => context.push('/chat/${request.id}'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Styled chat button
class _ChatButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ChatButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.warmCoral : AppColors.warmCoralDark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.warmCoral.withOpacity(isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.warmCoral.withOpacity(isDark ? 0.4 : 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline, size: 18, color: textColor),
              const SizedBox(width: 8),
              Text(
                'Open Chat',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceivedRequestCard extends ConsumerStatefulWidget {
  final TripRequest request;

  const _ReceivedRequestCard({required this.request});

  @override
  ConsumerState<_ReceivedRequestCard> createState() => _ReceivedRequestCardState();
}

class _ReceivedRequestCardState extends ConsumerState<_ReceivedRequestCard> {
  bool _isResponding = false;

  Future<void> _respondToRequest(String status) async {
    setState(() => _isResponding = true);
    
    try {
      await ref.read(requestActionsNotifierProvider.notifier).respondToRequest(
        requestId: widget.request.id,
        status: status,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'ACCEPTED' 
                  ? 'Request accepted! You can now chat.' 
                  : 'Request declined.',
            ),
            backgroundColor: status == 'ACCEPTED' ? AppColors.success : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to respond: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResponding = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final requester = widget.request.requester;
    final trip = widget.request.trip;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMD),
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
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Requester avatar with gradient ring
                if (requester != null)
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.warmCoral, AppColors.goldenAmber],
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: Theme.of(context).cardColor,
                      backgroundImage: requester.profilePhotoUrl != null
                          ? CachedNetworkImageProvider(requester.profilePhotoUrl!)
                          : null,
                      child: requester.profilePhotoUrl == null
                          ? Text(
                              requester.fullName.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.warmCoral,
                              ),
                            )
                          : null,
                    ),
                  ),
                const SizedBox(width: AppTheme.spacingMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        requester?.fullName ?? 'Unknown User',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (requester?.cityOfResidence != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              requester!.cityOfResidence!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                _StatusChip(status: widget.request.status),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSM),
            // Trip destination badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.goldenAmber.withOpacity(isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.goldenAmber.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.flight_takeoff, 
                    size: 14, 
                    color: isDark ? AppColors.goldenAmber : AppColors.goldenAmberDark,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    trip?.destinationName ?? "Unknown Trip",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.charcoal, // Always use charcoal for readability
                    ),
                  ),
                ],
              ),
            ),
            if (widget.request.message != null) ...[
              const SizedBox(height: AppTheme.spacingSM),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingSM),
                decoration: BoxDecoration(
                  color: AppColors.softTeal.withOpacity(isDark ? 0.1 : 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.format_quote, size: 16, color: AppColors.deepTeal.withOpacity(0.5)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.request.message!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: isDark ? AppColors.softTeal : AppColors.charcoal,
                            ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (requester?.bio != null && requester!.bio!.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingSM),
              Text(
                requester!.bio!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: AppTheme.spacingMD),
            if (widget.request.status == RequestStatus.pending)
              Row(
                children: [
                  Expanded(
                    child: _DeclineButton(
                      isLoading: _isResponding,
                      onTap: () => _respondToRequest('REJECTED'),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSM),
                  Expanded(
                    child: _AcceptButton(
                      isLoading: _isResponding,
                      onTap: () => _respondToRequest('ACCEPTED'),
                    ),
                  ),
                ],
              )
            else if (widget.request.status == RequestStatus.accepted)
              _ChatButton(
                onTap: () => context.push('/chat/${widget.request.id}'),
              ),
          ],
        ),
      ),
    );
  }
}

/// Styled decline button
class _DeclineButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _DeclineButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.error.withOpacity(0.3),
            ),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.error,
                    ),
                  )
                : Text(
                    'Decline',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Styled accept button
class _AcceptButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _AcceptButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.success, AppColors.ethiopianGreen],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Accept',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final RequestStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor;
    Color textColor;
    IconData icon;
    String label;
    
    switch (status) {
      case RequestStatus.pending:
        bgColor = AppColors.goldenAmber;
        textColor = isDark ? AppColors.goldenAmber : AppColors.goldenAmberDark;
        icon = Icons.hourglass_top;
        label = 'Pending';
        break;
      case RequestStatus.accepted:
        bgColor = AppColors.successLight;
        textColor = isDark ? AppColors.successLight : AppColors.success;
        icon = Icons.check_circle_outline;
        label = 'Accepted';
        break;
      case RequestStatus.rejected:
        bgColor = AppColors.errorLight;
        textColor = AppColors.error;
        icon = Icons.cancel_outlined;
        label = 'Declined';
        break;
      case RequestStatus.cancelled:
        bgColor = AppColors.textSecondary;
        textColor = AppColors.textSecondary;
        icon = Icons.block;
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(isDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: bgColor.withOpacity(isDark ? 0.4 : 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
