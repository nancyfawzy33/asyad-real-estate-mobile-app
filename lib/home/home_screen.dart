import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // تمت الإضافة لمسح التوكن عند الخروج
import '../core/api_service.dart';
import '../sign/loginscreen.dart';
import 'property_details_screen.dart';
// عملنا import لشاشة الـ Login اللي لسه مخلصينها

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  List _properties = [];
  String _selectedCategory = 'All';
  final _storage = const FlutterSecureStorage(); // استدعاء الـ Storage

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    setState(() => _isLoading = true);
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final response = await apiService.getProperties();

      if (mounted) {
        setState(() {
          _properties = response.data['data'] ?? response.data ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint("Home Load Error: $e");
    }
  }

  // دالة تسجيل الخروج والانتقال لصفحة الـ Login مباشرة مع مسح التوكن
  Future<void> _handleLogout() async {
    // 1. مسح التوكن المخزن عشان نأمن الحساب تماماً
    await _storage.delete(key: 'token');

    if (!mounted) return;

    // 2. التوجيه لشاشة الـ LoginScreen وتصفير كل الشاشات اللي فاتت
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(), // التوجيه لشاشتك المظبوطة
      ),
          (route) => false, // يمنع المستخدم من الرجوع بـ Back للـ Home بعد تسجيل الخروج
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0095FF)))
          : SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 25),
              _buildSearchBar(),
              const SizedBox(height: 25),
              _buildCategories(),
              const SizedBox(height: 25),
              _buildFeaturedSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // 1. الهيدر (المكان، الترحيب، النوتيفيكيشن، وزرار الـ Logout)
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Location", style: TextStyle(color: Colors.grey, fontSize: 12)),
            SizedBox(height: 4),
            Row(
              children: [
                Text("Cairo, Egypt ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A1E25))),
                Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF0095FF)),
              ],
            ),
            SizedBox(height: 15),
            Text("Hey, Yusuf 👋", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1E25))),
            SizedBox(height: 4),
            Text("Let's find your dream home", style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        Row(
          children: [
            // زرار الإشعارات
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 22,
              child: IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.black54, size: 22),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 10),
            // زرار تسجيل الخروج (Logout) المتجه لشاشة الـ Login
            CircleAvatar(
              backgroundColor: const Color(0xFFFFEBEB),
              radius: 22,
              child: IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                tooltip: 'Logout',
                onPressed: _handleLogout,
              ),
            ),
          ],
        )
      ],
    );
  }

  // 2. شريط البحث
  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: "Search house, apartment...",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.grey),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFF0095FF), borderRadius: BorderRadius.circular(15)),
          child: const Icon(Icons.tune, color: Colors.white, size: 22),
        )
      ],
    );
  }

  // 3. قسم التصنيفات (Categories)
  Widget _buildCategories() {
    final categories = ['All', 'House', 'Villa', 'Apartment'];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1E25))),
            TextButton(onPressed: () {}, child: const Text("See All", style: TextStyle(color: Color(0xFF0095FF)))),
          ],
        ),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, i) {
              bool isSelected = _selectedCategory == categories[i];
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = categories[i]),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0095FF) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade200),
                  ),
                  child: Center(
                    child: Text(
                      categories[i],
                      style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 4. قسم العقارات المعروضة (Featured)
  Widget _buildFeaturedSection() {
    final List filteredProperties = _properties.where((p) {
      if (p == null || p is! Map) return false;
      if (_selectedCategory == 'All') return true;
      return (p['propertyType']?.toString().toLowerCase() == _selectedCategory.toLowerCase());
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Featured", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1E25))),
            TextButton(onPressed: () {}, child: const Text("See All", style: TextStyle(color: Color(0xFF0095FF)))),
          ],
        ),
        filteredProperties.isEmpty
            ? const Padding(
          padding: EdgeInsets.only(top: 40),
          child: Center(child: Text("No properties found in this category", style: TextStyle(color: Colors.grey))),
        )
            : SizedBox(
          height: 285,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: filteredProperties.length,
            itemBuilder: (context, index) {
              final item = filteredProperties[index] as Map<String, dynamic>;
              return PropertyCard(
                property: item,
                onTap: () {
                  String propertyId = '';
                  if (item['_id'] is Map) {
                    propertyId = (item['_id']['\$oid'] ?? item['_id']['oid'] ?? '').toString();
                  } else {
                    propertyId = (item['_id'] ?? '').toString();
                  }

                  if (propertyId.isEmpty) {
                    propertyId = (item['id'] ?? '').toString();
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PropertyDetailsScreen(
                        propertyId: propertyId,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF0095FF),
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: "Explore"),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Saved"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
      ],
    );
  }
}

class PropertyCard extends StatelessWidget {
  final Map<String, dynamic> property;
  final VoidCallback onTap;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final images = property['images'] as List?;
    final imageUrl = (images != null && images.isNotEmpty)
        ? (images[0] is Map ? (images[0]['url'] ?? '') : images[0].toString())
        : '';

    final location = property['location'] as Map<String, dynamic>?;
    final details = property['details'] as Map<String, dynamic>?;

    final String status = property['statusSaleRent'] == 'sale' ? 'For Sale' : 'For Rent';

    double price = double.tryParse(property['price']?.toString() ?? '0') ?? 0;
    String displayPrice = price >= 1000000
        ? "${(price / 1000000).toStringAsFixed(1)}M"
        : price.toStringAsFixed(0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        margin: const EdgeInsets.only(right: 16, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: imageUrl.isNotEmpty
                      ? Image.network(imageUrl, height: 145, width: double.infinity, fit: BoxFit.cover)
                      : Container(height: 145, color: Colors.grey[200], child: const Icon(Icons.home, size: 40, color: Colors.grey)),
                ),
                Positioned(
                  top: 12, left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFF0095FF), borderRadius: BorderRadius.circular(8)),
                    child: Text("EGP $displayPrice", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ),
                Positioned(
                  top: 12, right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), borderRadius: BorderRadius.circular(8)),
                    child: Text(status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 10)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property['name'] ?? '',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1E25)),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 13, color: Colors.grey),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          "${location?['city'] ?? ''}, ${location?['address'] ?? ''}",
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _miniSpecTile(Icons.bed_outlined, "${details?['bedrooms'] ?? 0} Beds"),
                      _miniSpecTile(Icons.bathtub_outlined, "${details?['bathrooms'] ?? 0} Baths"),
                      _miniSpecTile(Icons.square_foot_outlined, "${details?['area'] ?? 0} m²"),
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

  Widget _miniSpecTile(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Colors.grey[500]),
        const SizedBox(width: 2),
        Text(text, style: TextStyle(fontSize: 10, color: Colors.grey[700], fontWeight: FontWeight.w500)),
      ],
    );
  }
}