import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/parking_lot_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../utils/app_constants.dart';
import 'dart:convert';

class ParkingLotsScreen extends StatefulWidget {
  const ParkingLotsScreen({super.key});

  @override
  State<ParkingLotsScreen> createState() => _ParkingLotsScreenState();
}

class _ParkingLotsScreenState extends State<ParkingLotsScreen> {
  final authService = AuthService();
  final apiService = ApiService();

  List<ParkingLot> parkingLots = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  
  bool isMapView = false;
  GoogleMapController? mapController;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final lots = await apiService.getAllParkingLots();

      if (lots.isEmpty) {
        await _addSampleData();
      } else {
        if (mounted) {
          setState(() {
            parkingLots = lots;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('❌ initializeData error: $e');
      if (mounted) {
        setState(() {
          hasError = true;
          errorMessage = 'ไม่สามารถเชื่อมต่อ server ได้\n$e';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _addSampleData() async {
    print('📝 Adding sample parking lot data...');

    // Sample Data
    final sampleLotsData = [
      {
        'name': 'Cinema Park',
        'address': 'ถนนรัชดา เขตพระนคร กรุงเทพ',
        'rating': 4.8,
        'totalSpots': 50,
        'availableSpots': 20,
        'operatedBy': 'Cinema Park Management',
        'image': 'assets/image/cinema.jpg',
        'latitude': 13.7663,
        'longitude': 100.5618,
      },
      {
        'name': 'Shopping Mall Spot',
        'address': 'ถนนวิทยุ เขตปทุมวัน กรุงเทพ',
        'rating': 4.5,
        'totalSpots': 100,
        'availableSpots': 45,
        'operatedBy': 'Shopping Mall Management',
        'image': 'assets/image/shoppingmall.jpg',
        'latitude': 13.7431,
        'longitude': 100.5471,
      },
      {
        'name': 'Market Spot',
        'address': 'ถนนราชดำเนิน เขตพระนคร กรุงเทพ',
        'rating': 4.2,
        'totalSpots': 60,
        'availableSpots': 25,
        'operatedBy': 'Market Management',
        'image': 'assets/image/market.JPG',
        'latitude': 13.7568,
        'longitude': 100.5019,
      },
      {
        'name': 'Home Ground Spot',
        'address': 'ถนนสุขุมวิท เขตวัฒนา กรุงเทพ',
        'rating': 4.7,
        'totalSpots': 80,
        'availableSpots': 35,
        'operatedBy': 'Home Ground Management',
        'image': 'assets/image/home ground.jpg',
        'latitude': 13.7367,
        'longitude': 100.5815,
      },
    ];

    int successCount = 0;
    for (var data in sampleLotsData) {
      try {
        final lot = ParkingLot(
          id: 0,
          name: data['name'] as String,
          address: data['address'] as String,
          image: data['image'] as String,
          rating: data['rating'] as double,
          totalSpots: data['totalSpots'] as int,
          availableSpots: data['availableSpots'] as int,
          operatedBy: data['operatedBy'] as String,
          latitude: data['latitude'] as double,
          longitude: data['longitude'] as double,
        );
        await apiService.insertParkingLot(lot);
        successCount++;
        print('✅ Inserted: ${lot.name}');
      } catch (e) {
        print('⚠️ Could not insert ${data['name']}: $e');
      }
    }

    print('📊 Inserted $successCount/${sampleLotsData.length} lots');

    final lots = await apiService.getAllParkingLots();
    if (mounted) {
      setState(() {
        parkingLots = lots;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ค้นหาที่จอดรถ', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.dark,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isMapView ? Icons.list : Icons.map),
            onPressed: () {
              setState(() {
                isMapView = !isMapView;
              });
            },
            tooltip: isMapView ? 'มุมมองรายการ' : 'มุมมองแผนที่',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).pushNamed('/booking-history');
            },
            tooltip: 'ประวัติการจอด',
          ),
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.white),
                    SizedBox(width: 8),
                    Text(AppStrings.logout),
                  ],
                ),
              ),
            ],
            onSelected: (String value) {
              if (value == 'logout') {
                authService.logout();
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      backgroundColor: AppColors.backgroundColor,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('กำลังโหลดข้อมูล...', style: AppStyles.bodyText),
          ],
        ),
      );
    }

    if (hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 64, color: AppColors.errorColor),
              const SizedBox(height: 16),
              const Text('เชื่อมต่อ Server ไม่ได้', style: AppStyles.headingMedium),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: AppStyles.bodyTextSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _initializeData,
                icon: const Icon(Icons.refresh),
                label: const Text('ลองใหม่'),
              ),
            ],
          ),
        ),
      );
    }

    if (parkingLots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_parking, size: 64, color: AppColors.lightgray),
            const SizedBox(height: 16),
            const Text('ไม่มีข้อมูลลานจอดรถ', style: AppStyles.bodyText),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _initializeData,
              icon: const Icon(Icons.refresh),
              label: const Text('รีโหลด'),
            ),
          ],
        ),
      );
    }

    if (isMapView) {
      return _buildMapView();
    }

    return RefreshIndicator(
      onRefresh: _initializeData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'พิมพ์ที่จอดรถที่ต้องการ',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: const Icon(Icons.filter_list),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
              const SizedBox(height: 24),
              
              // Recommended Section
              const Text(
                'แนะนำสำหรับคุณ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 260,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: parkingLots.length > 3 ? 3 : parkingLots.length,
                  itemBuilder: (context, index) {
                    return _buildHorizontalLotCard(parkingLots[index]);
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              // All Parking Lots Section
              const Text(
                'สถานที่จอดรถทั้งหมด',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: parkingLots.length,
                itemBuilder: (context, index) {
                  return _buildVerticalLotCard(parkingLots[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapView() {
    bool isSupported = kIsWeb || (!kIsWeb && (Platform.isAndroid || Platform.isIOS));
    
    if (!isSupported) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_outlined, size: 64, color: AppColors.lightgray),
            const SizedBox(height: 16),
            const Text('ไม่รองรับแผนที่บน Windows Desktop', style: AppStyles.headingMedium),
            const SizedBox(height: 8),
            const Text(
              'โปรดรันแอปบน Chrome หรือมือถือเพื่อใช้งานฟังก์ชันแผนที่',
              style: AppStyles.bodyTextSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isMapView = false;
                });
              },
              child: const Text('กลับไปมุมมองรายการ'),
            ),
          ],
        ),
      );
    }

    Set<Marker> markers = parkingLots.map((lot) {
      return Marker(
        markerId: MarkerId(lot.id.toString()),
        position: LatLng(lot.latitude, lot.longitude),
        infoWindow: InfoWindow(
          title: lot.name,
          snippet: 'เหลือ ${lot.availableSpots} ที่',
          onTap: () {
            Navigator.of(context).pushNamed('/parking-spots', arguments: lot);
          },
        ),
      );
    }).toSet();

    CameraPosition initialCameraPosition = const CameraPosition(
      target: LatLng(13.7563, 100.5018), // BKK default
      zoom: 12,
    );

    if (parkingLots.isNotEmpty) {
      initialCameraPosition = CameraPosition(
        target: LatLng(parkingLots[0].latitude, parkingLots[0].longitude),
        zoom: 12,
      );
    }

    return GoogleMap(
      initialCameraPosition: initialCameraPosition,
      markers: markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      onMapCreated: (GoogleMapController controller) {
        mapController = controller;
      },
    );
  }

  Widget _buildHorizontalLotCard(ParkingLot lot) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/parking-spots', arguments: lot);
      },
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildLotImage(lot.image),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          lot.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 16),
                          const SizedBox(width: 4),
                          Text(lot.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(lot.address, style: const TextStyle(color: AppColors.charcoal, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'เหลือ ${lot.availableSpots} ที่',
                        style: TextStyle(
                          color: lot.availableSpots > 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('จองเลย', style: TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.bold)),
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

  Widget _buildVerticalLotCard(ParkingLot lot) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/parking-spots', arguments: lot);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildLotImage(lot.image),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          lot.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 18),
                          const SizedBox(width: 4),
                          Text(lot.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(lot.address, style: const TextStyle(color: AppColors.charcoal, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'เหลือ ${lot.availableSpots} ที่',
                        style: TextStyle(
                          color: lot.availableSpots > 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text('จองเลย', style: TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.bold)),
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

  // แสดงรูปภาพ
  Widget _buildLotImage(String imageString) {
    if (imageString.isEmpty) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_parking, size: 60, color: AppColors.primaryColor),
          SizedBox(height: 8),
          Text('No Image', style: TextStyle(color: AppColors.lightgray)),
        ],
      );
    } else if (imageString.startsWith('assets/')) {
      return Image.asset(
        imageString,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.broken_image, size: 50, color: AppColors.lightgray),
          );
        },
      );
    } else {
      try {
        return Image.memory(
          base64Decode(imageString),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.broken_image, size: 50, color: AppColors.lightgray),
            );
          },
        );
      } catch (e) {
        return const Center(
          child: Icon(Icons.error, color: AppColors.errorColor),
        );
      }
    }
  }
}
