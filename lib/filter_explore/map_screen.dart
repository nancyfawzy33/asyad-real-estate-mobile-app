import 'package:flutter/material.dart';


class Estate {
  final int id;
  final String title;
  final String imagePath;
  final String location;
  final String price;
  final int beds;
  final int baths;
  final int area;
  final double top;
  final double left;

  Estate({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.location,
    required this.price,
    required this.beds,
    required this.baths,
    required this.area,
    required this.top,
    required this.left,
  });
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int _selectedIndex = 1;


  final List<Estate> estates = [
    Estate(
      id: 1,
      title: "Grand Villa",
      imagePath: "assets/images/house1.png",
      location: "New Cairo, 5th Settlement",
      price: "EGP 12.5M",
      beds: 5,
      baths: 3,
      area: 600,
      top: 350,
      left: 140,
    ),
    Estate(
      id: 2,
      title: "Modern House",
      imagePath: "assets/images/house2.png",
      location: "New Cairo, Waterway",
      price: "EGP 8.2M",
      beds: 4,
      baths: 2,
      area: 450,
      top: 220,
      left: 230,
    ),
    Estate(
      id: 3,
      title: "Luxury Penthouse",
      imagePath: "assets/images/house3.png",
      location: "New Cairo, Mivida",
      price: "EGP 15.0M",
      beds: 6,
      baths: 4,
      area: 800,
      top: 420,
      left: 60,
    ),
    Estate(
      id: 4,
      title: "Royal Villa",
      imagePath: "assets/images/house4.png",
      location: "New Cairo, Hyde Park",
      price: "EGP 21.0M",
      beds: 7,
      baths: 5,
      area: 1100,
      top: 150,
      left: 320,
    ),
  ];

  late Estate selectedEstate;

  @override
  void initState() {
    super.initState();
    selectedEstate = estates[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          Container(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/images/maps.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Text(
                      "خريطة غير متوفرة",
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  ),
                );
              },
            ),
          ),


          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                height: 55,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.black),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "New Cairo",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const VerticalDivider(indent: 15, endIndent: 15),
                    const Icon(Icons.tune, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),


          ...estates.map((estate) => _buildMapPriceTag(estate)).toList(),


          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: _buildPropertyCard(),
          ),
        ],
      ),
        );
  }


  Widget _buildMapPriceTag(Estate estate) {
    bool isActive = selectedEstate.id == estate.id;
    return Positioned(
      top: estate.top,
      left: estate.left,
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedEstate = estate;
          });
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Text(
                estate.price.replaceAll("EGP ", ""),
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: isActive ? Colors.black : Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildPropertyCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              selectedEstate.imagePath,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(width: 90, height: 90, color: Colors.blue.shade50, child: const Icon(Icons.image)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedEstate.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  selectedEstate.location,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.king_bed_outlined, size: 16, color: Colors.grey),
                    Text(" ${selectedEstate.beds} Beds ", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(width: 8),
                    const Icon(Icons.bathtub_outlined, size: 16, color: Colors.grey),
                    Text(" ${selectedEstate.baths} Baths", style: const TextStyle(color: Colors.grey, fontSize: 12)), // ✅ هنا
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  selectedEstate.price,
                  style: const TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }
}