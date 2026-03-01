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
        startTime = DateTime.now();
        endTime = startTime!.add(const Duration(hours: 3));
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
        title: const Text('เลือกเวลาจอดรถ'),
        backgroundColor: AppColors.primaryColor,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ข้อมูลที่เลือก
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.local_parking, color: AppColors.primaryColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(parkingLot!.name, style: AppStyles.headingMedium),
                                Text('ช่องจอด: ${parkingSpot!.spotNumber}', style: AppStyles.bodyTextSmall),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          const Icon(Icons.directions_car, color: AppColors.accentColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${vehicle!.licensePlate} • ${vehicle!.brand} ${vehicle!.model}',
                              style: AppStyles.bodyText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // เลือกเวลาเข้า
              const Text('เวลาเข้า', style: AppStyles.headingMedium),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDateTime(true),
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppColors.charcoal,
                    borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                    border: Border.all(color: AppColors.lightgray),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.accentColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          startTime != null
                              ? DateFormat('dd/MM/yyyy HH:mm').format(startTime!)
                              : 'กดเพื่อเลือกเวลา',
                          style: AppStyles.bodyText,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: AppColors.lightgray),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // เลือกเวลาออก
              const Text('เวลาออก', style: AppStyles.headingMedium),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDateTime(false),
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppColors.charcoal,
                    borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                    border: Border.all(color: AppColors.lightgray),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.accentColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          endTime != null
                              ? DateFormat('dd/MM/yyyy HH:mm').format(endTime!)
                              : 'กดเพื่อเลือกเวลา',
                          style: AppStyles.bodyText,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: AppColors.lightgray),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // แสดงระยะเวลาและราคา
              if (startTime != null && endTime != null)
                Card(
                  color: AppColors.charcoal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('สรุป', style: AppStyles.headingMedium),
                        const Divider(height: 24),
                        _summaryRow(
                          'ระยะเวลา',
                          PricingService.calculateDuration(
                            startTime: startTime!,
                            endTime: endTime!,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _summaryRow(
                          'ราคา',
                          PricingService.formatPrice(totalPrice),
                          valueColor: AppColors.successColor,
                        ),
                        if (PricingService.isFreeParking(startTime: startTime!, endTime: endTime!))
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                            decoration: BoxDecoration(
                              color: AppColors.successColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle, color: AppColors.successColor, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'ชั่วโมงแรกฟรี!',
                                    style: TextStyle(
                                      color: AppColors.successColor,
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
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: ElevatedButton(
          onPressed: _handleNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
            ),
          ),
          child: const Text('ถัดไป', style: AppStyles.buttonText),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppStyles.bodyText),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
