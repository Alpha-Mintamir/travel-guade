import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/models/user.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 3;

  // Form keys for each step
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  Gender? _selectedGender;
  DateTime? _selectedDateOfBirth;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
      initialDate:
          _selectedDateOfBirth ?? DateTime(now.year - 25, now.month, now.day),
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

  void _nextStep() {
    // Validate current step
    if (_currentStep == 0) {
      if (!_step1FormKey.currentState!.validate()) return;
    } else if (_currentStep == 1) {
      if (!_step2FormKey.currentState!.validate()) return;
    }

    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.pop();
    }
  }

  Future<void> _handleRegister() async {
    await ref.read(authStateProvider.notifier).register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
          gender: _genderToString(_selectedGender),
          dateOfBirth: _selectedDateOfBirth,
        );

    if (mounted && ref.read(authStateProvider).valueOrNull != null) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar with back button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingSM,
                vertical: AppTheme.spacingSM,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: isLoading ? null : _previousStep,
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  const Spacer(),
                  if (_currentStep == _totalSteps - 1)
                    TextButton(
                      onPressed: isLoading ? null : _handleRegister,
                      child: Text(
                        'Skip',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                ],
              ),
            ),

            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLG),
              child: _StepProgressIndicator(
                currentStep: _currentStep,
                totalSteps: _totalSteps,
              ),
            ),

            const SizedBox(height: AppTheme.spacingMD),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Step 1: Basic Info
                  _Step1BasicInfo(
                    formKey: _step1FormKey,
                    nameController: _nameController,
                    emailController: _emailController,
                    isLoading: isLoading,
                  ),

                  // Step 2: Password
                  _Step2Password(
                    formKey: _step2FormKey,
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                    obscurePassword: _obscurePassword,
                    obscureConfirmPassword: _obscureConfirmPassword,
                    onTogglePassword: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    onToggleConfirmPassword: () => setState(
                        () => _obscureConfirmPassword = !_obscureConfirmPassword),
                    isLoading: isLoading,
                  ),

                  // Step 3: Personal Details (Optional)
                  _Step3PersonalDetails(
                    selectedGender: _selectedGender,
                    selectedDateOfBirth: _selectedDateOfBirth,
                    onGenderChanged: (gender) =>
                        setState(() => _selectedGender = gender),
                    onSelectDateOfBirth: _selectDateOfBirth,
                    isLoading: isLoading,
                  ),
                ],
              ),
            ),

            // Error message
            if (authState.hasError)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLG),
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMD),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authState.error.toString(),
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Bottom navigation
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLG),
              child: Column(
                children: [
                  // Next/Register button
                  _ActionButton(
                    label: _currentStep == _totalSteps - 1
                        ? 'Create Account'
                        : 'Continue',
                    icon: _currentStep == _totalSteps - 1
                        ? Icons.check_circle_outline
                        : Icons.arrow_forward,
                    isLoading: isLoading,
                    onPressed: _currentStep == _totalSteps - 1
                        ? _handleRegister
                        : _nextStep,
                  ),

                  const SizedBox(height: AppTheme.spacingMD),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.alreadyHaveAccount,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      TextButton(
                        onPressed: isLoading ? null : () => context.pop(),
                        child: Text(
                          AppStrings.login,
                          style: TextStyle(
                            color: AppColors.warmCoral,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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

// ==================== STEP PROGRESS INDICATOR ====================

class _StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepProgressIndicator({
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isCompleted = index < currentStep;
        final isCurrent = index == currentStep;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 4,
                  decoration: BoxDecoration(
                    color: isCompleted || isCurrent
                        ? AppColors.warmCoral
                        : AppColors.textSecondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (index < totalSteps - 1) const SizedBox(width: 8),
            ],
          ),
        );
      }),
    );
  }
}

// ==================== STEP 1: BASIC INFO ====================

