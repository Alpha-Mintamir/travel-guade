import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/utils/avatar_utils.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/app_theme.dart';

/// A widget that allows users to pick an avatar from DiceBear styles
class AvatarPicker extends StatefulWidget {
  final String? currentAvatarUrl;
  final String seed;
  final ValueChanged<String> onAvatarSelected;

  const AvatarPicker({
    super.key,
    this.currentAvatarUrl,
    required this.seed,
    required this.onAvatarSelected,
  });

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  late String _currentSeed;
  String? _selectedUrl;

  @override
  void initState() {
    super.initState();
    _currentSeed = widget.seed;
    _selectedUrl = widget.currentAvatarUrl;
  }

  void _regenerateAvatars() {
    setState(() {
      _currentSeed = AvatarUtils.generateRandomSeed();
      _selectedUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final avatarOptions = AvatarUtils.getAllAvatarOptions(_currentSeed);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header with title and shuffle button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMD),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Choose Your Avatar',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: _regenerateAvatars,
                icon: const Icon(Icons.shuffle, size: 18),
                label: const Text('Shuffle'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.deepTeal,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingSM),
        // Avatar grid
        SizedBox(
          height: 320,
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMD),
            scrollDirection: Axis.horizontal,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: avatarOptions.length,
            itemBuilder: (context, index) {
              final option = avatarOptions[index];
              final isSelected = _selectedUrl == option.url;
              
              return _AvatarOption(
                option: option,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedUrl = option.url;
                  });
                  widget.onAvatarSelected(option.url);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AvatarOption extends StatelessWidget {
  final AvatarOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _AvatarOption({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.deepTeal : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.deepTeal.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: option.url,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.softTeal.withOpacity(0.2),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.softTeal.withOpacity(0.2),
                  child: const Icon(Icons.error_outline, color: AppColors.error),
                ),
              ),
              // Style name badge at the bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    '${option.style.emoji} ${option.style.name}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              // Selected checkmark
              if (isSelected)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.deepTeal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A dialog that shows the avatar picker
class AvatarPickerDialog extends StatefulWidget {
  final String? currentAvatarUrl;
  final String seed;

  const AvatarPickerDialog({
    super.key,
    this.currentAvatarUrl,
    required this.seed,
  });

  static Future<String?> show(
    BuildContext context, {
    String? currentAvatarUrl,
    required String seed,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => AvatarPickerDialog(
        currentAvatarUrl: currentAvatarUrl,
        seed: seed,
      ),
    );
  }

  @override
  State<AvatarPickerDialog> createState() => _AvatarPickerDialogState();
}

class _AvatarPickerDialogState extends State<AvatarPickerDialog> {
  String? _selectedUrl;

  @override
  void initState() {
    super.initState();
    _selectedUrl = widget.currentAvatarUrl;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMD),
            // Avatar picker
            AvatarPicker(
              currentAvatarUrl: widget.currentAvatarUrl,
              seed: widget.seed,
              onAvatarSelected: (url) {
                setState(() {
                  _selectedUrl = url;
                });
              },
            ),
            const SizedBox(height: AppTheme.spacingMD),
            // Action buttons
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMD),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMD),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedUrl != null
                          ? () => Navigator.pop(context, _selectedUrl)
                          : null,
                      child: const Text('Select'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
