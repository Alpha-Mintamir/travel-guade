import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/skeleton_loaders.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Not logged in'));
          }
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            child: Column(
              children: [
                const SizedBox(height: AppTheme.spacingLG),
                // Profile photo
                CircleAvatar(
                  radius: 60,
                  backgroundImage: user.profilePhotoUrl != null
                      ? CachedNetworkImageProvider(user.profilePhotoUrl!)
                      : null,
                  child: user.profilePhotoUrl == null
                      ? Text(
                          user.fullName.initials,
                          style: const TextStyle(fontSize: 32),
                        )
                      : null,
                ),
                const SizedBox(height: AppTheme.spacingMD),
                // Name
                Text(
                  user.fullName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppTheme.spacingSM),
                // Email
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                if (user.cityOfResidence != null) ...[
                  const SizedBox(height: AppTheme.spacingSM),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        user.cityOfResidence!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppTheme.spacingLG),
                // Edit profile button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      context.push('/edit-profile');
                    },
                    child: const Text(AppStrings.editProfile),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMD),
                // Trip Requests button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.push('/requests');
                    },
                    icon: const Icon(Icons.mail_outline),
                    label: const Text('Trip Requests'),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLG),
                // Bio section
                if (user.bio != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingMD),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.bio,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: AppTheme.spacingSM),
                          Text(user.bio!),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMD),
                ],
                // Interests section
                if (user.interests != null && user.interests!.isNotEmpty) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingMD),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.interests_outlined, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                AppStrings.interests,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacingSM),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: user.interests!
                                .split(',')
                                .map((interest) => interest.trim())
                                .where((interest) => interest.isNotEmpty)
                                .map((interest) => Chip(
                                      label: Text(interest),
                                      visualDensity: VisualDensity.compact,
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMD),
                ],
                // Logout button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await ref.read(authStateProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/auth/login');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Logout'),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const ProfileSkeleton(),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: AppTheme.spacingMD),
              Text('Error: $error'),
            ],
          ),
        ),
      ),
    );
  }
}
