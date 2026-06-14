import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/api_service.dart';
import '../home/property_details_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final String? beds;
  final String? baths;

  const SearchResultsScreen({
    super.key,
    this.category,
    this.minPrice,
    this.maxPrice,
    this.beds,
    this.baths,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  bool _isLoading = true;
  List<dynamic> _results = [];

  @override
  void initState() {
    super.initState();
    _fetchResults();
  }

  Future<void> _fetchResults() async {
    setState(() => _isLoading = true);
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      // نرسل الفلاتر للـ API
      final response = await apiService.getProperties(
        category: widget.category,
        minPrice: widget.minPrice,
        maxPrice: widget.maxPrice,
        // تأكدي أن الـ ApiService يدعم هذه المعاملات
      );

      if (mounted) {
        setState(() {
          _results = response.data['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Search Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Search Results", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
          ? _buildEmptyState()
          : _buildResultsList(),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final property = _results[index];
        return _buildPropertyCard(property);
      },
    );
  }

  Widget _buildPropertyCard(dynamic property) {
    // نفس تصميم الكارد اللي عملناه في الهوم سكرين لضمان تناسق الشكل
    final id = property['_id'].toString();
    final name = property['name'] ?? 'Property';
    final price = property['price'] ?? '0';
    final city = property['location']?['city'] ?? '';
    String imageUrl = "";
    if (property['images'] != null && property['images'].isNotEmpty) {
      imageUrl = property['images'][0]['url'] ?? property['images'][0];
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PropertyDetailsScreen(propertyId: id)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: imageUrl.isNotEmpty
                  ? Image.network(imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover)
                  : Container(height: 180, color: Colors.grey[200], child: const Icon(Icons.home)),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(city, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  Text("EGP $price", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 15),
          const Text("No properties match your filters", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}