class _Step1BasicInfo extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final bool isLoading;

  const _Step1BasicInfo({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLG),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppTheme.spacingLG),

            // Step header
            _StepHeader(
              step: 1,
              title: "Let's get to know you",
              subtitle: 'Start with your basic information',
              icon: Icons.person_outline,
              color: AppColors.warmCoral,
            ),

            const SizedBox(height: AppTheme.spacingXL),

            // Name field
            _StyledTextField(
              controller: nameController,
              label: 'Full Name',
              hint: 'Enter your full name',
              icon: Icons.badge_outlined,
              color: AppColors.deepTeal,
              validator: (value) => Validators.required(value, 'Full name'),
              enabled: !isLoading,
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: AppTheme.spacingLG),

            // Email field
            _StyledTextField(
              controller: emailController,
              label: 'Email Address',
              hint: 'your@email.com',
              icon: Icons.email_outlined,
              color: AppColors.goldenAmber,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
              enabled: !isLoading,
            ),

            const SizedBox(height: AppTheme.spacingLG),

            // Info tip
            _InfoTip(
              icon: Icons.privacy_tip_outlined,
              text: 'Your email will be used to sign in and recover your account',
              color: AppColors.softTeal,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== STEP 2: PASSWORD ====================

class _Step2Password extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final bool isLoading;

  const _Step2Password({
    required this.formKey,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLG),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppTheme.spacingLG),

            // Step header
            _StepHeader(
              step: 2,
              title: 'Secure your account',
              subtitle: 'Create a strong password',
              icon: Icons.lock_outline,
              color: AppColors.deepTeal,
            ),

            const SizedBox(height: AppTheme.spacingXL),

            // Password field
            _StyledTextField(
              controller: passwordController,
              label: 'Password',
              hint: 'Create a password',
              icon: Icons.lock_outline,
              color: AppColors.deepTeal,
              obscureText: obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: onTogglePassword,
              ),
              validator: Validators.password,
              enabled: !isLoading,
            ),

            const SizedBox(height: AppTheme.spacingLG),

            // Confirm password field
            _StyledTextField(
              controller: confirmPasswordController,
              label: 'Confirm Password',
              hint: 'Re-enter your password',
              icon: Icons.lock_outline,
              color: AppColors.goldenAmber,
              obscureText: obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: onToggleConfirmPassword,
              ),
              validator: (value) =>
                  Validators.confirmPassword(value, passwordController.text),
              enabled: !isLoading,
            ),

            const SizedBox(height: AppTheme.spacingLG),

            // Password requirements
            _PasswordRequirements(password: passwordController.text),
          ],
        ),
      ),
    );
  }
}

// ==================== STEP 3: PERSONAL DETAILS ====================

class _Step3PersonalDetails extends StatelessWidget {
  final Gender? selectedGender;
  final DateTime? selectedDateOfBirth;
  final ValueChanged<Gender?> onGenderChanged;
  final VoidCallback onSelectDateOfBirth;
  final bool isLoading;

  const _Step3PersonalDetails({
    required this.selectedGender,
    required this.selectedDateOfBirth,
    required this.onGenderChanged,
    required this.onSelectDateOfBirth,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppTheme.spacingLG),

          // Step header
          _StepHeader(
            step: 3,
            title: 'Almost there!',
            subtitle: 'A bit more about you (optional)',
            icon: Icons.celebration_outlined,
            color: AppColors.goldenAmber,
            isOptional: true,
          ),

          const SizedBox(height: AppTheme.spacingXL),

          // Gender selection
          Text(
            'Gender',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppTheme.spacingSM),
          Row(
            children: [
              Expanded(
                child: _GenderOption(
                  gender: Gender.male,
                  label: 'Male',
                  icon: Icons.male,
                  color: AppColors.deepTeal,
                  isSelected: selectedGender == Gender.male,
                  onTap: isLoading ? null : () => onGenderChanged(Gender.male),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMD),
              Expanded(
                child: _GenderOption(
                  gender: Gender.female,
                  label: 'Female',
                  icon: Icons.female,
                  color: AppColors.warmCoral,
                  isSelected: selectedGender == Gender.female,
                  onTap: isLoading ? null : () => onGenderChanged(Gender.female),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingLG),

          // Date of birth
          Text(
            'Date of Birth',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppTheme.spacingSM),
          _DateOfBirthPicker(
            selectedDate: selectedDateOfBirth,
            onTap: isLoading ? null : onSelectDateOfBirth,
          ),

          const SizedBox(height: AppTheme.spacingLG),

          // Info tip
          _InfoTip(
            icon: Icons.info_outline,
            text:
                'This helps us personalize your experience. You can skip this step and add it later.',
            color: AppColors.goldenAmber,
          ),
        ],
      ),
    );
  }
}

// ==================== REUSABLE WIDGETS ====================

/// Step header with icon and title
class _StepHeader extends StatelessWidget {
  final int step;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isOptional;

