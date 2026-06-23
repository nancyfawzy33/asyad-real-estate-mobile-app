import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/api_service.dart';
import 'property_details_screen.dart';
import '../filter_explore/map_screen.dart';
import '../filter_explore/saved_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  bool _isLoading = true;
  List _properties = [];
  String _selectedCategory = 'All';
  String? _errorMessage;
  String _userName = 'there';

  final List<String> _categories = ['All', 'Villa', 'Apartment'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      final results = await Future.wait([
        apiService.getMe(),
        apiService.getProperties(),
      ]);

      final userResponse = results[0];
      final propResponse = results[1];

      final userData = userResponse.data['data'] ?? userResponse.data;
      if (userData is Map) {
        final fullName = userData['fullName']?.toString() ?? '';
        final userName = userData['userName']?.toString() ?? '';
        final email   = userData['email']?.toString() ?? '';
        if (fullName.isNotEmpty) {
          _userName = fullName.split(' ').first;
        } else if (userName.isNotEmpty) {
          _userName = userName;
        } else if (email.isNotEmpty) {
          _userName = email.split('@').first;
        }
      }

      final raw = propResponse.data;
      List result = [];
      if (raw is List) {
        result = raw;
      } else if (raw is Map) {
        result = (raw['data'] ?? raw['properties'] ?? raw['results'] ?? []) as List;
      }

      if (mounted) setState(() { _properties = result; _isLoading = false; });
    } catch (e) {
      debugPrint('❌ Error: $e');
      if (mounted) setState(() { _isLoading = false; _errorMessage = 'Failed to load.'; });
    }
  }

  // ✅ لما تضغط القلب: يعمل save ويروح لتاب الـ Saved
  Future<void> _toggleFavorite(String propertyId, int index) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final current = _properties[index]['_isFavorite'] == true;
    try {
      if (current) {
        await apiService.removeFromFavorites(propertyId);
        setState(() => _properties[index]['_isFavorite'] = false);
      } else {
        await apiService.addToFavorites(propertyId);
        setState(() => _properties[index]['_isFavorite'] = true);
        // ✅ ينقله لتاب Saved (index 2) بعد ما يعمل save
        setState(() => _currentNavIndex = 2);
      }
    } catch (e) {
      debugPrint('❌ Favorite error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update favorite')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: IndexedStack(
        index: _currentNavIndex,
        children: [
          _buildHomePage(),
          const MapScreen(),
          const SavedScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF0095FF),
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      elevation: 12,
      currentIndex: _currentNavIndex,
      onTap: (i) => setState(() => _currentNavIndex = i),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Explore"),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Saved"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
      ],
    );
  }

  Widget _buildHomePage() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0095FF)));
    }
    if (_errorMessage != null) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(_errorMessage!, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0095FF)),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ]),
      );
    }
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFF0095FF),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopHeader(),
              _buildSearchBar(),
              _buildCategoriesSection(),
              _buildFeaturedSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: const [
                Text('Location', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ]),
              const SizedBox(height: 2),
              Row(children: const [
                Text('Cairo, Egypt', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF1A1A2E)),
              ]),
              const SizedBox(height: 10),
              Text(
                'Hey, $_userName 👋',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
              ),
              const SizedBox(height: 2),
              const Text("Let's find your dream home", style: TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
                ),
                child: const Icon(Icons.notifications_outlined, color: Color(0xFF1A1A2E), size: 22),
              ),
              Positioned(
                right: 8, top: 8,
                child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search house, apartment...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: const Color(0xFF0095FF), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.tune, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
              const Text('See All', style: TextStyle(fontSize: 13, color: Color(0xFF0095FF), fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, i) {
                final selected = _categories[i] == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = _categories[i]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF0095FF) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? const Color(0xFF0095FF) : Colors.grey.shade300),
                      boxShadow: selected
                          ? [BoxShadow(color: const Color(0xFF0095FF).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        _categories[i],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          color: selected ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection() {
    final filtered = _properties.where((p) {
      if (_selectedCategory == 'All') return true;
      return p['propertyType']?.toString().toLowerCase() == _selectedCategory.toLowerCase();
    }).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Featured', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                const Text('See All', style: TextStyle(fontSize: 13, color: Color(0xFF0095FF), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40, right: 20),
              child: Center(child: Text('No properties found', style: TextStyle(color: Colors.grey))),
            )
          else
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final realIndex = _properties.indexOf(filtered[i]);
                  final idRaw = filtered[i]['_id'];
                  final String id = (idRaw is Map)
                      ? (idRaw['\$oid'] ?? '').toString()
                      : idRaw?.toString() ?? '';

                  return PropertyCard(
                    property: filtered[i],
                    isFavorite: filtered[i]['_isFavorite'] == true,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PropertyDetailsScreen(propertyId: id)),
                    ),
                    onFavoriteTap: () => _toggleFavorite(id, realIndex),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class PropertyCard extends StatelessWidget {
  final Map<String, dynamic> property;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final bool isFavorite;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    required this.onFavoriteTap,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final images = property['images'] as List?;
    final String imageUrl = (images != null && images.isNotEmpty)
        ? (images[0] is Map ? images[0]['url']?.toString() ?? '' : images[0].toString())
        : '';

    final String name = property['name']?.toString() ?? 'Property';
    final String location = property['location']?.toString() ?? property['address']?.toString() ?? '';
    final dynamic price = property['price'];
    final dynamic beds = property['bedrooms'] ?? property['beds'];
    final dynamic baths = property['bathrooms'] ?? property['baths'];
    final dynamic area = property['area'] ?? property['size'];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                      : _placeholder(),
                ),
                if (price != null)
                  Positioned(
                    top: 12, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: const Color(0xFF0095FF), borderRadius: BorderRadius.circular(8)),
                      child: Text('EGP ${_formatPrice(price)}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ),
                // ✅ القلب له GestureDetector منفصل مع HitTestBehavior.opaque
                Positioned(
                  top: 12, right: 12,
                  child: GestureDetector(
                    onTap: onFavoriteTap,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: isFavorite ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  if (location.isNotEmpty)
                    Row(children: [
                      const Icon(Icons.location_on, size: 12, color: Color(0xFF0095FF)),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(location,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    if (beds != null) ...[
                      const Icon(Icons.bed_outlined, size: 13, color: Colors.grey),
                      const SizedBox(width: 3),
                      Text('$beds Beds', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                    if (baths != null) ...[
                      const SizedBox(width: 10),
                      const Icon(Icons.bathtub_outlined, size: 13, color: Colors.grey),
                      const SizedBox(width: 3),
                      Text('$baths Baths', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                    if (area != null) ...[
                      const SizedBox(width: 10),
                      const Icon(Icons.square_foot, size: 13, color: Colors.grey),
                      const SizedBox(width: 3),
                      Text('$area m²', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    height: 160, width: double.infinity,
    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: const BorderRadius.vertical(top: Radius.circular(18))),
    child: const Icon(Icons.home, size: 50, color: Colors.grey),
  );

  String _formatPrice(dynamic price) {
    final num p = num.tryParse(price.toString()) ?? 0;
    if (p >= 1000000) return '${(p / 1000000).toStringAsFixed(1)}M';
    if (p >= 1000) return '${(p / 1000).toStringAsFixed(0)}K';
    return p.toString();
  }
}