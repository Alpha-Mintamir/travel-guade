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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Not logged in'));
          }
          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Modern header with gradient
              SliverAppBar(
                expandedHeight: 280,
                floating: false,
                pinned: true,
                backgroundColor: isDark ? AppColors.darkSurface : AppColors.deepTeal,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [AppColors.darkSurface, AppColors.darkCard]
                            : [AppColors.deepTeal, AppColors.deepTeal.withBlue(100)],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          // Profile photo with ring
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.warmCoral,
                                  AppColors.goldenAmber,
                                ],
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 56,
                              backgroundColor: isDark ? AppColors.darkCard : Colors.white,
                              backgroundImage: user.profilePhotoUrl != null
                                  ? CachedNetworkImageProvider(user.profilePhotoUrl!)
                                  : null,
                              child: user.profilePhotoUrl == null
                                  ? Text(
                                      user.fullName.initials,
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.deepTeal,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingMD),
                          // Name
                          Text(
                            user.fullName,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                          if (user.email != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              user.email!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.white),
                    onPressed: () {
                      // TODO: Navigate to settings
                    },
                  ),
                ],
              ),
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMD),
                  child: Column(
                    children: [
                      // Quick info badges
                      if (user.age != null || user.genderDisplay != null || user.cityOfResidence != null)
                        _QuickInfoSection(
                          age: user.age,
                          genderDisplay: user.genderDisplay,
                          city: user.cityOfResidence,
                        ),
                      
                      const SizedBox(height: AppTheme.spacingMD),
                      
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.edit_outlined,
                              label: 'Edit Profile',
                              color: AppColors.deepTeal,
                              onTap: () => context.push('/edit-profile'),
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingSM),
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.mail_outline,
                              label: 'Requests',
                              color: AppColors.warmCoral,
                              onTap: () => context.push('/requests'),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppTheme.spacingLG),
                      
                      // Bio section
                      if (user.bio != null && user.bio!.isNotEmpty)
                        _ProfileSectionCard(
                          accentColor: AppColors.goldenAmber,
                          icon: Icons.info_outline,
                          title: AppStrings.bio,
                          child: Text(
                            user.bio!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.5,
                            ),
                          ),
                        ),
                      
                      if (user.bio != null && user.bio!.isNotEmpty)
                        const SizedBox(height: AppTheme.spacingMD),
                      
                      // Interests section
                      if (user.interests != null && user.interests!.isNotEmpty)
                        _ProfileSectionCard(
                          accentColor: AppColors.softTeal,
                          icon: Icons.interests_outlined,
                          title: AppStrings.interests,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: user.interests!
                                .split(',')
                                .map((interest) => interest.trim())
                                .where((interest) => interest.isNotEmpty)
                                .map((interest) => _InterestChip(label: interest))
                                .toList(),
                          ),
                        ),
                      
                      if (user.interests != null && user.interests!.isNotEmpty)
                        const SizedBox(height: AppTheme.spacingMD),
                      
                      // Travel preferences
                      if (user.travelPreferences != null && user.travelPreferences!.isNotEmpty)
                        _ProfileSectionCard(
                          accentColor: AppColors.ethiopianGreen,
                          icon: Icons.flight_outlined,
                          title: AppStrings.travelPreferences,
                          child: Text(
                            user.travelPreferences!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.5,
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: AppTheme.spacingXL),
                      
                      // Logout button
                      _LogoutButton(
                        onPressed: () async {
                          await ref.read(authStateProvider.notifier).logout();
                          if (context.mounted) {
                            context.go('/auth/login');
                          }
                        },
                      ),
                      
                      const SizedBox(height: AppTheme.spacingLG),
                    ],
                  ),
                ),
              ),
            ],
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

/// Quick info badges section
class _QuickInfoSection extends StatelessWidget {
  final int? age;
  final String? genderDisplay;
  final String? city;

  const _QuickInfoSection({this.age, this.genderDisplay, this.city});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        if (age != null)
          _InfoChip(
            icon: Icons.cake_outlined,
            label: '$age years old',
            color: AppColors.goldenAmber,
          ),
        if (genderDisplay != null)
          _InfoChip(
            icon: genderDisplay == 'Male' ? Icons.male : Icons.female,
            label: genderDisplay!,
            color: genderDisplay == 'Male' ? AppColors.deepTeal : AppColors.warmCoral,
          ),
        if (city != null)
          _InfoChip(
            icon: Icons.location_on_outlined,
            label: city!,
            color: AppColors.ethiopianGreen,
          ),
      ],
    );
  }
}

/// Info chip widget
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  // Get high-contrast text color for the accent color
  Color _getTextColor(Color accentColor, bool isDark) {
    if (isDark) return accentColor; // In dark mode, accent colors are visible
    // In light mode, use dark variants for text
    if (accentColor == AppColors.goldenAmber) return AppColors.goldenAmberDark;
    if (accentColor == AppColors.softTeal) return AppColors.softTealDark;
    if (accentColor == AppColors.warmCoral) return AppColors.warmCoralDark;
    return accentColor;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = _getTextColor(color, isDark);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.3 : 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isDark ? color : textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.charcoal, // Always use charcoal for text readability
            ),
          ),
        ],
      ),
    );
  }
}

/// Action button widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  // Get high-contrast text color for the accent color
  Color _getTextColor(Color accentColor, bool isDark) {
    if (isDark) return accentColor;
    if (accentColor == AppColors.goldenAmber) return AppColors.goldenAmberDark;
    if (accentColor == AppColors.softTeal) return AppColors.softTealDark;
    if (accentColor == AppColors.warmCoral) return AppColors.warmCoralDark;
    return accentColor;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = _getTextColor(color, isDark);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMD),
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(isDark ? 0.3 : 0.25),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: textColor),
              const SizedBox(width: 8),
              Text(
                label,
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

/// Profile section card with accent color
class _ProfileSectionCard extends StatelessWidget {
  final Color accentColor;
  final IconData icon;
  final String title;
  final Widget child;

  const _ProfileSectionCard({
    required this.accentColor,
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(isDark ? 0.1 : 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(isDark ? 0.2 : 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isDark ? accentColor.withOpacity(0.9) : accentColor,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Interest chip with modern styling
class _InterestChip extends StatelessWidget {
  final String label;

  const _InterestChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.softTeal.withOpacity(isDark ? 0.2 : 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.softTeal.withOpacity(isDark ? 0.4 : 0.5),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.softTeal : AppColors.deepTeal,
        ),
      ),
    );
  }
}

/// Styled logout button
class _LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _LogoutButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMD),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.error.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, size: 20, color: AppColors.error),
              const SizedBox(width: 8),
              Text(
                'Logout',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
