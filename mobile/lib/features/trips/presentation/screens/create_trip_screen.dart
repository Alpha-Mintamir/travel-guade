import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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
            // Photo Section Header
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMD),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppTheme.spacingSM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trip Photos',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Add photos to show in a swipeable carousel like Instagram',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingMD),

            // 1. Destination Photo (Required)
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSM),
                Text(
                  'Destination Photo *',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingXS),
            Text(
              'Show where you\'re going - this will be the first photo people see',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppTheme.spacingSM),
            GestureDetector(
              onTap: _isUploadingDestinationPhoto ? null : _pickDestinationImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _uploadedDestinationPhotoUrl != null 
                        ? Colors.green 
                        : Theme.of(context).colorScheme.outline,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  image: _uploadedDestinationPhotoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(_uploadedDestinationPhotoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _isUploadingDestinationPhoto
                    ? const Center(child: CircularProgressIndicator())
                    : _uploadedDestinationPhotoUrl == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.landscape_outlined,
                                size: 48,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: AppTheme.spacingSM),
                              Text(
                                'Tap to add destination photo',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'e.g., Lalibela churches, Simien views...',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                            ],
                          )
                        : Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
              ),
            ),

            const SizedBox(height: AppTheme.spacingLG),

            // 2. User Photo (Optional)
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('2', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSM),
                Text(
                  'Your Photo (Optional)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingXS),
            Text(
              'Show yourself so travel buddies know who they\'ll be traveling with',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppTheme.spacingSM),
            GestureDetector(
              onTap: _isUploadingUserPhoto ? null : _pickUserImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _uploadedUserPhotoUrl != null 
                        ? Colors.green 
                        : Theme.of(context).colorScheme.outline,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  image: _uploadedUserPhotoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(_uploadedUserPhotoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _isUploadingUserPhoto
                    ? const Center(child: CircularProgressIndicator())
                    : _uploadedUserPhotoUrl == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 48,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(height: AppTheme.spacingSM),
                              Text(
                                'Tap to add your photo',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Builds trust with potential travel buddies',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                            ],
                          )
                        : Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
              ),
            ),

            const SizedBox(height: AppTheme.spacingLG),

            // Destination text field (free text)
            Text(
              'Where do you want to go? *',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingXS),
            Text(
              'Tap a suggestion or type your own destination',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppTheme.spacingSM),
            
            // Destination suggestion chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _suggestedDestinations.map((destination) {
                return ActionChip(
                  label: Text(destination),
                  onPressed: () => _addDestination(destination),
                  avatar: const Icon(Icons.place, size: 18),
                );
              }).toList(),
            ),
            const SizedBox(height: AppTheme.spacingSM),
            
            TextFormField(
              controller: _destinationController,
              decoration: const InputDecoration(
                hintText: 'e.g., Lalibela, Gondar, Simien Mountains...',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a destination';
                }
                return null;
              },
            ),

            const SizedBox(height: AppTheme.spacingLG),

            // Date selection
            Text(
              'When are you traveling? *',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingSM),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(_formatDate(_startDate)),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMD),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'End Date',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(_formatDate(_endDate)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSM),
            CheckboxListTile(
              value: _flexibleDates,
              onChanged: (value) => setState(() => _flexibleDates = value ?? false),
              title: const Text('My dates are flexible'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),

            const SizedBox(height: AppTheme.spacingLG),

            // People needed
            Text(
              'How many travel partners do you need?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingSM),
            Row(
              children: [
                IconButton(
                  onPressed: _peopleNeeded > 1
                      ? () => setState(() => _peopleNeeded--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMD,
                    vertical: AppTheme.spacingSM,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_peopleNeeded',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: _peopleNeeded < 10
                      ? () => setState(() => _peopleNeeded++)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingLG),

            // Budget level
            Text(
              'What\'s your budget level?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingSM),
            SegmentedButton<String>(
              segments: _budgetLevels.map((level) {
                return ButtonSegment(
                  value: level,
                  label: Text(_formatBudgetLevel(level)),
                  icon: Icon(
                    level == 'BUDGET'
                        ? Icons.savings_outlined
                        : level == 'MEDIUM'
                            ? Icons.account_balance_wallet_outlined
                            : Icons.diamond_outlined,
                  ),
                );
              }).toList(),
              selected: {_budgetLevel},
              onSelectionChanged: (Set<String> selection) {
                setState(() => _budgetLevel = selection.first);
              },
            ),

            const SizedBox(height: AppTheme.spacingLG),

            // Travel style
            Text(
              'What\'s your travel style?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingSM),
            Wrap(
              spacing: AppTheme.spacingSM,
              runSpacing: AppTheme.spacingSM,
              children: _travelStyles.map((style) {
                final isSelected = _travelStyle == style;
                return ChoiceChip(
                  label: Text(_formatTravelStyle(style)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _travelStyle = style);
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: AppTheme.spacingLG),

            // Description
            Text(
              'Describe your trip (optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingSM),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Tell potential travel partners about your plans, interests, and what you\'re looking for...',
              ),
            ),

            const SizedBox(height: AppTheme.spacingLG),

            // Contact Information Section
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMD),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.contact_phone_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: AppTheme.spacingSM),
                      Text(
                        'Contact Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    'How can potential travel partners reach you?',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMD),

                  // Instagram (Required)
                  TextFormField(
                    controller: _instagramController,
                    decoration: const InputDecoration(
                      labelText: 'Instagram Username *',
                      hintText: '@yourusername',
                      prefixIcon: Icon(Icons.camera_alt_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Instagram username is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingMD),

                  // Phone (Optional)
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number (optional)',
                      hintText: '+251 9XX XXX XXX',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMD),

                  // Telegram (Optional)
                  TextFormField(
                    controller: _telegramController,
                    decoration: const InputDecoration(
                      labelText: 'Telegram Username (optional)',
                      hintText: '@yourusername',
                      prefixIcon: Icon(Icons.send_outlined),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingXL),

            // Submit button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createTrip,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Trip'),
              ),
            ),

            const SizedBox(height: AppTheme.spacingLG),
          ],
        ),
      ),
    );
  }
}
