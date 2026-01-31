import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import '../models/trip.dart';

class TripCard extends StatefulWidget {
  final Trip trip;
  final VoidCallback onTap;

  const TripCard({
    super.key,
    required this.trip,
    required this.onTap,
  });

  @override
  State<TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<TripCard> {
  int _currentPage = 0;

  // Get list of available photo URLs
  List<String> get _photoUrls {
    final urls = <String>[];
    if (widget.trip.photoUrl != null && widget.trip.photoUrl!.isNotEmpty) {
      urls.add(widget.trip.photoUrl!);
    }
    if (widget.trip.userPhotoUrl != null && widget.trip.userPhotoUrl!.isNotEmpty) {
      urls.add(widget.trip.userPhotoUrl!);
    }
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photoUrls = _photoUrls;
    final hasMultiplePhotos = photoUrls.length > 1;
    
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMD),
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip Photo Carousel with Hero animation - Instagram-style
            Hero(
              tag: 'trip-image-${widget.trip.id}',
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 4 / 5, // Instagram-style portrait aspect ratio
                    child: photoUrls.isNotEmpty
                        ? hasMultiplePhotos
                            ? PageView.builder(
                                itemCount: photoUrls.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentPage = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  return _buildImage(photoUrls[index]);
                                },
                              )
                            : _buildImage(photoUrls.first)
                        : Container(
                            color: AppColors.softTeal,
                            child: const Center(
                              child: Icon(Icons.photo, size: 48, color: Colors.white54),
                            ),
                          ),
                  ),
                  // Page indicator dots (only show if multiple photos)
                  if (hasMultiplePhotos)
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          photoUrls.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _currentPage == index ? 8 : 6,
                            height: _currentPage == index ? 8 : 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Photo count indicator (top right, like Instagram)
                  if (hasMultiplePhotos)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_currentPage + 1}/${photoUrls.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  // Instagram badge (bottom right on single photo, or top left on multiple)
                  Positioned(
                    top: hasMultiplePhotos ? null : 8,
                    bottom: hasMultiplePhotos ? 40 : null,
                    right: hasMultiplePhotos ? null : 8,
                    left: hasMultiplePhotos ? 12 : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.camera_alt_outlined,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.trip.instagramUsername,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Destination name
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.trip.destinationName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Date range
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        widget.trip.formattedDateRange,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Creator info with age and gender
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: widget.trip.creator.profilePhotoUrl != null
                            ? CachedNetworkImageProvider(widget.trip.creator.profilePhotoUrl!)
                            : null,
                        child: widget.trip.creator.profilePhotoUrl == null
                            ? Text(widget.trip.creator.fullName.initials)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.trip.creator.fullName,
                                style: theme.textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Age and gender badges
                            if (widget.trip.creator.age != null || widget.trip.creator.genderShort != null) ...[
                              const SizedBox(width: 6),
                              _CreatorInfoBadge(
                                age: widget.trip.creator.age,
                                genderShort: widget.trip.creator.genderShort,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.softTeal,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${widget.trip.peopleNeeded} needed',
                          style: const TextStyle(
                            color: AppColors.deepTeal,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
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

  Widget _buildImage(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      placeholder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(color: Colors.white),
      ),
      errorWidget: (_, __, ___) => Container(
        color: AppColors.softTeal,
        child: const Icon(Icons.image_not_supported, size: 48),
      ),
    );
  }
}

/// Badge showing age and gender in a compact, stylish way
class _CreatorInfoBadge extends StatelessWidget {
  final int? age;
  final String? genderShort;

  const _CreatorInfoBadge({
    this.age,
    this.genderShort,
  });

  IconData? get _genderIcon {
    switch (genderShort) {
      case 'M':
        return Icons.male;
      case 'F':
        return Icons.female;
      default:
        return null;
    }
  }

  Color get _genderColor {
    switch (genderShort) {
      case 'M':
        return AppColors.deepTeal;
      case 'F':
        return AppColors.warmCoral;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAge = age != null;
    final hasGender = genderShort != null && _genderIcon != null;

    if (!hasAge && !hasGender) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _genderColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _genderColor.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasAge) ...[
            Text(
              '$age',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _genderColor,
              ),
            ),
          ],
          if (hasAge && hasGender)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                '•',
                style: TextStyle(
                  fontSize: 8,
                  color: _genderColor.withOpacity(0.5),
                ),
              ),
            ),
          if (hasGender)
            Icon(
              _genderIcon,
              size: 14,
              color: _genderColor,
            ),
        ],
      ),
    );
  }
}
