import 'package:flutter/material.dart';
import 'theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class HostelPgPage extends StatefulWidget {
  const HostelPgPage({Key? key}) : super(key: key);

  @override
  State<HostelPgPage> createState() => _HostelPgPageState();
}

class _HostelPgPageState extends State<HostelPgPage> {
  String _selectedLocation = 'All Cities';
  String _selectedPriceRange = 'All Prices';
  String _selectedRoomType = 'All Types';
  String _searchQuery = '';

  final List<String> _locations = [
    'All Cities',
    'Downtown, NY',
    'Uptown, NY',
    'Brooklyn, NY',
    'Queens, NY',
  ];

  final List<String> _priceRanges = [
    'All Prices',
    '\$0 - \$500',
    '\$500 - \$1000',
    '\$1000 - \$1500',
    '\$1500 - \$2000',
    '\$2000+',
  ];

  final List<String> _roomTypes = ['All Types', 'Shared', 'Private'];

  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _hostels = [
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=400&q=80',
      'title': 'Sunrise Hostel',
      'price': '\$120',
      'period': '/mo',
      'location': 'Downtown, NY',
      'type': 'Shared',
      'size': '2 Beds',
      'available': 'Available Now',
      'amenities': ['WiFi', 'Laundry', 'Furnished'],
      'rating': '4.7',
      'reviews': '18',
      'verified': true,
      'distance': 'Near Subway',
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=400&q=80',
      'title': 'Sunset PG',
      'price': '\$150',
      'period': '/mo',
      'location': 'Uptown, NY',
      'type': 'Private',
      'size': '1 Bed',
      'available': 'Available Mar 1',
      'amenities': ['AC', 'Kitchen', 'Parking'],
      'rating': '4.9',
      'reviews': '12',
      'verified': true,
      'distance': '5 min to Park',
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=400&q=80',
      'title': 'Moonlight Hostel',
      'price': '\$100',
      'period': '/mo',
      'location': 'Brooklyn, NY',
      'type': 'Shared',
      'size': '4 Beds',
      'available': 'Available Now',
      'amenities': ['WiFi', 'Gym', 'Cafeteria'],
      'rating': '4.5',
      'reviews': '9',
      'verified': false,
      'distance': 'Near Metro',
    },
  ];

  List<Map<String, dynamic>> get _filteredHostels {
    return _hostels.where((hostel) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          hostel['title'].toString().toLowerCase().contains(query) ||
          hostel['location'].toString().toLowerCase().contains(query) ||
          (hostel['amenities'] as List).any(
            (a) => a.toString().toLowerCase().contains(query),
          );
      final matchesLocation =
          _selectedLocation == 'All Cities' ||
          hostel['location'].toString().toLowerCase().contains(
            _selectedLocation.toLowerCase(),
          );
      final matchesType =
          _selectedRoomType == 'All Types' ||
          hostel['type'].toString().toLowerCase() ==
              _selectedRoomType.toLowerCase();
      final matchesPrice =
          _selectedPriceRange == 'All Prices' ||
          _priceInRange(hostel['price'], _selectedPriceRange);
      return matchesSearch && matchesLocation && matchesType && matchesPrice;
    }).toList();
  }

  bool _priceInRange(String priceStr, String range) {
    try {
      final price = int.parse(priceStr.replaceAll(RegExp(r'[^\d]'), ''));
      if (range == '\$0 - \$500') return price <= 500;
      if (range == '\$500 - \$1000') return price > 500 && price <= 1000;
      if (range == '\$1000 - \$1500') return price > 1000 && price <= 1500;
      if (range == '\$1500 - \$2000') return price > 1500 && price <= 2000;
      if (range == '\$2000+') return price > 2000;
    } catch (_) {}
    return true;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor =
        isDark ? const Color(0xFF90CAF9) : const Color(0xFF2D3748);
    final Color accentColor =
        isDark ? const Color(0xFF64B5F6) : const Color(0xFF4299E1);
    final Color cardColor = isDark ? const Color(0xFF23262F) : Colors.white;
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF2D3748);
    final Color textSecondary =
        isDark ? Colors.white70 : const Color(0xFF718096);
    final Color textLight = isDark ? Colors.white38 : const Color(0xFFA0AEC0);
    final Color borderColor = isDark ? Colors.white12 : const Color(0xFFE2E8F0);
    final Color successColor =
        isDark ? const Color(0xFF81C784) : const Color(0xFF48BB78);
    final Color warningColor =
        isDark ? const Color(0xFFFFB74D) : const Color(0xFFED8936);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 2));
          },
          color: BuddyTheme.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(BuddyTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, textPrimary),
                  const SizedBox(height: BuddyTheme.spacingLg),
                  _buildSearchSection(
                    cardColor,
                    textLight,
                    textPrimary,
                    accentColor,
                    borderColor,
                  ),
                  const SizedBox(height: BuddyTheme.spacingMd),
                  _buildQuickStats(
                    cardColor,
                    accentColor,
                    successColor,
                    warningColor,
                    borderColor,
                    textSecondary,
                  ),
                  const SizedBox(height: BuddyTheme.spacingLg),
                  _buildSectionHeader(
                    'Available Hostels / PG',
                    textPrimary,
                    accentColor,
                  ),
                  const SizedBox(height: BuddyTheme.spacingMd),
                  ..._filteredHostels
                      .map(
                        (hostel) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: BuddyTheme.spacingMd,
                          ),
                          child: _buildHostelCard(
                            hostel,
                            cardColor,
                            borderColor,
                            textLight,
                            textPrimary,
                            textSecondary,
                            accentColor,
                            primaryColor,
                            Theme.of(context).scaffoldBackgroundColor,
                            successColor,
                            warningColor,
                          ),
                        ),
                      )
                      .toList(),
                  const SizedBox(height: BuddyTheme.spacingMd),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color labelColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Find Your',
          style: Theme.of(
            context,
          ).textTheme.displaySmall!.copyWith(color: labelColor),
        ),
        Text(
          'Perfect Hostel / PG',
          style: Theme.of(context).textTheme.displayMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: BuddyTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection(
    Color cardColor,
    Color textLight,
    Color textPrimary,
    Color accentColor,
    Color borderColor,
  ) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search hostels, amenities, or locations...',
              hintStyle: TextStyle(
                color: textLight,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(
                Icons.search_outlined,
                color: textLight,
                size: 22,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(18),
            ),
            style: TextStyle(color: textPrimary),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                'Location',
                _selectedLocation,
                _locations,
                (value) {
                  setState(() => _selectedLocation = value);
                },
                cardColor,
                textPrimary,
                borderColor,
              ),
              const SizedBox(width: BuddyTheme.spacingXs),
              _buildFilterChip(
                'Budget',
                _selectedPriceRange,
                _priceRanges,
                (value) {
                  setState(() => _selectedPriceRange = value);
                },
                cardColor,
                textPrimary,
                borderColor,
              ),
              const SizedBox(width: BuddyTheme.spacingXs),
              _buildFilterChip(
                'Room Type',
                _selectedRoomType,
                _roomTypes,
                (value) {
                  setState(() => _selectedRoomType = value);
                },
                cardColor,
                textPrimary,
                borderColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    List<String> options,
    Function(String) onChanged,
    Color cardColor,
    Color labelColor,
    Color borderColor,
  ) {
    final isSelected = value != options.first;
    return GestureDetector(
      onTap:
          () => _showFilterBottomSheet(
            context,
            label,
            options,
            value,
            onChanged,
            cardColor,
            labelColor,
            borderColor,
          ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: BuddyTheme.spacingSm,
          vertical: BuddyTheme.spacingXs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? BuddyTheme.primaryColor : cardColor,
          borderRadius: BorderRadius.circular(BuddyTheme.borderRadiusSm),
          border: Border.all(
            color: isSelected ? BuddyTheme.primaryColor : borderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value == options.first ? label : value,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: isSelected ? BuddyTheme.textLightColor : labelColor,
              ),
            ),
            const SizedBox(width: BuddyTheme.spacingXxs),
            Icon(
              Icons.keyboard_arrow_down,
              size: BuddyTheme.iconSizeSm,
              color: isSelected ? BuddyTheme.textLightColor : labelColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(
    Color cardColor,
    Color accentColor,
    Color successColor,
    Color warningColor,
    Color borderColor,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            '42',
            'Available\nHostels',
            accentColor,
            textSecondary,
          ),
          Container(width: 1, height: 40, color: borderColor),
          _buildStatItem('12', 'New This\nWeek', successColor, textSecondary),
          Container(width: 1, height: 40, color: borderColor),
          _buildStatItem(
            '28',
            'Verified\nListings',
            warningColor,
            textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String number,
    String label,
    Color color,
    Color textSecondary,
  ) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: textSecondary,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    String title,
    Color textPrimary,
    Color accentColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildHostelCard(
    Map<String, dynamic> hostel,
    Color cardColor,
    Color borderColor,
    Color textLight,
    Color textPrimary,
    Color textSecondary,
    Color accentColor,
    Color primaryColor,
    Color backgroundColor,
    Color successColor,
    Color warningColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  imageUrl: hostel['imageUrl'],
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Shimmer.fromColors(
                        baseColor: borderColor,
                        highlightColor: cardColor,
                        child: Container(color: borderColor),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        color: borderColor,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: textLight,
                          size: 48,
                        ),
                      ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (hostel['verified'])
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: successColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${hostel['rating']} (${hostel['reviews']})',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        hostel['available'] == 'Available Now'
                            ? successColor
                            : warningColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    hostel['available'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hostel['title'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: textLight,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  hostel['location'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hostel['distance'],
                            style: TextStyle(
                              fontSize: 13,
                              color: textLight,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: hostel['price'],
                            style: TextStyle(
                              fontSize: 24,
                              color: primaryColor,
                              fontWeight: FontWeight.w800,
                            ),
                            children: [
                              TextSpan(
                                text: hostel['period'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                hostel['type'],
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: textLight.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                hostel['size'],
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      (hostel['amenities'] as List<String>)
                          .map(
                            (amenity) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: borderColor),
                              ),
                              child: Text(
                                amenity,
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'View Details',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
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
    );
  }

  void _showFilterBottomSheet(
    BuildContext context,
    String title,
    List<String> options,
    String currentValue,
    Function(String) onChanged,
    Color cardColor,
    Color labelColor,
    Color borderColor,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: borderColor)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Select $title',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: labelColor,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close_rounded, color: labelColor),
                      ),
                    ],
                  ),
                ),
                ...options.map(
                  (option) => ListTile(
                    title: Text(
                      option,
                      style: TextStyle(
                        color: labelColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing:
                        currentValue == option
                            ? Icon(
                              Icons.check_rounded,
                              color: BuddyTheme.primaryColor,
                            )
                            : null,
                    onTap: () {
                      onChanged(option);
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
              ],
            ),
          ),
    );
  }
}
