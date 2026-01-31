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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.editProfile),
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
              // Avatar Section Card
              _EditSectionCard(
                accentColor: AppColors.warmCoral,
                icon: Icons.face_outlined,
                title: 'Profile Photo',
                subtitle: 'Choose an avatar to represent you',
                child: Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _openAvatarPicker,
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [AppColors.warmCoral, AppColors.goldenAmber],
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Theme.of(context).cardColor,
                                backgroundImage: _selectedAvatarUrl != null
                                    ? CachedNetworkImageProvider(_selectedAvatarUrl!)
                                    : null,
                                child: _selectedAvatarUrl == null
                                    ? Icon(Icons.person, size: 50, color: AppColors.deepTeal)
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.warmCoral,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Theme.of(context).cardColor, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.warmCoral.withOpacity(0.3),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMD),
                      TextButton.icon(
                        onPressed: _openAvatarPicker,
                        icon: const Icon(Icons.face, size: 18),
                        label: const Text('Change Avatar'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.warmCoral,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spacingLG),

              // Basic Info Section Card
              _EditSectionCard(
                accentColor: AppColors.deepTeal,
                icon: Icons.person_outline,
                title: 'Basic Information',
                subtitle: 'Your personal details',
                child: Column(
                  children: [
                    // Full Name
                    _StyledFormField(
                      controller: _fullNameController,
                      label: AppStrings.fullName,
                      hint: 'Enter your full name',
                      icon: Icons.badge_outlined,
                      color: AppColors.deepTeal,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTheme.spacingMD),

                    // City of Residence
                    _StyledFormField(
                      controller: _cityController,
                      label: AppStrings.cityOfResidence,
                      hint: 'Where do you live?',
                      icon: Icons.location_on_outlined,
                      color: AppColors.ethiopianGreen,
                    ),
                    const SizedBox(height: AppTheme.spacingMD),

                    // Gender and Date of Birth row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gender selector
                        Expanded(
                          child: _GenderSelector(
                            selectedGender: _selectedGender,
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
                          child: _DateOfBirthPicker(
                            selectedDate: _selectedDateOfBirth,
                            onTap: _selectDateOfBirth,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingLG),

              // About You Section Card
              _EditSectionCard(
                accentColor: AppColors.goldenAmber,
                icon: Icons.info_outline,
                title: 'About You',
                subtitle: 'Tell others about yourself',
                child: Column(
                  children: [
                    // Bio
                    _StyledFormField(
                      controller: _bioController,
                      label: AppStrings.bio,
                      hint: 'Write a short bio about yourself...',
                      icon: Icons.edit_note_outlined,
                      color: AppColors.goldenAmber,
                      maxLines: 3,
                      maxLength: 500,
                    ),
                    const SizedBox(height: AppTheme.spacingMD),

                    // Travel Preferences
                    _StyledFormField(
                      controller: _travelPreferencesController,
                      label: AppStrings.travelPreferences,
                      hint: 'e.g., Adventure, Cultural, Budget-friendly',
                      icon: Icons.flight_outlined,
                      color: AppColors.softTeal,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingLG),

              // Interests Section Card
              _EditSectionCard(
                accentColor: AppColors.softTeal,
                icon: Icons.interests_outlined,
                title: AppStrings.interests,
                subtitle: AppStrings.interestsHint,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Interest chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _suggestedInterests.map((interest) {
                        final isSelected = _interestsController.text.toLowerCase().contains(interest.toLowerCase());
                        return ActionChip(
                          label: Text(
                            interest,
                            style: TextStyle(
                              color: isSelected 
                                  ? Colors.white 
                                  : (isDark ? AppColors.softTeal : AppColors.deepTeal),
                            ),
                          ),
                          onPressed: () {
                            _addInterest(interest);
                            setState(() {});
                          },
                          avatar: Icon(
                            isSelected ? Icons.check : Icons.add,
                            size: 18,
                            color: isSelected 
                                ? Colors.white 
                                : (isDark ? AppColors.softTeal : AppColors.deepTeal),
                          ),
                          backgroundColor: isSelected 
                              ? AppColors.deepTeal 
                              : AppColors.softTeal.withOpacity(isDark ? 0.2 : 0.3),
                          side: BorderSide(
                            color: isSelected 
                                ? AppColors.deepTeal 
                                : AppColors.softTeal.withOpacity(0.5),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppTheme.spacingMD),

                    // Interests text field
                    _StyledFormField(
                      controller: _interestsController,
                      label: 'Your interests',
                      hint: 'Tap chips above or type your own',
                      icon: Icons.interests_outlined,
                      color: AppColors.softTeal,
                      maxLines: 3,
                      maxLength: 1000,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingXL),

              // Save button
              _SaveButton(
                isLoading: _isLoading,
                onPressed: _saveProfile,
              ),

              const SizedBox(height: AppTheme.spacingLG),
            ],
          ),
        ),
      ),
    );
  }
}

/// Edit section card with accent color
class _EditSectionCard extends StatelessWidget {
  final Color accentColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _EditSectionCard({
    required this.accentColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
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
                  height: 40,
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
                    size: 20,
                    color: isDark ? accentColor.withOpacity(0.9) : accentColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
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

/// Styled form field
class _StyledFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final Color color;
  final int maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;

  const _StyledFormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.color,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
  });

  // Get high-contrast icon color
  Color _getIconColor(Color accentColor, bool isDark) {
    if (isDark) return accentColor;
    if (accentColor == AppColors.goldenAmber) return AppColors.goldenAmberDark;
    if (accentColor == AppColors.softTeal) return AppColors.softTealDark;
    if (accentColor == AppColors.warmCoral) return AppColors.warmCoralDark;
    return accentColor;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = _getIconColor(color, isDark);
    
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.charcoal),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary), // Use neutral gray for labels
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: iconColor),
        filled: true,
        fillColor: color.withOpacity(isDark ? 0.08 : 0.05),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        alignLabelWithHint: maxLines > 1,
      ),
      validator: validator,
    );
  }
}

/// Gender selector
class _GenderSelector extends StatelessWidget {
  final Gender? selectedGender;
  final ValueChanged<Gender?> onChanged;

  const _GenderSelector({
    required this.selectedGender,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.gender,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _GenderOption(
                gender: Gender.male,
                icon: Icons.male,
                label: 'M',
                color: AppColors.deepTeal,
                isSelected: selectedGender == Gender.male,
                onTap: () => onChanged(Gender.male),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _GenderOption(
                gender: Gender.female,
                icon: Icons.female,
                label: 'F',
                color: AppColors.warmCoral,
                isSelected: selectedGender == Gender.female,
                onTap: () => onChanged(Gender.female),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Gender option button
class _GenderOption extends StatelessWidget {
  final Gender gender;
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.gender,
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  // Get high-contrast color for text/icons
  Color _getDisplayColor(Color accentColor, bool isDark) {
    if (isDark) return accentColor;
    if (accentColor == AppColors.goldenAmber) return AppColors.goldenAmberDark;
    if (accentColor == AppColors.softTeal) return AppColors.softTealDark;
    if (accentColor == AppColors.warmCoral) return AppColors.warmCoralDark;
    return accentColor;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayColor = _getDisplayColor(color, isDark);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected 
                ? color.withOpacity(isDark ? 0.2 : 0.15) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : AppColors.textSecondary.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon, 
                size: 24, 
                color: isSelected ? displayColor : AppColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.charcoal : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Date of birth picker
class _DateOfBirthPicker extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onTap;

  const _DateOfBirthPicker({
    required this.selectedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasDate = selectedDate != null;
    final iconColor = isDark ? AppColors.goldenAmber : AppColors.goldenAmberDark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.dateOfBirth,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: hasDate 
                    ? AppColors.goldenAmber.withOpacity(isDark ? 0.15 : 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasDate 
                      ? AppColors.goldenAmber 
                      : AppColors.textSecondary.withOpacity(0.3),
                  width: hasDate ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.cake_outlined,
                    size: 20,
                    color: hasDate ? iconColor : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasDate 
                              ? DateFormat('MMM d').format(selectedDate!) 
                              : 'Select',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: hasDate ? FontWeight.w600 : FontWeight.normal,
                            color: hasDate ? AppColors.charcoal : AppColors.textSecondary,
                          ),
                        ),
                        if (hasDate)
                          Text(
                            '${DateTime.now().year - selectedDate!.year}y old',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.goldenAmber : AppColors.goldenAmberDark,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Save button with gradient
class _SaveButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _SaveButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.deepTeal, AppColors.deepTeal.withBlue(100)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepTeal.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.save,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
