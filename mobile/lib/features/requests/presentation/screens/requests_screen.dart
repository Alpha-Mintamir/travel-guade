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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Requests'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Sent'),
            Tab(text: 'Received'),
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
          );
        }

        return RefreshIndicator(
          onRefresh: () => ref.read(sentRequestsNotifierProvider.notifier).refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return _SentRequestCard(request: request);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: AppTheme.spacingMD),
            Text('Error: $error'),
            const SizedBox(height: AppTheme.spacingMD),
            ElevatedButton(
              onPressed: () => ref.invalidate(sentRequestsNotifierProvider),
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
          );
        }

        return RefreshIndicator(
          onRefresh: () => ref.read(receivedRequestsNotifierProvider.notifier).refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return _ReceivedRequestCard(request: request);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: AppTheme.spacingMD),
            Text('Error: $error'),
            const SizedBox(height: AppTheme.spacingMD),
            ElevatedButton(
              onPressed: () => ref.invalidate(receivedRequestsNotifierProvider),
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
}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 64,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        ),
        const SizedBox(height: AppTheme.spacingMD),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: AppTheme.spacingSM),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXL),
          child: Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );
}

class _SentRequestCard extends StatelessWidget {
  final TripRequest request;

  const _SentRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final trip = request.trip;
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMD),
      child: InkWell(
        onTap: trip != null ? () => context.push('/trip/${trip.id}') : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Trip creator avatar
                  if (trip?.creator != null)
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: trip!.creator.profilePhotoUrl != null
                          ? CachedNetworkImageProvider(trip.creator.profilePhotoUrl!)
                          : null,
                      child: trip.creator.profilePhotoUrl == null
                          ? Text(trip.creator.fullName.substring(0, 1).toUpperCase())
                          : null,
                    ),
                  const SizedBox(width: AppTheme.spacingMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip?.destinationName ?? 'Unknown Destination',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if (trip?.creator != null)
                          Text(
                            'By ${trip!.creator.fullName}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                      ],
                    ),
                  ),
                  _StatusChip(status: request.status),
                ],
              ),
              if (request.message != null) ...[
                const SizedBox(height: AppTheme.spacingSM),
                Text(
                  '"${request.message}"',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (request.status == RequestStatus.accepted) ...[
                const SizedBox(height: AppTheme.spacingMD),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/chat/${request.id}'),
                    icon: const Icon(Icons.chat),
                    label: const Text('Open Chat'),
                  ),
                ),
              ],
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
            backgroundColor: status == 'ACCEPTED' ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to respond: $e'),
            backgroundColor: Colors.red,
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
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMD),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Requester avatar
                if (requester != null)
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: requester.profilePhotoUrl != null
                        ? CachedNetworkImageProvider(requester.profilePhotoUrl!)
                        : null,
                    child: requester.profilePhotoUrl == null
                        ? Text(requester.fullName.substring(0, 1).toUpperCase())
                        : null,
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
                      if (requester?.cityOfResidence != null)
                        Text(
                          requester!.cityOfResidence!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                    ],
                  ),
                ),
                _StatusChip(status: widget.request.status),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSM),
            Text(
              'For: ${trip?.destinationName ?? "Unknown Trip"}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            if (widget.request.message != null) ...[
              const SizedBox(height: AppTheme.spacingSM),
              Text(
                '"${widget.request.message}"',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (requester?.bio != null) ...[
              const SizedBox(height: AppTheme.spacingSM),
              Text(
                requester!.bio!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: AppTheme.spacingMD),
            if (widget.request.status == RequestStatus.pending)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isResponding ? null : () => _respondToRequest('REJECTED'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: _isResponding
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMD),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isResponding ? null : () => _respondToRequest('ACCEPTED'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: _isResponding
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Accept'),
                    ),
                  ),
                ],
              )
            else if (widget.request.status == RequestStatus.accepted)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/chat/${widget.request.id}'),
                  icon: const Icon(Icons.chat),
                  label: const Text('Open Chat'),
                ),
              ),
          ],
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
    Color backgroundColor;
    Color textColor;
    String label;
    
    switch (status) {
      case RequestStatus.pending:
        backgroundColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange;
        label = 'Pending';
        break;
      case RequestStatus.accepted:
        backgroundColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green;
        label = 'Accepted';
        break;
      case RequestStatus.rejected:
        backgroundColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red;
        label = 'Declined';
        break;
      case RequestStatus.cancelled:
        backgroundColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey;
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