  const _StepHeader({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.isOptional = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            if (isOptional) ...[
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Optional',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppTheme.spacingMD),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}

/// Styled text field with colored accent
class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final Color color;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;
  final TextCapitalization textCapitalization;

  const _StyledTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.color,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingSM),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          enabled: enabled,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: color.withOpacity(isDark ? 0.08 : 0.05),
            prefixIcon: Icon(icon, color: color.withOpacity(0.7)),
            suffixIcon: suffixIcon,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: color.withOpacity(0.2),
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
          ),
          validator: validator,
        ),
      ],
    );
  }
}

/// Info tip widget
class _InfoTip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoTip({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.1 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? color : AppColors.charcoal,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Password requirements checklist
class _PasswordRequirements extends StatelessWidget {
  final String password;

  const _PasswordRequirements({required this.password});

  @override
  Widget build(BuildContext context) {
    final hasMinLength = password.length >= 6;
    final hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: AppColors.softTeal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password requirements:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          _RequirementItem(
            text: 'At least 6 characters',
            isMet: hasMinLength,
          ),
          _RequirementItem(
            text: 'One uppercase letter',
            isMet: hasUpperCase,
          ),
          _RequirementItem(
            text: 'One number',
            isMet: hasNumber,
          ),
        ],
      ),
    );
  }
}

/// Individual requirement item
class _RequirementItem extends StatelessWidget {
  final String text;
  final bool isMet;

  const _RequirementItem({
    required this.text,
    required this.isMet,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isMet ? AppColors.success : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isMet ? AppColors.success : AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

/// Gender selection option
class _GenderOption extends StatelessWidget {
  final Gender gender;
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const _GenderOption({
    required this.gender,
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppTheme.spacingLG),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withOpacity(isDark ? 0.2 : 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : AppColors.textSecondary.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 40,
                color: isSelected ? color : AppColors.textSecondary,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? (isDark ? color : AppColors.charcoal)
                          : AppColors.textSecondary,
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
  final VoidCallback? onTap;

  const _DateOfBirthPicker({
    this.selectedDate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasDate = selectedDate != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingMD),
          decoration: BoxDecoration(
            color: hasDate
                ? AppColors.goldenAmber.withOpacity(isDark ? 0.15 : 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasDate
                  ? AppColors.goldenAmber
                  : AppColors.textSecondary.withOpacity(0.3),
              width: hasDate ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.goldenAmber.withOpacity(isDark ? 0.2 : 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.cake_outlined,
                  color: AppColors.goldenAmber,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasDate
                          ? DateFormat('MMMM d, yyyy').format(selectedDate!)
                          : 'Select your birthday',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight:
                                hasDate ? FontWeight.w600 : FontWeight.normal,
                            color: hasDate
                                ? (isDark
                                    ? AppColors.goldenAmber
                                    : AppColors.charcoal)
                                : AppColors.textSecondary,
                          ),
                    ),
                    if (hasDate)
                      Text(
                        '${DateTime.now().year - selectedDate!.year} years old',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.goldenAmber,
                            ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color:
                    hasDate ? AppColors.goldenAmber : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Action button with gradient
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
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
          colors: [
            AppColors.warmCoral,
            AppColors.warmCoral.withRed(240),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.warmCoral.withOpacity(0.4),
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
                      Text(
                        label,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        icon,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
