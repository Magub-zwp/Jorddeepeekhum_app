// ไฟล์สำหรับหน้าเลือกช่องจอด (Parking Spots Screen)
import 'package:flutter/material.dart';
import '../models/parking_lot_model.dart';
import '../models/parking_spot_model.dart';
import '../services/api_service.dart';
import '../utils/app_constants.dart';

class ParkingSpotsScreen extends StatefulWidget {
  const ParkingSpotsScreen({super.key});

  @override
  State<ParkingSpotsScreen> createState() => _ParkingSpotsScreenState();
}

class _ParkingSpotsScreenState extends State<ParkingSpotsScreen> {
  final apiService = ApiService();

  ParkingLot? parkingLot;
  List<ParkingSpot> parkingSpots = [];
  ParkingSpot? selectedSpot;
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (parkingLot == null) {
      _loadData();
    }
  }

  void _loadData() async {
    final lot = ModalRoute.of(context)!.settings.arguments as ParkingLot;

    setState(() {
      parkingLot = lot;
      isLoading = true;
    });

    final spots = await apiService.getParkingSpotsByLotId(lot.id);

    if (spots.isEmpty) {
      await _addSampleSpots(lot);
    } else {
      setState(() {
        parkingSpots = spots;
        isLoading = false;
      });
    }
  }

  Future<void> _addSampleSpots(ParkingLot lot) async {
    // ✅ สร้าง spot data โดยไม่ใส่ id (API จะ generate เอง)
    final spotsData = [
      // แถว A
      {'spotNumber': 'A01', 'floor': 'ชั้น 1', 'isAvailable': true, 'positionX': 10.0, 'positionY': 10.0},
      {'spotNumber': 'A02', 'floor': 'ชั้น 1', 'isAvailable': true, 'positionX': 50.0, 'positionY': 10.0},
      {'spotNumber': 'A03', 'floor': 'ชั้น 1', 'isAvailable': false, 'positionX': 90.0, 'positionY': 10.0},
      // แถว B
      {'spotNumber': 'B01', 'floor': 'ชั้น 1', 'isAvailable': true, 'positionX': 10.0, 'positionY': 50.0},
      {'spotNumber': 'B02', 'floor': 'ชั้น 1', 'isAvailable': false, 'positionX': 50.0, 'positionY': 50.0},
      {'spotNumber': 'B03', 'floor': 'ชั้น 1', 'isAvailable': true, 'positionX': 90.0, 'positionY': 50.0},
      // แถว C
      {'spotNumber': 'C01', 'floor': 'ชั้น 1', 'isAvailable': true, 'positionX': 10.0, 'positionY': 90.0},
      {'spotNumber': 'C02', 'floor': 'ชั้น 1', 'isAvailable': true, 'positionX': 50.0, 'positionY': 90.0},
      {'spotNumber': 'C03', 'floor': 'ชั้น 1', 'isAvailable': false, 'positionX': 90.0, 'positionY': 90.0},
    ];

    print('📝 Creating ${spotsData.length} sample parking spots...');
    
    for (var data in spotsData) {
      try {
        // ✅ สร้าง ParkingSpot ด้วย id = 0 (API จะ generate)
        final spot = ParkingSpot(
          id: 0,
          parkingLotId: lot.id,
          spotNumber: data['spotNumber'] as String,
          floor: data['floor'] as String,
          isAvailable: data['isAvailable'] as bool,
          positionX: data['positionX'] as double,
          positionY: data['positionY'] as double,
        );
        await apiService.insertParkingSpot(spot);
        print('✅ Created spot: ${spot.spotNumber}');
      } catch (e) {
        print('⚠️ insertParkingSpot error (${data['spotNumber']}): $e');
      }
    }

    // โหลดใหม่จาก API
    final spots = await apiService.getParkingSpotsByLotId(lot.id);

    if (mounted) {
      setState(() {
        parkingSpots = spots;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(parkingLot?.name ?? AppStrings.selectParkingSpot),
        backgroundColor: AppColors.primaryColor,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ข้อมูลสถานที่
                if (parkingLot != null)
                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(parkingLot!.name, style: AppStyles.headingMedium),
                        const SizedBox(height: 4),
                        Text(parkingLot!.address, style: AppStyles.bodyTextSmall),
                      ],
                    ),
                  ),
                // Legend
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMedium),
                  child: Row(
                    children: [
                      _buildLegend(AppColors.availableColor, 'ว่าง'),
                      const SizedBox(width: 16),
                      _buildLegend(AppColors.occupiedColor, 'ไม่ว่าง'),
                      const SizedBox(width: 16),
                      _buildLegend(AppColors.selectedColor, 'เลือกแล้ว'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(),
                // กริดช่องจอด
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: parkingSpots.length,
                    itemBuilder: (context, index) {
                      final spot = parkingSpots[index];
                      final isSelected = selectedSpot?.id == spot.id;

                      Color spotColor = AppColors.availableColor;
                      if (!spot.isAvailable) {
                        spotColor = AppColors.occupiedColor;
                      } else if (isSelected) {
                        spotColor = AppColors.selectedColor;
                      }

                      return GestureDetector(
                        onTap: () {
                          if (spot.isAvailable) {
                            setState(() {
                              selectedSpot = spot;
                            });
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: spotColor,
                            borderRadius: BorderRadius.circular(
                                AppDimensions.borderRadiusMedium),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.white
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  spot.isAvailable
                                      ? Icons.directions_car_outlined
                                      : Icons.directions_car,
                                  color: AppColors.white,
                                  size: AppDimensions.iconSizeLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  spot.spotNumber,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: selectedSpot != null
          ? Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    '/vehicle-details',
                    arguments: {
                      'parkingLot': parkingLot,
                      'parkingSpot': selectedSpot,
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        AppDimensions.borderRadiusMedium),
                  ),
                ),
                child: Text(
                  'ถัดไป → ช่อง ${selectedSpot!.spotNumber}',
                  style: AppStyles.buttonText,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppStyles.bodyTextSmall),
      ],
    );
  }
}
