import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  final String token;
  
  const EmailVerificationScreen({
    super.key,
    required this.token,
  });

  @override
  ConsumerState<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen> {
  bool _isLoading = true;
  bool _verificationSuccess = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _verifyEmail();
  }

  Future<void> _verifyEmail() async {
    try {
      await ref.read(authStateProvider.notifier).verifyEmail(widget.token);
      
      if (mounted) {
        setState(() {
          _verificationSuccess = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/auth/login'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLG),
          child: _isLoading
              ? _buildLoadingView()
              : _verificationSuccess
                  ? _buildSuccessView()
                  : _buildErrorView(),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppTheme.spacingLG),
          Text(
            'Verifying your email...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success icon
        const Icon(
          Icons.verified_outlined,
          size: 80,
          color: Colors.green,
        ),
        const SizedBox(height: AppTheme.spacingLG),
        // Title
        Text(
          'Email Verified!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacingSM),
        // Description
        Text(
          'Your email has been successfully verified. You can now enjoy all features of Travel Buddy.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacingXL),
        // Continue button
        ElevatedButton(
          onPressed: () => context.go('/auth/login'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Continue to Login'),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Error icon
        const Icon(
          Icons.error_outline,
          size: 80,
          color: Colors.red,
        ),
        const SizedBox(height: AppTheme.spacingLG),
        // Title
        Text(
          'Verification Failed',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacingSM),
        // Error description
        Text(
          'The verification link may have expired or is invalid.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
        if (_error != null) ...[
          const SizedBox(height: AppTheme.spacingMD),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _error!,
              style: const TextStyle(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        const SizedBox(height: AppTheme.spacingXL),
        // Retry button
        ElevatedButton(
          onPressed: () {
            setState(() {
              _isLoading = true;
              _error = null;
            });
            _verifyEmail();
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Try Again'),
        ),
        const SizedBox(height: AppTheme.spacingMD),
        // Back to login
        TextButton(
          onPressed: () => context.go('/auth/login'),
          child: const Text('Back to Login'),
        ),
      ],
    );
  }
}
