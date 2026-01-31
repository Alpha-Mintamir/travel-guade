import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _cityController;
  late TextEditingController _bioController;
  late TextEditingController _travelPreferencesController;
  late TextEditingController _interestsController;

  bool _isLoading = false;

  // Suggested interests for the chips
  static const List<String> _suggestedInterests = [
    'Politics',
    'Personal Development',
    'Football',
    'Films',
    'ንግድ',
    'Travel',
    'Music',
    'Technology',
    'Food',
    'Art',
    'Photography',
    'Reading',
    'Sports',
    'Nature',
    'History',
  ];

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider).valueOrNull;
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _cityController = TextEditingController(text: user?.cityOfResidence ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _travelPreferencesController = TextEditingController(text: user?.travelPreferences ?? '');
    _interestsController = TextEditingController(text: user?.interests ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    _travelPreferencesController.dispose();
    _interestsController.dispose();
    super.dispose();
  }

  void _addInterest(String interest) {
    final currentText = _interestsController.text.trim();
    if (currentText.isEmpty) {
      _interestsController.text = interest;
    } else {
      // Check if interest already exists (case-insensitive)
      final existingInterests = currentText.split(',').map((e) => e.trim().toLowerCase()).toList();
      if (!existingInterests.contains(interest.toLowerCase())) {
        _interestsController.text = '$currentText, $interest';
      }
    }
    // Move cursor to end
    _interestsController.selection = TextSelection.fromPosition(
      TextPosition(offset: _interestsController.text.length),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authStateProvider.notifier).updateProfile(
            fullName: _fullNameController.text.trim(),
            cityOfResidence: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
            bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
            travelPreferences: _travelPreferencesController.text.trim().isEmpty ? null : _travelPreferencesController.text.trim(),
            interests: _interestsController.text.trim().isEmpty ? null : _interestsController.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.editProfile),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(AppStrings.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Full Name
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: AppStrings.fullName,
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacingMD),

              // City of Residence
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: AppStrings.cityOfResidence,
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: AppTheme.spacingMD),

              // Bio
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: AppStrings.bio,
                  prefixIcon: Icon(Icons.info_outline),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                maxLength: 500,
              ),
              const SizedBox(height: AppTheme.spacingMD),

              // Travel Preferences
              TextFormField(
                controller: _travelPreferencesController,
                decoration: const InputDecoration(
                  labelText: AppStrings.travelPreferences,
                  prefixIcon: Icon(Icons.flight_outlined),
                  hintText: 'e.g., Adventure, Cultural, Budget-friendly',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: AppTheme.spacingLG),

              // Interests Section
              Text(
                AppStrings.interests,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppTheme.spacingSM),
              Text(
                AppStrings.interestsHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: AppTheme.spacingSM),

              // Interest chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _suggestedInterests.map((interest) {
                  return ActionChip(
                    label: Text(interest),
                    onPressed: () => _addInterest(interest),
                    avatar: const Icon(Icons.add, size: 18),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppTheme.spacingMD),

              // Interests text field
              TextFormField(
                controller: _interestsController,
                decoration: const InputDecoration(
                  labelText: 'Your interests',
                  prefixIcon: Icon(Icons.interests_outlined),
                  hintText: 'Tap chips above or type your own',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                maxLength: 1000,
              ),
              const SizedBox(height: AppTheme.spacingXL),

              // Save button (alternative to app bar)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(AppStrings.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
