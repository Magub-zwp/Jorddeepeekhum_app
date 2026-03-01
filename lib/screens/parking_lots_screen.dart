import 'package:flutter/material.dart';
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

    // ✅ FIX BUG 4: แก้ image path ให้ตรงกับ pubspec.yaml และชื่อไฟล์จริง
    final sampleLotsData = [
      {
        'name': 'Cinema Park',
        'address': 'ถนนรัชดา เขตพระนคร กรุงเทพ',
        'rating': 4.8,
        'totalSpots': 50,
        'availableSpots': 20,
        'operatedBy': 'Cinema Park Management',
        'image': 'assets/images/cinema.jpg',         // ✅ ตรงกับ pubspec
      },
      {
        'name': 'Shopping Mall Spot',
        'address': 'ถนนวิทยุ เขตปทุมวัน กรุงเทพ',
        'rating': 4.5,
        'totalSpots': 100,
        'availableSpots': 45,
        'operatedBy': 'Shopping Mall Management',
        'image': 'assets/images/shoppingmall.jpg',   // ✅ ตรงกับ pubspec
      },
      {
        'name': 'Market Spot',
        'address': 'ถนนราชดำเนิน เขตพระนคร กรุงเทพ',
        'rating': 4.2,
        'totalSpots': 60,
        'availableSpots': 25,
        'operatedBy': 'Market Management',
        'image': 'assets/images/market.jpg',         // ✅ ตรงกับ pubspec
      },
      {
        'name': 'Home Ground Spot',
        'address': 'ถนนสุขุมวิท เขตวัฒนา กรุงเทพ',
        'rating': 4.7,
        'totalSpots': 80,
        'availableSpots': 35,
        'operatedBy': 'Home Ground Management',
        'image': 'assets/images/home_ground.jpg',    // ✅ ตรงกับ pubspec
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
        title: const Text(AppStrings.selectParking),
        backgroundColor: AppColors.primaryColor,
        actions: [
          // ปุ่มประวัติการจอด
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
              const SizedBox(height: 12),
              const Text(
                '💡 ตรวจสอบว่า Apache/MySQL กำลังรันอยู่',
                style: AppStyles.bodyTextSmall,
                textAlign: TextAlign.center,
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

    return RefreshIndicator(
      onRefresh: _initializeData,
      child: ListView.builder(
        itemCount: parkingLots.length,
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        itemBuilder: (context, index) {
          final lot = parkingLots[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed('/parking-spots', arguments: lot);
            },
            child: Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.charcoal,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppDimensions.borderRadiusLarge),
                        topRight: Radius.circular(AppDimensions.borderRadiusLarge),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildLotImage(lot.image),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lot.name, style: AppStyles.headingMedium),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: AppColors.lightgray),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(lot.address, style: AppStyles.bodyTextSmall),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star, color: AppColors.accentColor, size: 16),
                                const SizedBox(width: 4),
                                Text(lot.rating.toStringAsFixed(1), style: AppStyles.bodyTextSmall),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: lot.availableSpots > 0
                                    ? AppColors.successColor.withOpacity(0.2)
                                    : AppColors.errorColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${lot.availableSpots}/${lot.totalSpots} ว่าง',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: lot.availableSpots > 0
                                      ? AppColors.successColor
                                      : AppColors.errorColor,
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
            ),
          );
        },
      ),
    );
  }

  // ✅ แสดงรูปภาพ: รองรับ Asset path และ Base64 (จาก DB)
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
      // ✅ แสดงรูปจาก assets
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
      // ✅ แสดงรูปจาก Base64 (ถ้า DB เก็บไว้)
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
