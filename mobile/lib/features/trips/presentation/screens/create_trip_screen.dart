import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/services/providers.dart';
import '../../providers/trips_provider.dart';

class CreateTripScreen extends ConsumerStatefulWidget {
  const CreateTripScreen({super.key});

  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instagramController = TextEditingController();
  final _phoneController = TextEditingController();
  final _telegramController = TextEditingController();
  
  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  DateTime _endDate = DateTime.now().add(const Duration(days: 14));
  bool _flexibleDates = false;
  int _peopleNeeded = 1;
  String _budgetLevel = 'MEDIUM';
  String _travelStyle = 'ADVENTURE';
  bool _isLoading = false;
  
  // Destination Photo
  XFile? _selectedDestinationImage;
  String? _uploadedDestinationPhotoUrl;
  bool _isUploadingDestinationPhoto = false;
  
  // User Photo (optional)
  XFile? _selectedUserImage;
  String? _uploadedUserPhotoUrl;
  bool _isUploadingUserPhoto = false;

  final List<String> _budgetLevels = ['BUDGET', 'MEDIUM', 'LUXURY'];
  final List<String> _travelStyles = ['ADVENTURE', 'CULTURAL', 'RELAXATION', 'PHOTOGRAPHY', 'FOOD', 'NATURE'];

  // Suggested Ethiopian tourism destinations
  static const List<String> _suggestedDestinations = [
    'Lalibela',
    'Gondar',
    'Axum',
    'Simien Mountains',
    'Danakil Depression',
    'Omo Valley',
    'Bale Mountains',
    'Harar',
    'Lake Tana',
    'Bahir Dar',
    'Blue Nile Falls',
    'Addis Ababa',
    'Dire Dawa',
    'Awash National Park',
    'Entoto',
    'ላልይበላ',
    'ጎንደር',
    'አክሱም',
    'ሐረር',
  ];

  void _addDestination(String destination) {
    final currentText = _destinationController.text.trim();
    if (currentText.isEmpty) {
      _destinationController.text = destination;
    } else {
      // Replace current text with the selected destination
      _destinationController.text = destination;
    }
    // Move cursor to end
    _destinationController.selection = TextSelection.fromPosition(
      TextPosition(offset: _destinationController.text.length),
    );
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _descriptionController.dispose();
    _instagramController.dispose();
    _phoneController.dispose();
    _telegramController.dispose();
    super.dispose();
  }

