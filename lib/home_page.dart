import 'package:flutter/material.dart';
import 'theme.dart';
import 'profile_page.dart';
import 'need_room_page.dart';
import 'need_flatmate_page.dart';
import 'widgets/action_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

export 'profile_page.dart';
export 'need_room_page.dart';
export 'need_flatmate_page.dart';
import 'Hostelpg_page.dart';
import 'service_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(
        key: const Key('home'),
        onTabChange: _onItemTapped, // Pass the callback here
      ),
      const NeedRoomPage(key: Key('needroom')),
      const NeedFlatmatePage(key: Key('needflatmate')),
      const ProfilePage(key: Key('profile')),
    ];
  }

  void _showActionSheet(BuildContext context) async {
    final result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ActionBottomSheet(),
    );

    if (result != null && mounted) {
      setState(() => _selectedIndex = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final navBarColor =
        isDark
            ? const Color(0xFF23262F) // Custom dark shade for nav bar
            : const Color(0xFFF5F6FA); // Custom light shade for nav bar
    final navBarIconColor =
        isDark ? Colors.white : BuddyTheme.textSecondaryColor;
    final navBarSelectedColor = BuddyTheme.primaryColor;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder:
            (child, animation) =>
                FadeTransition(opacity: animation, child: child),
        child: _pages[_selectedIndex],
      ),
      floatingActionButton:
          _selectedIndex == 0
              ? Container(
                decoration: BuddyTheme.fabShadowDecoration,
                child: FloatingActionButton(
                  onPressed: () => _showActionSheet(context),
                  backgroundColor: BuddyTheme.primaryColor,
                  shape: const CircleBorder(),
                  elevation: BuddyTheme.elevationSm,
                  child: const Icon(
                    Icons.add,
                    size: BuddyTheme.iconSizeMd,
                    color: BuddyTheme.textLightColor,
                  ),
                ),
              )
              : null, // Hide FAB on other pages
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        notchMargin: BuddyTheme.spacingSm,
        elevation: BuddyTheme.elevationMd,
        padding: EdgeInsets.zero,
        color: navBarColor,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black26,
        shape: const CircularNotchedRectangle(),
        clipBehavior: Clip.antiAlias,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: BuddyTheme.spacingSm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                0,
                Icons.home_outlined,
                Icons.home,
                'Home',
                navBarIconColor,
                navBarSelectedColor,
              ),
              _buildNavItem(
                1,
                Icons.hotel_outlined,
                Icons.hotel,
                'Need\nRoom',
                navBarIconColor,
                navBarSelectedColor,
              ),
              if (_selectedIndex == 0) const SizedBox(width: 56),
              _buildNavItem(
                2,
                Icons.group_outlined,
                Icons.group,
                'Need\nFlatmate',
                navBarIconColor,
                navBarSelectedColor,
              ),
              _buildNavItem(
                3,
                Icons.person_outline,
                Icons.person,
                'Profile',
                navBarIconColor,
                navBarSelectedColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
    Color iconColor,
    Color selectedColor,
  ) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? selectedColor : iconColor,
                size: BuddyTheme.iconSizeMd,
              ),
            ],
          ),
          const SizedBox(height: BuddyTheme.spacingXs),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: isSelected ? selectedColor : iconColor,
              fontSize: BuddyTheme.fontSizeXs,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final void Function(int)? onTabChange; // Add this line

  const HomePage({super.key, this.onTabChange}); // Update constructor

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _fetchFeaturedProperties();
    _fetchFeaturedFlatmates();
  }

  Future<void> _fetchFeaturedProperties() async {
    final ref = FirebaseDatabase.instance.ref().child('room_listings');
    final snapshot = await ref.get();
    final List<Map<dynamic, dynamic>> properties = [];
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        final property = Map<String, dynamic>.from(value as Map);
        property['key'] = key;
        properties.add(property);
      });
    }
    setState(() {
      _featuredProperties =
          properties.take(5).toList(); // Show top 5, or filter as needed
      _isLoadingProperties = false;
    });
  }

  Future<void> _fetchFeaturedFlatmates() async {
    final ref = FirebaseDatabase.instance.ref().child('room_requests');
    final snapshot = await ref.get();
    final List<Map<dynamic, dynamic>> flatmates = [];
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        final flatmate = Map<String, dynamic>.from(value as Map);
        flatmate['key'] = key;
        flatmates.add(flatmate);
      });
    }
    setState(() {
      _featuredFlatmates = flatmates.take(5).toList(); // Show top 5
      _isLoadingFlatmates = false;
    });
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    String name = 'User';
    if (user != null) {
      if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
        name = user.displayName!;
      } else if (user.email != null && user.email!.trim().isNotEmpty) {
        name = user.email!.split('@')[0]; // Use email prefix as fallback
      } else if (user.phoneNumber != null &&
          user.phoneNumber!.trim().isNotEmpty) {
        name = user.phoneNumber!;
      }
    }
    if (mounted) {
      setState(() {
        _userName = name;
      });
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 2)); // Simulate refresh
        },
        color: BuddyTheme.primaryColor,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: RangeMaintainingScrollPhysics(),
          ),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(BuddyTheme.spacingMd),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(context),
                  const SizedBox(height: BuddyTheme.spacingLg),

                  // Featured Properties
                  _buildSectionHeader(
                    context,
                    'Featured Properties',
                    () => widget.onTabChange?.call(1),
                  ),
                  const SizedBox(height: BuddyTheme.spacingSm),
                  SizedBox(
                    height: 270,
                    child:
                        _isLoadingProperties
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _featuredProperties.length,
                              separatorBuilder:
                                  (context, index) => const SizedBox(
                                    width: BuddyTheme.spacingSm,
                                  ),
                              itemBuilder: (context, index) {
                                final property = _featuredProperties[index];
                                return _buildPropertyCard(
                                  context,
                                  property as Map<String, dynamic>,
                                );
                              },
                            ),
                  ),
                  const SizedBox(height: BuddyTheme.spacingMd),

                  // Featured Flatmates
                  _buildSectionHeader(
                    context,
                    'Featured Flatmates',
                    () => widget.onTabChange?.call(2),
                  ),
                  const SizedBox(height: BuddyTheme.spacingSm),
                  SizedBox(
                    height: 180,
                    child:
                        _isLoadingFlatmates
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _featuredFlatmates.length,
                              separatorBuilder:
                                  (context, index) => const SizedBox(
                                    width: BuddyTheme.spacingSm,
                                  ),
                              itemBuilder: (context, index) {
                                final flatmate = _featuredFlatmates[index];
                                return _buildFlatmateCard(
                                  context,
                                  imageUrl:
                                      flatmate['photoUrl'] ??
                                      'https://randomuser.me/api/portraits/men/32.jpg',
                                  name: flatmate['name'] ?? 'No Name',
                                  age: flatmate['age']?.toString() ?? '',
                                  profession:
                                      flatmate['occupation'] ??
                                      flatmate['about'] ??
                                      '',
                                );
                              },
                            ),
                  ),

                  const SizedBox(height: BuddyTheme.spacingMd),

                  // Hostels/PG Section
                  _buildSectionHeader(
                    context,
                    'Hostels / PG',
                    () => Navigator.pushNamed(context, '/hostelpg'),
                  ),
                  const SizedBox(height: BuddyTheme.spacingSm),
                  SizedBox(
                    height: 270,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildHostelCard(
                          context,
                          imageUrl:
                              'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=400&q=80',
                          title: 'Sunrise Hostel',
                          price: '\$120/mo',
                          location: 'Downtown, NY',
                          type: 'Shared',
                        ),
                        const SizedBox(width: BuddyTheme.spacingSm),
                        _buildHostelCard(
                          context,
                          imageUrl:
                              'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=400&q=80',
                          title: 'Sunset PG',
                          price: '\$150/mo',
                          location: 'Uptown, NY',
                          type: 'Private',
                        ),
                        const SizedBox(width: BuddyTheme.spacingSm),
                        _buildHostelCard(
                          context,
                          imageUrl:
                              'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=400&q=80',
                          title: 'Moonlight Hostel',
                          price: '\$100/mo',
                          location: 'Midtown, NY',
                          type: 'Shared',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: BuddyTheme.spacingMd),

                  // Featured Services Section
                  _buildSectionHeader(
                    context,
                    'Featured Services',
                    () => Navigator.pushNamed(context, '/services'),
                  ),
                  const SizedBox(height: BuddyTheme.spacingSm),
                  SizedBox(
                    height: 200, // Increased from 180
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildServiceCard(
                          context,
                          imageUrl:
                              'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
                          name: 'Cafe Mocha',
                          type: 'Cafe',
                        ),
                        const SizedBox(width: BuddyTheme.spacingSm),
                        _buildServiceCard(
                          context,
                          imageUrl:
                              'https://images.unsplash.com/photo-1460518451285-97b6aa326961?auto=format&fit=crop&w=400&q=80',
                          name: 'City Library',
                          type: 'Library',
                        ),
                        const SizedBox(width: BuddyTheme.spacingSm),
                        _buildServiceCard(
                          context,
                          imageUrl:
                              'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
                          name: 'Gym Fitness',
                          type: 'Gym',
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello!',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: BuddyTheme.textSecondaryColor,
              ),
            ),
            Text(
              _userName,
              style: Theme.of(
                context,
              ).textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              width: BuddyTheme.iconSizeXl,
              height: BuddyTheme.iconSizeXl,
              decoration: BoxDecoration(
                color: BuddyTheme.successColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: BuddyTheme.borderColor, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  BuddyTheme.borderRadiusCircular,
                ),
                child: CachedNetworkImage(
                  imageUrl: 'https://via.placeholder.com/50',
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Shimmer.fromColors(
                        baseColor: BuddyTheme.backgroundSecondaryColor,
                        highlightColor: BuddyTheme.backgroundPrimaryColor,
                        child: Container(
                          color: BuddyTheme.backgroundSecondaryColor,
                        ),
                      ),
                  errorWidget:
                      (context, url, error) => Icon(
                        Icons.person,
                        color: BuddyTheme.textSecondaryColor,
                        size: BuddyTheme.iconSizeLg,
                      ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    VoidCallback onTap,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            'See All »',
            style: Theme.of(
              context,
            ).textTheme.labelLarge!.copyWith(color: BuddyTheme.successColor),
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyCard(
    BuildContext context,
    Map<String, dynamic> property,
  ) {
    // Helper function to format currency
    String formatPrice(String price) {
      if (price.isEmpty) return '';
      final amount = int.tryParse(price) ?? 0;
      return '₹${(amount / 1000).toStringAsFixed(0)}K/month';
    }

    // Helper function to format date
    String formatAvailableDate(String? dateString) {
      if (dateString == null || dateString.isEmpty) return 'Immediate';
      try {
        final date = DateTime.parse(dateString);
        final now = DateTime.now();
        final difference = date.difference(now).inDays;

        if (difference <= 0) return 'Available Now';
        if (difference <= 7) return 'This Week';
        if (difference <= 30) return 'This Month';
        return '${date.day}/${date.month}';
      } catch (e) {
        return 'Available';
      }
    }

    // Helper function to get short furnishing
    String getShortFurnishing(String furnishing) {
      if (furnishing.toLowerCase().contains('full')) return 'Fully Furnished';
      if (furnishing.toLowerCase().contains('semi')) return 'Semi Furnished';
      if (furnishing.toLowerCase().contains('un')) return 'Unfurnished';
      return furnishing;
    }

    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        width: 240, // More compact width
        decoration: BuddyTheme.featuredCardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with Status Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(BuddyTheme.borderRadiusMd),
                    topRight: Radius.circular(BuddyTheme.borderRadiusMd),
                  ),
                  child: CachedNetworkImage(
                    imageUrl:
                        property['imageUrl'] ??
                        'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
                    height: 110, // Slightly reduced height
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Shimmer.fromColors(
                          baseColor: BuddyTheme.backgroundSecondaryColor,
                          highlightColor: BuddyTheme.backgroundPrimaryColor,
                          child: Container(
                            height: 110,
                            color: BuddyTheme.backgroundSecondaryColor,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          height: 110,
                          color: Colors.grey[300],
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Image not available',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                  ),
                ),
                // Available Status Badge
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Available',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                // Room Type Badge
                Positioned(
                  bottom: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${property['roomType'] ?? ''} • ${property['flatSize'] ?? ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(10), // Slightly reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    property['title'] ?? 'Property Title',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: BuddyTheme.textPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // Location
                  Text(
                    property['location'] ?? 'Location',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: BuddyTheme.textSecondaryColor,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Price
                  Text(
                    formatPrice(property['rent'] ?? ''),
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: BuddyTheme.accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // First Row of Info Chips
                  Wrap(
                    spacing: 3,
                    runSpacing: 2,
                    children: [
                      _buildInfoChip(
                        context,
                        Icons.chair,
                        getShortFurnishing(property['furnishing'] ?? ''),
                      ),
                      _buildInfoChip(
                        context,
                        Icons.calendar_today,
                        formatAvailableDate(property['availableFromDate']),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Second Row of Info Chips
                  Wrap(
                    spacing: 3,
                    runSpacing: 2,
                    children: [
                      if (property['genderComposition'] != null &&
                          property['genderComposition'].toString().isNotEmpty)
                        _buildInfoChip(
                          context,
                          Icons.wc,
                          property['genderComposition'],
                        ),
                      if (property['occupation'] != null &&
                          property['occupation'].toString().isNotEmpty)
                        _buildInfoChip(
                          context,
                          Icons.work,
                          property['occupation'],
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Flatmates Info
                  if (property['currentFlatmates'] != null &&
                      property['maxFlatmates'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: BuddyTheme.backgroundSecondaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.people_outline,
                            size: 12,
                            color: BuddyTheme.textSecondaryColor,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${property['currentFlatmates']}/${property['maxFlatmates']} flatmates',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall!.copyWith(
                              color: BuddyTheme.textSecondaryColor,
                              fontSize: 10,
                            ),
                          ),
                        ],
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

  // Enhanced info chip with better styling
  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: BuddyTheme.backgroundSecondaryColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: BuddyTheme.borderColor.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: BuddyTheme.textSecondaryColor),
          const SizedBox(width: 2),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: BuddyTheme.textSecondaryColor,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlatmateCard(
    BuildContext context, {
    required String imageUrl,
    required String name,
    required String age,
    required String profession,
    Color? cardColor,
    Color? labelColor,
  }) {
    final Color effectiveCardColor =
        cardColor ?? BuddyTheme.backgroundSecondaryColor;
    final Color effectiveLabelColor = labelColor ?? BuddyTheme.textPrimaryColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            BuddyTheme.primaryColor.withOpacity(0.12),
            BuddyTheme.accentColor.withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(BuddyTheme.borderRadiusMd),
        border: Border.all(
          color: BuddyTheme.primaryColor.withOpacity(0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      width: 130,
      padding: const EdgeInsets.all(BuddyTheme.spacingMd),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: 64,
                height: 64,
                placeholder:
                    (context, url) => Shimmer.fromColors(
                      baseColor: effectiveCardColor,
                      highlightColor: BuddyTheme.backgroundPrimaryColor,
                      child: Container(color: effectiveCardColor),
                    ),
                errorWidget:
                    (context, url, error) => Icon(
                      Icons.person,
                      color: effectiveLabelColor,
                      size: BuddyTheme.iconSizeMd,
                    ),
              ),
            ),
          ),
          const SizedBox(height: BuddyTheme.spacingXs),
          Text(
            name,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.w700,
              color: effectiveLabelColor,
              fontSize: 16,
              letterSpacing: 0.1,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          if (age.isNotEmpty)
            Text(
              'Age: $age',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: effectiveLabelColor.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          Text(
            profession.isNotEmpty ? profession : '—',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: BuddyTheme.accentColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 0.1,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required String imageUrl,
    required String name,
    required String type,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: BuddyTheme.backgroundSecondaryColor,
        borderRadius: BorderRadius.circular(BuddyTheme.borderRadiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      width: 120,
      padding: const EdgeInsets.all(
        BuddyTheme.spacingSm,
      ), // Reduced from spacingMd
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(BuddyTheme.borderRadiusMd),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              height: 60, // Reduced from 80
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Shimmer.fromColors(
                    baseColor: BuddyTheme.backgroundSecondaryColor,
                    highlightColor: BuddyTheme.backgroundPrimaryColor,
                    child: Container(
                      color: BuddyTheme.backgroundSecondaryColor,
                    ),
                  ),
              errorWidget:
                  (context, url, error) => Icon(
                    Icons.broken_image,
                    color: BuddyTheme.textSecondaryColor,
                    size: BuddyTheme.iconSizeLg,
                  ),
            ),
          ),
          const SizedBox(height: BuddyTheme.spacingXs),
          Text(
            name,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: BuddyTheme.textPrimaryColor,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            type,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: BuddyTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHostelCard(
    BuildContext context, {
    required String imageUrl,
    required String title,
    required String price,
    required String location,
    required String type, // e.g. "Shared", "Private", "PG", etc.
  }) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        width: 255,
        decoration: BuddyTheme.featuredCardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(BuddyTheme.borderRadiusMd),
                topRight: Radius.circular(BuddyTheme.borderRadiusMd),
              ),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Shimmer.fromColors(
                      baseColor: BuddyTheme.backgroundSecondaryColor,
                      highlightColor: BuddyTheme.backgroundPrimaryColor,
                      child: Container(
                        color: BuddyTheme.backgroundSecondaryColor,
                      ),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.broken_image,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(BuddyTheme.spacingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(color: BuddyTheme.textPrimaryColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        price,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: BuddyTheme.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: BuddyTheme.spacingXs),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: BuddyTheme.textSecondaryColor,
                        size: BuddyTheme.iconSizeSm,
                      ),
                      const SizedBox(width: BuddyTheme.spacingXxs),
                      Expanded(
                        child: Text(
                          location,
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(color: BuddyTheme.textSecondaryColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: BuddyTheme.spacingSm),
                  _buildInfoChip(context, Icons.meeting_room, type),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PropertyData {
  final String imageUrl;
  // ... other fields

  PropertyData({
    required this.imageUrl,
    // ... other fields
  });

  factory PropertyData.fromJson(Map<String, dynamic> json) {
    return PropertyData(
      imageUrl: json['imageUrl'] ?? '',
      // ... other fields
    );
  }
}

List<Map<dynamic, dynamic>> _featuredProperties = [];
bool _isLoadingProperties = true;

List<Map<dynamic, dynamic>> _featuredFlatmates = [];
bool _isLoadingFlatmates = true;
