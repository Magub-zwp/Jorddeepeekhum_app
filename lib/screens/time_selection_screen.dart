import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/parking_lot_model.dart';
import '../models/parking_spot_model.dart';
import '../models/vehicle_model.dart';
import '../services/pricing_service.dart';
import '../utils/app_constants.dart';

class TimeSelectionScreen extends StatefulWidget {
  const TimeSelectionScreen({super.key});
  @override
  State<TimeSelectionScreen> createState() => _TimeSelectionScreenState();
}

class _TimeSelectionScreenState extends State<TimeSelectionScreen> {
  ParkingLot? parkingLot;
  ParkingSpot? parkingSpot;
  Vehicle? vehicle;
  
  DateTime? startTime;
  DateTime? endTime;
  bool _dataLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dataLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null) {
        parkingLot = args['parkingLot'] as ParkingLot;
        parkingSpot = args['parkingSpot'] as ParkingSpot;
        vehicle = args['vehicle'] as Vehicle;
        
        // ตั้งค่าเริ่มต้น
        startTime = args['startTime'] as DateTime? ?? DateTime.now();
        endTime = args['endTime'] as DateTime? ?? startTime!.add(const Duration(hours: 3));
      }
      _dataLoaded = true;
    }
  }

  Future<void> _selectDateTime(bool isStartTime) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartTime ? (startTime ?? DateTime.now()) : (endTime ?? DateTime.now().add(const Duration(hours: 3))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryColor,
              onPrimary: AppColors.white,
              surface: AppColors.charcoal,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isStartTime ? (startTime ?? DateTime.now()) : (endTime ?? DateTime.now())),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primaryColor,
                onPrimary: AppColors.white,
                surface: AppColors.charcoal,
                onSurface: AppColors.textPrimary,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null && mounted) {
        final selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          if (isStartTime) {
            startTime = selectedDateTime;
            // ถ้าเวลาออกน้อยกว่าเวลาเข้า ให้ปรับเวลาออกให้ถูกต้อง
            if (endTime != null && endTime!.isBefore(startTime!)) {
              endTime = startTime!.add(const Duration(hours: 1));
            }
          } else {
            endTime = selectedDateTime;
          }
        });
      }
    }
  }

  void _handleNext() {
    if (startTime == null || endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกเวลาเข้าและออก')),
      );
      return;
    }

    if (endTime!.isBefore(startTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เวลาออกต้องมากกว่าเวลาเข้า')),
      );
      return;
    }

    final duration = endTime!.difference(startTime!);
    if (duration.inMinutes < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ระยะเวลาจอดต้องมากกว่า 1 นาที')),
      );
      return;
    }

    Navigator.of(context).pushNamed('/payment', arguments: {
      'parkingLot': parkingLot,
      'parkingSpot': parkingSpot,
      'vehicle': vehicle,
      'startTime': startTime,
      'endTime': endTime,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (parkingLot == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final totalPrice = startTime != null && endTime != null
        ? PricingService.calculatePrice(startTime: startTime!, endTime: endTime!)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('เลือกเวลาจอดรถ', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.dark,
        elevation: 0,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ข้อมูลที่เลือก
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.local_parking, color: AppColors.primaryBlue),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(parkingLot!.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.dark)),
                              const SizedBox(height: 4),
                              Text('ช่องจอด: ${parkingSpot!.spotNumber}', style: const TextStyle(color: AppColors.charcoal, fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1, color: AppColors.lightgray),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.lightgray.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.directions_car, color: AppColors.charcoal),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            '${vehicle!.licensePlate} • ${vehicle!.brand} ${vehicle!.model}',
                            style: const TextStyle(fontSize: 14, color: AppColors.dark, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // เลือกเวลาเข้า
              const Text('เวลาเข้า', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.dark)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDateTime(true),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.lightgray.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.charcoal, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          startTime != null
                              ? DateFormat('dd MMM yyyy, HH:mm').format(startTime!)
                              : 'กดเพื่อเลือกเวลา',
                          style: const TextStyle(fontSize: 14, color: AppColors.dark, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: AppColors.charcoal),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // เลือกเวลาออก
              const Text('เวลาออก', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.dark)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDateTime(false),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.lightgray.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.charcoal, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          endTime != null
                              ? DateFormat('dd MMM yyyy, HH:mm').format(endTime!)
                              : 'กดเพื่อเลือกเวลา',
                          style: const TextStyle(fontSize: 14, color: AppColors.dark, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: AppColors.charcoal),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // แสดงระยะเวลาและราคา
              if (startTime != null && endTime != null)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('สรุป', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.dark)),
                      const SizedBox(height: 16),
                      _summaryRow(
                        'ระยะเวลา',
                        PricingService.calculateDuration(
                          startTime: startTime!,
                          endTime: endTime!,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _summaryRow(
                        'ราคา',
                        PricingService.formatPrice(totalPrice),
                        valueColor: AppColors.primaryBlue,
                        isBold: true,
                      ),
                      if (PricingService.isFreeParking(startTime: startTime!, endTime: endTime!))
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'ชั่วโมงแรกฟรี!',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 100), // padding for bottom button
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: double.infinity,
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
        child: ElevatedButton(
          onPressed: _handleNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text('ดำเนินการต่อ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white)),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.charcoal, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppColors.dark,
          ),
        ),
      ],
    );
  }
}