  Future<void> _pickDestinationImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        _selectedDestinationImage = image;
        _uploadedDestinationPhotoUrl = null;
      });
      
      // Upload immediately
      await _uploadDestinationPhoto();
    }
  }

  Future<void> _uploadDestinationPhoto() async {
    if (_selectedDestinationImage == null) return;
    
    setState(() => _isUploadingDestinationPhoto = true);
    
    try {
      final bytes = await _selectedDestinationImage!.readAsBytes();
      final filename = _selectedDestinationImage!.name;
      
      final photoUrl = await ref.read(apiServiceProvider).uploadTripPhoto(
        bytes,
        filename,
      );
      setState(() {
        _uploadedDestinationPhotoUrl = photoUrl;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Destination photo uploaded!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingDestinationPhoto = false);
      }
    }
  }

  Future<void> _pickUserImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        _selectedUserImage = image;
        _uploadedUserPhotoUrl = null;
      });
      
      // Upload immediately
      await _uploadUserPhoto();
    }
  }

  Future<void> _uploadUserPhoto() async {
    if (_selectedUserImage == null) return;
    
    setState(() => _isUploadingUserPhoto = true);
    
    try {
      final bytes = await _selectedUserImage!.readAsBytes();
      final filename = _selectedUserImage!.name;
      
      final photoUrl = await ref.read(apiServiceProvider).uploadTripPhoto(
        bytes,
        filename,
      );
      setState(() {
        _uploadedUserPhotoUrl = photoUrl;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your photo uploaded!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingUserPhoto = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final firstDate = isStartDate ? DateTime.now() : _startDate;
    final lastDate = DateTime.now().add(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _createTrip() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDestinationImage == null || _uploadedDestinationPhotoUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a destination photo for your trip')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create trip with optimistic update - returns immediately
      final newTrip = await ref.read(tripsNotifierProvider.notifier).createTrip(
            destinationName: _destinationController.text.trim(),
            startDate: _startDate,
            endDate: _endDate,
            flexibleDates: _flexibleDates,
            description: _descriptionController.text.isEmpty 
                ? null 
                : _descriptionController.text,
            peopleNeeded: _peopleNeeded,
            budgetLevel: _budgetLevel,
            travelStyle: _travelStyle,
            instagramUsername: _instagramController.text.trim(),
            phoneNumber: _phoneController.text.isEmpty 
                ? null 
                : _phoneController.text.trim(),
            telegramUsername: _telegramController.text.isEmpty 
                ? null 
                : _telegramController.text.trim(),
            photoUrl: _uploadedDestinationPhotoUrl,
            userPhotoUrl: _uploadedUserPhotoUrl,
          );
      
      // Also update my trips list optimistically
      ref.read(myTripsNotifierProvider.notifier).addTrip(newTrip);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trip created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating trip: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatBudgetLevel(String level) {
    switch (level) {
      case 'BUDGET':
        return 'Budget Friendly';
      case 'MEDIUM':
        return 'Mid-Range';
      case 'LUXURY':
        return 'Luxury';
      default:
        return level;
    }
  }

  String _formatTravelStyle(String style) {
    return style[0] + style.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Trip'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.all(AppTheme.spacingMD),
          children: [
            // ==================== PHOTOS SECTION ====================
            _FormSectionCard(
              accentColor: AppColors.warmCoral,
              icon: Icons.photo_library_outlined,
              title: 'Trip Photos',
              subtitle: 'Add photos for a swipeable carousel like Instagram',
              children: [
                // Destination Photo (Required)
                _PhotoUploadTile(
                  number: '1',
                  numberColor: AppColors.warmCoral,
                  title: 'Destination Photo',
                  subtitle: 'Show where you\'re going',
                  hint: 'e.g., Lalibela churches, Simien views...',
                  icon: Icons.landscape_outlined,
                  isRequired: true,
                  isUploading: _isUploadingDestinationPhoto,
                  uploadedUrl: _uploadedDestinationPhotoUrl,
                  onTap: _pickDestinationImage,
                ),
                const SizedBox(height: AppTheme.spacingMD),
                
                // User Photo (Optional)
                _PhotoUploadTile(
                  number: '2',
                  numberColor: AppColors.goldenAmber,
                  title: 'Your Photo',
                  subtitle: 'Let travel buddies see who you are',
                  hint: 'Builds trust with potential partners',
                  icon: Icons.person_outline,
                  isRequired: false,
                  isUploading: _isUploadingUserPhoto,
                  uploadedUrl: _uploadedUserPhotoUrl,
                  onTap: _pickUserImage,
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingLG),

            // ==================== DESTINATION SECTION ====================
            _FormSectionCard(
              accentColor: AppColors.deepTeal,
              icon: Icons.location_on_outlined,
              title: 'Destination',
              subtitle: 'Where do you want to explore?',
              children: [
                // Destination suggestion chips
                Text(
                  'Popular Ethiopian Destinations',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSM),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _suggestedDestinations.map((destination) {
                    final isSelected = _destinationController.text == destination;
                    return ActionChip(
                      label: Text(
                        destination,
                        style: TextStyle(
                          color: isSelected 
                              ? Colors.white 
                              : (isDark ? AppColors.softTeal : AppColors.deepTeal),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      onPressed: () {
                        _addDestination(destination);
                        setState(() {});
                      },
                      backgroundColor: isSelected 
                          ? AppColors.deepTeal 
                          : AppColors.softTeal.withOpacity(isDark ? 0.2 : 0.3),
                      side: BorderSide(
                        color: isSelected 
                            ? AppColors.deepTeal 
                            : AppColors.softTeal.withOpacity(0.5),
                      ),
                      avatar: Icon(
                        Icons.place,
                        size: 18,
                        color: isSelected 
                            ? Colors.white 
                            : (isDark ? AppColors.softTeal : AppColors.deepTeal),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppTheme.spacingMD),
                
                TextFormField(
                  controller: _destinationController,
                  decoration: InputDecoration(
                    hintText: 'Or type your own destination...',
                    prefixIcon: Icon(
                      Icons.edit_location_alt_outlined,
                      color: isDark ? AppColors.softTeal : AppColors.deepTeal,
                    ),
                    filled: true,
                    fillColor: isDark 
                        ? AppColors.darkCard 
                        : AppColors.softTeal.withOpacity(0.1),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a destination';
                    }
                    return null;
                  },
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingLG),

            // ==================== DATES SECTION ====================
            _FormSectionCard(
              accentColor: AppColors.goldenAmber,
              icon: Icons.calendar_month_outlined,
              title: 'Travel Dates',
              subtitle: 'When are you planning to go?',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _DatePickerCard(
                        label: 'Start Date',
                        date: _startDate,
                        color: AppColors.goldenAmber,
                        onTap: () => _selectDate(context, true),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.arrow_forward,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Expanded(
                      child: _DatePickerCard(
                        label: 'End Date',
                        date: _endDate,
                        color: AppColors.goldenAmber,
                        onTap: () => _selectDate(context, false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingSM),
                _FlexibleDatesToggle(
                  value: _flexibleDates,
                  onChanged: (value) => setState(() => _flexibleDates = value),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingLG),

            // ==================== TRIP DETAILS SECTION ====================
            _FormSectionCard(
              accentColor: AppColors.softTeal,
              icon: Icons.tune_outlined,
              title: 'Trip Details',
              subtitle: 'Customize your travel preferences',
              children: [
                // People needed
                _FormFieldLabel(
                  label: 'Travel Partners Needed',
                  icon: Icons.people_outline,
                ),
                const SizedBox(height: AppTheme.spacingSM),
                _PeopleCounter(
                  value: _peopleNeeded,
                  onDecrement: _peopleNeeded > 1
                      ? () => setState(() => _peopleNeeded--)
                      : null,
                  onIncrement: _peopleNeeded < 10
                      ? () => setState(() => _peopleNeeded++)
                      : null,
                ),

                const SizedBox(height: AppTheme.spacingLG),

                // Budget level
                _FormFieldLabel(
                  label: 'Budget Level',
                  icon: Icons.account_balance_wallet_outlined,
                ),
                const SizedBox(height: AppTheme.spacingSM),
                _BudgetSelector(
                  selectedBudget: _budgetLevel,
                  onChanged: (value) => setState(() => _budgetLevel = value),
                ),

                const SizedBox(height: AppTheme.spacingLG),

                // Travel style
                _FormFieldLabel(
                  label: 'Travel Style',
                  icon: Icons.explore_outlined,
                ),
                const SizedBox(height: AppTheme.spacingSM),
                _TravelStyleSelector(
                  styles: _travelStyles,
                  selectedStyle: _travelStyle,
                  onChanged: (value) => setState(() => _travelStyle = value),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingLG),

            // ==================== DESCRIPTION SECTION ====================
            _FormSectionCard(
              accentColor: AppColors.ethiopianGreen,
              icon: Icons.description_outlined,
              title: 'Description',
              subtitle: 'Tell others about your trip plans',
              isOptional: true,
              children: [
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'What are you hoping to experience? What kind of travel buddy are you looking for?',
                    filled: true,
                    fillColor: isDark 
                        ? AppColors.darkCard 
                        : AppColors.ethiopianGreen.withOpacity(0.05),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingLG),

            // ==================== CONTACT SECTION ====================
            _FormSectionCard(
              accentColor: AppColors.warmCoral,
              icon: Icons.contact_phone_outlined,
              title: 'Contact Information',
              subtitle: 'How can travel partners reach you?',
              children: [
                // Instagram (Required)
                _ContactField(
                  controller: _instagramController,
                  label: 'Instagram Username',
                  hint: '@yourusername',
                  icon: Icons.camera_alt_outlined,
                  color: AppColors.warmCoral,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Instagram username is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacingMD),

                // Phone (Optional)
                _ContactField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: '+251 9XX XXX XXX',
                  icon: Icons.phone_outlined,
                  color: AppColors.deepTeal,
                  isRequired: false,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppTheme.spacingMD),

                // Telegram (Optional)
                _ContactField(
                  controller: _telegramController,
                  label: 'Telegram Username',
                  hint: '@yourusername',
                  icon: Icons.send_outlined,
                  color: const Color(0xFF0088CC),
                  isRequired: false,
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingXL),

            // ==================== SUBMIT BUTTON ====================
            _CreateTripButton(
              isLoading: _isLoading,
              onPressed: _createTrip,
            ),

            const SizedBox(height: AppTheme.spacingLG),
          ],
        ),
      ),
    );
  }
}

// ==================== CUSTOM WIDGETS ====================

/// Section card with accent color bar and header
class _FormSectionCard extends StatelessWidget {
  final Color accentColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;
  final bool isOptional;

  const _FormSectionCard({
    required this.accentColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
    this.isOptional = false,
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
          // Header with accent bar
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
                      Row(
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isOptional) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.textSecondary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Optional',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ],
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

/// Photo upload tile with styled container
class _PhotoUploadTile extends StatelessWidget {
  final String number;
  final Color numberColor;
  final String title;
  final String subtitle;
  final String hint;
  final IconData icon;
  final bool isRequired;
  final bool isUploading;
  final String? uploadedUrl;
  final VoidCallback onTap;

  const _PhotoUploadTile({
    required this.number,
    required this.numberColor,
    required this.title,
    required this.subtitle,
    required this.hint,
    required this.icon,
    required this.isRequired,
    required this.isUploading,
    this.uploadedUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasPhoto = uploadedUrl != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: numberColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  color: AppColors.warmCoral,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const Spacer(),
            if (hasPhoto)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 14, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text(
                      'Uploaded',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSM),
        GestureDetector(
          onTap: isUploading ? null : onTap,
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasPhoto 
                    ? AppColors.success 
                    : numberColor.withOpacity(0.3),
                width: 2,
                style: hasPhoto ? BorderStyle.solid : BorderStyle.solid,
              ),
              image: hasPhoto
                  ? DecorationImage(
                      image: NetworkImage(uploadedUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              gradient: hasPhoto ? null : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  numberColor.withOpacity(isDark ? 0.1 : 0.05),
                  numberColor.withOpacity(isDark ? 0.05 : 0.02),
                ],
              ),
            ),
            child: isUploading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(numberColor),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Uploading...',
                          style: TextStyle(color: numberColor),
                        ),
                      ],
                    ),
                  )
                : hasPhoto
                    ? Stack(
                        children: [
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: numberColor.withOpacity(isDark ? 0.2 : 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon,
                              size: 32,
                              color: numberColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to add photo',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: numberColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hint,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
          ),
        ),
      ],
    );
  }
}

/// Styled date picker card
class _DatePickerCard extends StatelessWidget {
  final String label;
  final DateTime date;
  final Color color;
  final VoidCallback onTap;

  const _DatePickerCard({
    required this.label,
    required this.date,
    required this.color,
    required this.onTap,
  });

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingMD),
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(isDark ? 0.3 : 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: color,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(date),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? color : null,
                    ),
                  ),
                ],
              ),
              Text(
                '${date.year}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Flexible dates toggle
class _FlexibleDatesToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _FlexibleDatesToggle({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingSM,
            vertical: AppTheme.spacingSM,
          ),
          decoration: BoxDecoration(
            color: value 
                ? AppColors.goldenAmber.withOpacity(isDark ? 0.15 : 0.1) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: value ? Border.all(
              color: AppColors.goldenAmber.withOpacity(0.3),
            ) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                value ? Icons.check_box : Icons.check_box_outline_blank,
                color: value ? AppColors.goldenAmber : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'My dates are flexible',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: value 
                      ? (isDark ? AppColors.goldenAmber : AppColors.charcoal)
                      : AppColors.textSecondary,
                  fontWeight: value ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.swap_horiz,
                size: 16,
                color: value ? AppColors.goldenAmber : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Form field label with icon
class _FormFieldLabel extends StatelessWidget {
  final String label;
  final IconData icon;

  const _FormFieldLabel({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Styled people counter
class _PeopleCounter extends StatelessWidget {
  final int value;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  const _PeopleCounter({
    required this.value,
    this.onDecrement,
    this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        _CounterButton(
          icon: Icons.remove,
          onTap: onDecrement,
          color: AppColors.warmCoral,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMD),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingLG,
            vertical: AppTheme.spacingSM,
          ),
          decoration: BoxDecoration(
            color: AppColors.softTeal.withOpacity(isDark ? 0.15 : 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.softTeal.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.people,
                size: 20,
                color: isDark ? AppColors.softTeal : AppColors.deepTeal,
              ),
              const SizedBox(width: 8),
              Text(
                '$value',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.softTeal : AppColors.deepTeal,
                ),
              ),
            ],
          ),
        ),
        _CounterButton(
          icon: Icons.add,
          onTap: onIncrement,
          color: AppColors.success,
        ),
        const SizedBox(width: AppTheme.spacingMD),
        Text(
          value == 1 ? 'person' : 'people',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Counter button
class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  const _CounterButton({
    required this.icon,
    this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = onTap != null;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isEnabled 
                ? color.withOpacity(isDark ? 0.2 : 0.1) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isEnabled 
                  ? color.withOpacity(0.3) 
                  : AppColors.textSecondary.withOpacity(0.3),
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isEnabled ? color : AppColors.textSecondary.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}

/// Budget level selector
class _BudgetSelector extends StatelessWidget {
  final String selectedBudget;
  final ValueChanged<String> onChanged;

  const _BudgetSelector({
    required this.selectedBudget,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _BudgetOption(
          level: 'BUDGET',
          label: 'Budget',
          icon: Icons.savings_outlined,
          color: AppColors.success,
          isSelected: selectedBudget == 'BUDGET',
          onTap: () => onChanged('BUDGET'),
        ),
        const SizedBox(width: AppTheme.spacingSM),
        _BudgetOption(
          level: 'MEDIUM',
          label: 'Mid-Range',
          icon: Icons.account_balance_wallet_outlined,
          color: AppColors.goldenAmber,
          isSelected: selectedBudget == 'MEDIUM',
          onTap: () => onChanged('MEDIUM'),
        ),
        const SizedBox(width: AppTheme.spacingSM),
        _BudgetOption(
          level: 'LUXURY',
          label: 'Luxury',
          icon: Icons.diamond_outlined,
          color: AppColors.warmCoral,
          isSelected: selectedBudget == 'LUXURY',
          onTap: () => onChanged('LUXURY'),
        ),
      ],
    );
  }
}

/// Individual budget option
class _BudgetOption extends StatelessWidget {
  final String level;
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _BudgetOption({
    required this.level,
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppTheme.spacingMD,
              horizontal: AppTheme.spacingSM,
            ),
            decoration: BoxDecoration(
              color: isSelected 
                  ? color.withOpacity(isDark ? 0.2 : 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? color 
                    : AppColors.textSecondary.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected 
                      ? color 
                      : AppColors.textSecondary,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected 
                        ? (isDark ? color : AppColors.charcoal)
                        : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Travel style selector with colored chips
class _TravelStyleSelector extends StatelessWidget {
  final List<String> styles;
  final String selectedStyle;
  final ValueChanged<String> onChanged;

  const _TravelStyleSelector({
    required this.styles,
    required this.selectedStyle,
    required this.onChanged,
  });

  IconData _getStyleIcon(String style) {
    switch (style) {
      case 'ADVENTURE':
        return Icons.terrain;
      case 'CULTURAL':
        return Icons.museum;
      case 'RELAXATION':
        return Icons.spa;
      case 'PHOTOGRAPHY':
        return Icons.camera_alt;
      case 'FOOD':
        return Icons.restaurant;
      case 'NATURE':
        return Icons.park;
      default:
        return Icons.explore;
    }
  }

  Color _getStyleColor(String style) {
    switch (style) {
      case 'ADVENTURE':
        return AppColors.warmCoral;
      case 'CULTURAL':
        return AppColors.deepTeal;
      case 'RELAXATION':
        return AppColors.softTeal;
      case 'PHOTOGRAPHY':
        return AppColors.goldenAmber;
      case 'FOOD':
        return AppColors.ethiopianRed;
      case 'NATURE':
        return AppColors.ethiopianGreen;
      default:
        return AppColors.deepTeal;
    }
  }

  String _formatStyle(String style) {
    return style[0] + style.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Wrap(
      spacing: AppTheme.spacingSM,
      runSpacing: AppTheme.spacingSM,
      children: styles.map((style) {
        final isSelected = selectedStyle == style;
        final color = _getStyleColor(style);
        
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onChanged(style),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMD,
                vertical: AppTheme.spacingSM,
              ),
              decoration: BoxDecoration(
                color: isSelected 
                    ? color.withOpacity(isDark ? 0.3 : 0.15)
                    : color.withOpacity(isDark ? 0.1 : 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected 
                      ? color 
                      : color.withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStyleIcon(style),
                    size: 16,
                    color: isSelected 
                        ? color 
                        : color.withOpacity(0.7),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatStyle(style),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected 
                          ? (isDark ? color : AppColors.charcoal)
                          : color.withOpacity(0.8),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Contact field with colored icon
class _ContactField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final Color color;
  final bool isRequired;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _ContactField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.color,
    required this.isRequired,
    this.keyboardType,
    this.validator,
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  color: AppColors.warmCoral,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              Text(
                ' (optional)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingSM),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: color.withOpacity(isDark ? 0.1 : 0.05),
            prefixIcon: Icon(icon, color: color.withOpacity(0.7)),
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
          ),
          validator: validator,
        ),
      ],
    );
  }
}

/// Create trip button with gradient
class _CreateTripButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _CreateTripButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                      const Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Create Trip',
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
