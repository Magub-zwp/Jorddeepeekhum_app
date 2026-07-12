// ไฟล์สำหรับหน้าเลือกช่องจอด (Parking Spots Screen)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  DateTime? selectedStartTime;
  DateTime? selectedEndTime;
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

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? startTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        helpText: 'เลือกเวลาเข้า',
      );

      if (startTime != null && mounted) {
        final TimeOfDay? endTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: (startTime.hour + 2) % 24, minute: startTime.minute),
          helpText: 'เลือกเวลาออก',
        );

        if (endTime != null && mounted) {
          setState(() {
            selectedStartTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              startTime.hour,
              startTime.minute,
            );
            
            selectedEndTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              endTime.hour,
              endTime.minute,
            );
            
            if (selectedEndTime!.isBefore(selectedStartTime!)) {
              selectedEndTime = selectedEndTime!.add(const Duration(days: 1));
            }
            
            // เช็คว่าถ้าช่องที่เลือกไว้ไม่ว่างในเวลาใหม่ ให้ยกเลิกการเลือก
            if (selectedSpot != null && !_isSpotAvailable(selectedSpot!)) {
              selectedSpot = null;
            }
          });
        }
      }
    }
  }

  bool _isSpotAvailable(ParkingSpot spot) {
    if (selectedStartTime == null) return spot.isAvailable;
    
    int seed = spot.id + selectedStartTime!.day + selectedStartTime!.hour;
    
    if (spot.floor.contains('1')) {
      return (seed % 2) != 0;
    } else {
      return (seed % 3) != 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เลือกช่องจอด', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.dark,
        elevation: 0,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Date/Time Selector
                InkWell(
                  onTap: _selectDateTime,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today, color: AppColors.charcoal, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          selectedStartTime != null && selectedEndTime != null
                              ? '${DateFormat('MMM dd, HH:mm').format(selectedStartTime!)} - ${DateFormat('HH:mm').format(selectedEndTime!)}'
                              : 'เลือกวันและเวลาจอด',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.edit, color: AppColors.primaryBlue, size: 20),
                      ],
                    ),
                  ),
                ),
                
                // Legend
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegend(Colors.green, 'ว่าง'),
                      const SizedBox(width: 16),
                      _buildLegend(Colors.red, 'ถูกจองแล้ว'),
                      const SizedBox(width: 16),
                      _buildLegend(AppColors.primaryBlue, 'กำลังเลือก'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // กริดช่องจอด
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: InteractiveViewer(
                      boundaryMargin: const EdgeInsets.all(100),
                      minScale: 0.5,
                      maxScale: 3.0,
                      child: Stack(
                        children: [
                          // พื้นหลังถนน/เลน (Visual Only)
                          Positioned(
                            top: 40,
                            bottom: 40,
                            left: 120,
                            width: 60,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.lightgray.withOpacity(0.3),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(Icons.arrow_upward, color: AppColors.charcoal, size: 24),
                                  Icon(Icons.arrow_downward, color: AppColors.charcoal, size: 24),
                                ],
                              ),
                            ),
                          ),
                          
                          // ช่องจอดต่างๆ
                          ...parkingSpots.map((spot) {
                            final isSelected = selectedSpot?.id == spot.id;

                            Color spotColor = Colors.green.withOpacity(0.1);
                            Color borderColor = Colors.green;
                            Color textColor = Colors.green;
                            
                            bool isAvail = _isSpotAvailable(spot);

                            if (!isAvail) {
                              spotColor = Colors.red.withOpacity(0.1);
                              borderColor = Colors.red;
                              textColor = Colors.red;
                            } else if (isSelected) {
                              spotColor = AppColors.primaryBlue;
                              borderColor = AppColors.primaryBlue;
                              textColor = AppColors.white;
                            }

                            // กำหนดขนาดจำลองของช่องจอด
                            const double spotWidth = 80.0;
                            const double spotHeight = 100.0;

                            // จัดตำแหน่งให้สวยงาม
                            double drawX = spot.positionX;
                            double drawY = spot.positionY;
                            
                            if (spot.spotNumber.startsWith('A')) {
                              drawX = 20;
                              drawY = 20 + (int.parse(spot.spotNumber.substring(1)) - 1) * 120.0;
                            } else if (spot.spotNumber.startsWith('B')) {
                              drawX = 200;
                              drawY = 20 + (int.parse(spot.spotNumber.substring(1)) - 1) * 120.0;
                            } else if (spot.spotNumber.startsWith('C')) {
                              drawX = 300;
                              drawY = 20 + (int.parse(spot.spotNumber.substring(1)) - 1) * 120.0;
                            }

                            return Positioned(
                              left: drawX,
                              top: drawY,
                              width: spotWidth,
                              height: spotHeight,
                              child: GestureDetector(
                                onTap: () {
                                  if (_isSpotAvailable(spot)) {
                                    setState(() {
                                      selectedSpot = spot;
                                    });
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: spotColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: borderColor, width: 2),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _isSpotAvailable(spot)
                                              ? Icons.local_parking
                                              : Icons.directions_car,
                                          color: textColor,
                                          size: 28,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          spot.spotNumber,
                                          style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: selectedSpot != null
          ? Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('1 ที่', style: TextStyle(color: AppColors.charcoal, fontSize: 14)),
                        const SizedBox(height: 4),
                        const Text('\$2/hr', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryBlue)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          '/vehicle-details',
                          arguments: {
                            'parkingLot': parkingLot,
                            'parkingSpot': selectedSpot,
                            'startTime': selectedStartTime,
                            'endTime': selectedEndTime,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('ดำเนินการต่อ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
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
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.charcoal)),
      ],
    );
  }
}
