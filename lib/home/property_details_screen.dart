import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/api_service.dart';
import 'book_viewing_screen.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final String propertyId;

  const PropertyDetailsScreen({super.key, required this.propertyId});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _property;
  bool _isFavorite = false;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() => _isLoading = true);
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final response = await apiService.getPropertyDetails(widget.propertyId);

      try {
        final favResponse = await apiService.getMyFavorites();
        List favs = favResponse.data['data'] ?? [];
        _isFavorite = favs.any((f) {
          var favId = f['propertyId'] is Map ? f['propertyId']['_id'] : f['propertyId'];
          String finalFavId = favId is Map ? (favId['\$oid'] ?? favId['oid'] ?? '').toString() : favId.toString();
          return finalFavId == widget.propertyId;
        });
      } catch (_) {}

      if (mounted) {
        setState(() {
          var responseData = response.data;
          if (responseData is Map && responseData.containsKey('data')) {
            _property = responseData['data'];
          } else {
            _property = responseData;
          }

          final images = _property?['images'] as List?;
          if (images != null && images.isNotEmpty) {
            var firstImage = images[0];
            _currentImageUrl = firstImage is Map ? firstImage['url'] : firstImage.toString();
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint("Fetch Details Error: $e");
    }
  }

  void _launchWhatsApp() async {
    final phone = _property?['ownerPhone'] ?? "+201234567890";
    final message = "Hello, I'm interested in: ${_property?['name'] ?? 'this property'}";
    final Uri whatsappUri = Uri.parse("https://wa.me/$phone?text=${Uri.encodeComponent(message)}");

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not launch WhatsApp")),
          );
        }
      }
    } catch (e) {
      debugPrint("WhatsApp Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF0095FF))));
    if (_property == null) return const Scaffold(body: Center(child: Text("Property not found")));

    final details = _property?['details'] as Map<String, dynamic>?;
    final images = (_property?['images'] as List?) ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // تم تحويل التصميم إلى CustomScrollView لضمان ظهور محتوى الفيجما بالكامل بشكل سليم
          Positioned.fill(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverHeroSection(),
                SliverToBoxAdapter(
                  child: _buildContentSection(details, images),
                ),
              ],
            ),
          ),
          _buildBottomActionCard(),
        ],
      ),
    );
  }

  Widget _buildSliverHeroSection() {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.42,
      automaticallyImplyLeading: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Positioned.fill(
              child: _currentImageUrl != null
                  ? Image.network(_currentImageUrl!, fit: BoxFit.cover)
                  : Container(color: Colors.grey[200], child: const Icon(Icons.home, size: 50, color: Colors.grey)),
            ),
            // تدرج ظلي خفيف عشان الأزرار البيضاء تبان
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.2), Colors.transparent],
                ),
              ),
            ),
            // الأزرار العلوية (Back & Favorite) متطابقة مع الفيجما
            Positioned(
              top: 50, left: 20, right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _topCircleButton(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
                  _topCircleButton(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    _toggleFavorite,
                    iconColor: _isFavorite ? Colors.red : Colors.black,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection(Map<String, dynamic>? details, List images) {
    String description = _property?['description'] ?? '';
    if (description.isEmpty) {
      String type = _property?['propertyType'] ?? 'Property';
      String city = _property?['location']?['city'] ?? 'Cairo';
      description = "Experience luxury living in this stunning $type located in the heart of $city. Perfect choice for your family.";
    }

    final String status = _property?['statusSaleRent'] == 'sale' ? 'For Sale' : 'For Rent';
    final String type = _property?['propertyType'] ?? 'N/A';
    final String availability = _property?['availability'] == 'available' ? 'Available' : 'Optioned';
    final bool isFurnished = details?['furnished'] ?? false;

    return Transform.translate(
      offset: const Offset(0, -30), // يخلي الـ Container الأبيض يركب فوق الصورة زي الفيجما بالظبط
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),
        padding: const EdgeInsets.fromLTRB(25, 30, 25, 120), // مسافة أمان سفلية للـ Bottom Card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان والريتنج
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                      _property?['name'] ?? 'Grand Luxury Villa',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1E25))
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFFFF9E6), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: const [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(" 4.8", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1A1E25))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // الموقع اللوكيشن
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                const SizedBox(width: 4),
                Text(
                    "${_property?['location']?['city'] ?? 'New Cairo'}, ${_property?['location']?['address'] ?? '5th Settlement'}",
                    style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)
                ),
              ],
            ),
            const SizedBox(height: 25),

            // معرض الصور المصغرة المماثل للفيجما
            if (images.isNotEmpty) ...[
              _buildGalleryList(images),
              const SizedBox(height: 25),
            ],

            // المواصفات (Beds - Baths - Area)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _specTile(Icons.bed_outlined, "${details?['bedrooms'] ?? 5} Beds")),
                const SizedBox(width: 12),
                Expanded(child: _specTile(Icons.bathtub_outlined, "${details?['bathrooms'] ?? 5} Baths")),
                const SizedBox(width: 12),
                Expanded(child: _specTile(Icons.square_foot_outlined, "${details?['area'] ?? 600} m²")),
              ],
            ),
            const SizedBox(height: 25),

            const Text("Property Overview", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1E25))),
            const SizedBox(height: 12),
            GridView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 15,
                childAspectRatio: 3.2,
              ),
              children: [
                _overviewTile(Icons.assignment_outlined, "Purpose", status),
                _overviewTile(Icons.home_work_outlined, "Type", type),
                _overviewTile(Icons.chair_outlined, "Furnished", isFurnished ? "Yes" : "No"),
                _overviewTile(Icons.check_circle_outline, "Status", availability),
              ],
            ),
            const SizedBox(height: 25),

            const Text("Description", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1E25))),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(color: Colors.black54, height: 1.6, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _specTile(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: Colors.grey.shade600),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _overviewTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF0095FF)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1A1E25)), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGalleryList(List images) {
    return SizedBox(
      height: 65,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, i) {
          final item = images[i];
          final url = item is Map ? (item['url'] ?? '') : item.toString();
          bool isSelected = _currentImageUrl == url;
          return GestureDetector(
            onTap: () => setState(() => _currentImageUrl = url),
            child: Container(
              width: 65,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                image: url.isNotEmpty ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover) : null,
                color: Colors.grey[200],
                border: Border.all(color: isSelected ? const Color(0xFF0095FF) : Colors.transparent, width: 2),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomActionCard() {
    double price = double.tryParse(_property?['price']?.toString() ?? '0') ?? 0;
    String displayPrice = price >= 1000000 ? "${(price / 1000000).toStringAsFixed(1)}M" : price.toStringAsFixed(0);

    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(25, 15, 25, 35),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, -4))],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Total Price", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(
                    "EGP $displayPrice",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0095FF))
                ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: _launchWhatsApp,
              child: Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                    color: const Color(0xFFE8F7EE),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFC3E6CB))
                ),
                child: const Icon(Icons.chat, color: Colors.green, size: 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _showBookingSheet(),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0095FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "Book Visit",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topCircleButton(IconData icon, VoidCallback onTap, {Color iconColor = Colors.black}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
    );
  }

  void _showBookingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => BookViewingScreen(propertyId: widget.propertyId),
    );
  }

  Future<void> _toggleFavorite() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      if (_isFavorite) {
        await apiService.removeFromFavorites(widget.propertyId);
      } else {
        await apiService.addToFavorites(widget.propertyId);
      }
      setState(() => _isFavorite = !_isFavorite);
    } catch (e) {
      debugPrint("Fav Error: $e");
    }
  }
}