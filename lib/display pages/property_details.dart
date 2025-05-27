import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class PropertyDetailsPage extends StatefulWidget {
  final String propertyKey;
  const PropertyDetailsPage({Key? key, required this.propertyKey})
    : super(key: key);

  @override
  State<PropertyDetailsPage> createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage> {
  Map<dynamic, dynamic>? propertyData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProperty();
  }

  Future<void> fetchProperty() async {
    final ref = FirebaseDatabase.instance
        .ref()
        .child('room_listings')
        .child(widget.propertyKey);
    final snapshot = await ref.get();
    if (snapshot.exists) {
      setState(() {
        propertyData = snapshot.value as Map<dynamic, dynamic>;
        isLoading = false;
      });
    } else {
      setState(() {
        propertyData = null;
        isLoading = false;
      });
    }
  }

  Widget _buildInfoSection(
    String label,
    String? value, {
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value ?? '-',
            style: TextStyle(
              fontSize: highlight ? 18 : 16,
              fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
              color: highlight ? Colors.blue[700] : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilitiesSection(Map facilities) {
    final enabledFacilities =
        facilities.entries
            .where((e) => e.value == true)
            .map((e) => e.key)
            .toList();
    if (enabledFacilities.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          'No facilities listed',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            enabledFacilities
                .map(
                  (facility) => Chip(
                    label: Text(facility.toString()),
                    backgroundColor: Colors.blue[50],
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildPhotosSection(List photos) {
    if (photos.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        itemBuilder: (context, idx) {
          final url = photos[idx];
          return Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 8,
              top: 8,
              bottom: 8,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                url,
                width: 200,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      width: 200,
                      height: 160,
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Property Details')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : propertyData == null
              ? const Center(child: Text('Property not found.'))
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photos
                    if (propertyData?['uploadedPhotos'] != null &&
                        (propertyData!['uploadedPhotos'] as List).isNotEmpty)
                      _buildPhotosSection(
                        propertyData!['uploadedPhotos'] as List,
                      ),
                    const SizedBox(height: 12),
                    // Title
                    _buildInfoSection(
                      'Title',
                      propertyData?['title'],
                      highlight: true,
                    ),
                    _buildInfoSection('Location', propertyData?['location']),
                    _buildInfoSection('Rent', propertyData?['rent']),
                    _buildInfoSection('Deposit', propertyData?['deposit']),
                    _buildInfoSection(
                      'Available From',
                      propertyData?['availableFromDate'],
                    ),
                    _buildInfoSection('Room Type', propertyData?['roomType']),
                    _buildInfoSection('Flat Size', propertyData?['flatSize']),
                    _buildInfoSection(
                      'Furnishing',
                      propertyData?['furnishing'],
                    ),
                    _buildInfoSection(
                      'Attached Bathroom',
                      propertyData?['hasAttachedBathroom'] == true
                          ? 'Yes'
                          : 'No',
                    ),
                    _buildInfoSection(
                      'Current Flatmates',
                      propertyData?['currentFlatmates']?.toString(),
                    ),
                    _buildInfoSection(
                      'Max Flatmates',
                      propertyData?['maxFlatmates']?.toString(),
                    ),
                    _buildInfoSection(
                      'Gender Composition',
                      propertyData?['genderComposition'],
                    ),
                    _buildInfoSection(
                      'Occupation',
                      propertyData?['occupation'],
                    ),
                    _buildInfoSection(
                      'Looking For',
                      propertyData?['lookingFor'],
                    ),
                    _buildInfoSection(
                      'Food Preference',
                      propertyData?['foodPreference'],
                    ),
                    _buildInfoSection(
                      'Smoking Policy',
                      propertyData?['smokingPolicy'],
                    ),
                    _buildInfoSection(
                      'Drinking Policy',
                      propertyData?['drinkingPolicy'],
                    ),
                    _buildInfoSection(
                      'Pets Policy',
                      propertyData?['petsPolicy'],
                    ),
                    _buildInfoSection(
                      'Guests Policy',
                      propertyData?['guestsPolicy'],
                    ),
                    _buildInfoSection('Phone', propertyData?['phone']),
                    _buildInfoSection('Email', propertyData?['email']),
                    _buildInfoSection('Notes', propertyData?['notes']),
                    // Facilities
                    if (propertyData?['facilities'] != null)
                      _buildFacilitiesSection(
                        propertyData!['facilities'] as Map,
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
    );
  }
}
