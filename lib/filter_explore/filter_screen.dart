import 'package:flutter/material.dart';
import 'search_results_screen.dart';

class FilterScreen extends StatefulWidget {
  final String initialCategory;

  const FilterScreen({
    super.key,
    this.initialCategory = 'All', // غيرتها لـ All كدايفولت أشمل
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late String selectedCategory;
  String selectedBeds = 'Any';
  String selectedBaths = 'Any';
  // رينج الأسعار بالملايين لتسهيل تجربة المستخدم
  RangeValues priceRange = const RangeValues(1, 20);

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black), // علامة X أشيك في الفلتر
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Filters", style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => setState(() {
              selectedCategory = 'All';
              priceRange = const RangeValues(1, 20);
              selectedBeds = 'Any';
              selectedBaths = 'Any';
            }),
            child: const Text("Reset", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _sectionTitle("Category"),
            const SizedBox(height: 15),
            _buildCategoryRow(),

            const SizedBox(height: 35),
            _sectionTitle("Price Range (EGP)"),
            const SizedBox(height: 10),
            RangeSlider(
              values: priceRange,
              min: 0,
              max: 100, // زودت الماكس لـ 100 مليون لمرونة أكتر
              divisions: 100,
              activeColor: Colors.blue,
              inactiveColor: Colors.blue.withOpacity(0.1),
              labels: RangeLabels("${priceRange.start.round()}M", "${priceRange.end.round()}M"),
              onChanged: (values) => setState(() => priceRange = values),
            ),
            _buildPriceLabels(),

            const SizedBox(height: 35),
            _sectionTitle("Bedrooms"),
            const SizedBox(height: 15),
            _buildSelectionRow(['Any', '1', '2', '3', '4+'], selectedBeds, (val) => setState(() => selectedBeds = val)),

            const SizedBox(height: 35),
            _sectionTitle("Bathrooms"),
            const SizedBox(height: 15),
            _buildSelectionRow(['Any', '1', '2', '3', '4+'], selectedBaths, (val) => setState(() => selectedBaths = val)),

            const SizedBox(height: 50),
            _buildApplyButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)));
  }

  Widget _buildCategoryRow() {
    final list = ["All", "House", "Villa", "Apartment", "Office"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: list.map((cat) => Padding(
          padding: const EdgeInsets.only(right: 10),
          child: _buildCategoryChip(cat),
        )).toList(),
      ),
    );
  }

  Widget _buildPriceLabels() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("EGP ${priceRange.start.round()}M", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          Text("EGP ${priceRange.end.round()}M", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
    );
  }

  Widget _buildApplyButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        onPressed: () {
          // تحويل الملايين لأرقام كاملة للسيرفر
          double minP = priceRange.start * 1000000;
          double maxP = priceRange.end * 1000000;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchResultsScreen(
                category: selectedCategory == 'All' ? null : selectedCategory,
                minPrice: minP,
                maxPrice: maxP,
                beds: selectedBeds == 'Any' ? null : selectedBeds.replaceAll('+', ''),
                baths: selectedBaths == 'Any' ? null : selectedBaths.replaceAll('+', ''),
              ),
            ),
          );
        },
        child: const Text("Apply Filters", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- دوال الـ Widget المساعدة (كما هي مع تحسين بسيط في الاستايل) ---
  Widget _buildCategoryChip(String title) {
    bool isSelected = selectedCategory == title;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade200),
        ),
        child: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[600], fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSelectionRow(List<String> options, String current, Function(String) onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: options.map((opt) {
        bool isSelected = opt == current;
        return GestureDetector(
          onTap: () => onTap(opt),
          child: Container(
            width: 60, height: 50,
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade200),
            ),
            child: Center(child: Text(opt, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold))),
          ),
        );
      }).toList(),
    );
  }
}