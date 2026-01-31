import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/avatar_utils.dart';
import '../../../../shared/widgets/avatar_picker.dart';
import '../../../../shared/models/user.dart';

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
  String? _selectedAvatarUrl;
  Gender? _selectedGender;
  DateTime? _selectedDateOfBirth;

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
    _selectedAvatarUrl = user?.profilePhotoUrl;
    _selectedGender = user?.gender;
    _selectedDateOfBirth = user?.dateOfBirth;
  }

  String? _genderToString(Gender? gender) {
    switch (gender) {
      case Gender.male:
        return 'MALE';
      case Gender.female:
        return 'FEMALE';
      case null:
        return null;
    }
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final minAge = 16;
    final maxAge = 100;
    
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(now.year - maxAge),
      lastDate: DateTime(now.year - minAge, now.month, now.day),
      helpText: 'Select your date of birth',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.deepTeal,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
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

  Future<void> _openAvatarPicker() async {
    final user = ref.read(authStateProvider).valueOrNull;
    final seed = user?.id ?? AvatarUtils.generateRandomSeed();
    
    final selectedUrl = await AvatarPickerDialog.show(
      context,
      currentAvatarUrl: _selectedAvatarUrl,
      seed: seed,
    );
    
    if (selectedUrl != null) {
      setState(() {
        _selectedAvatarUrl = selectedUrl;
      });
    }
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
            gender: _genderToString(_selectedGender),
            dateOfBirth: _selectedDateOfBirth,
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
              // Avatar Section
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _openAvatarPicker,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.softTeal.withOpacity(0.2),
                            backgroundImage: _selectedAvatarUrl != null
                                ? CachedNetworkImageProvider(_selectedAvatarUrl!)
                                : null,
                            child: _selectedAvatarUrl == null
                                ? const Icon(Icons.person, size: 50, color: AppColors.deepTeal)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.deepTeal,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingSM),
                    TextButton.icon(
                      onPressed: _openAvatarPicker,
                      icon: const Icon(Icons.face, size: 18),
                      label: const Text('Change Avatar'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.deepTeal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingLG),
              
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

              // Gender and Date of Birth row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gender dropdown
                  Expanded(
                    child: DropdownButtonFormField<Gender>(
                      value: _selectedGender,
                      decoration: const InputDecoration(
                        labelText: AppStrings.gender,
                        prefixIcon: Icon(Icons.person_outline),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: Gender.male,
                          child: Row(
                            children: const [
                              Icon(Icons.male, size: 20, color: AppColors.deepTeal),
                              SizedBox(width: 8),
                              Text(AppStrings.male),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: Gender.female,
                          child: Row(
                            children: const [
                              Icon(Icons.female, size: 20, color: AppColors.warmCoral),
                              SizedBox(width: 8),
                              Text(AppStrings.female),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMD),
                  // Date of Birth picker
                  Expanded(
                    child: InkWell(
                      onTap: _selectDateOfBirth,
                      borderRadius: BorderRadius.circular(8),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: AppStrings.dateOfBirth,
                          prefixIcon: Icon(Icons.cake_outlined),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _selectedDateOfBirth != null
                                    ? DateFormat('MMM d, y').format(_selectedDateOfBirth!)
                                    : 'Select',
                                style: TextStyle(
                                  color: _selectedDateOfBirth != null
                                      ? Theme.of(context).textTheme.bodyLarge?.color
                                      : AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_selectedDateOfBirth != null)
                              Text(
                                '${DateTime.now().year - _selectedDateOfBirth!.year}y',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.deepTeal,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
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
