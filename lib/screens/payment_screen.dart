import 'package:flutter/material.dart';
import '../models/parking_lot_model.dart';
import '../models/parking_spot_model.dart';
import '../models/vehicle_model.dart';
import '../models/booking_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/pricing_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_utils.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final authService = AuthService();
  final apiService = ApiService();

  ParkingLot? parkingLot;
  ParkingSpot? parkingSpot;
  Vehicle? vehicle;
  late DateTime startTime;
  late DateTime endTime;
  late double totalPrice;
  bool isLoading = false;
  bool _dataLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dataLoaded) {
      _loadData();
      _dataLoaded = true;
    }
  }

  void _loadData() {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args == null) return;

    parkingLot = args['parkingLot'] as ParkingLot;
    parkingSpot = args['parkingSpot'] as ParkingSpot;
    vehicle = args['vehicle'] as Vehicle;
    startTime = args['startTime'] as DateTime;
    endTime = args['endTime'] as DateTime;
    
    totalPrice = PricingService.calculatePrice(startTime: startTime, endTime: endTime);
  }

  void _handlePayment() async {
    if (parkingLot == null || parkingSpot == null || vehicle == null) return;
    if (authService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session หมดอายุ กรุณา login ใหม่')),
      );
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    setState(() => isLoading = true);

    try {
      // ✅ ไม่ต้องสร้าง UUID - ใช้ int id = 0 (จะได้จาก API)
      final booking = Booking(
        id: 0,  // ✅ ใช้ 0 แทน UUID
        visitNumber: '',  // ✅ จะได้จาก API
        userId: authService.currentUser!.id,
        vehicleId: vehicle!.id,
        parkingLotId: parkingLot!.id,
        parkingSpotId: parkingSpot!.id,
        startTime: startTime,
        endTime: endTime,
        totalPrice: totalPrice,
        status: 'paid',
      );

      // ✅ insertBooking return Map แทน String
      final result = await apiService.insertBooking(booking);
      final bookingId = result['id'] as int;
      final visitNumber = result['visit_number'] as String;
      
      print('✅ Booking saved!');
      print('   ID: $bookingId');
      print('   Visit Number: $visitNumber');
      
      // อัปเดตช่องจอดเป็นไม่ว่าง
      await apiService.updateParkingSpotAvailability(parkingSpot!.id, false);
      print('✅ Parking spot updated');

      if (mounted) {
        Navigator.of(context).pushReplacementNamed(
          '/booking-confirmation', 
          arguments: booking.copyWith(
            id: bookingId,
            visitNumber: visitNumber,
          ),
        );
      }
    } catch (e) {
      print('❌ Payment error: $e');
      print('Error type: ${e.runtimeType}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: ${e.toString()}'),
            duration: const Duration(seconds: 5),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (parkingLot == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.payment),
        backgroundColor: AppColors.primaryColor,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // สรุปการจอด
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge)),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('สรุปการจองรถ', style: AppStyles.headingMedium),
                      const Divider(),
                      _detail('สถานที่', parkingLot!.name),
                      _detail('ช่องจอด', parkingSpot!.spotNumber),
                      _detail('ทะเบียนรถ', vehicle!.licensePlate),
                      _detail('รถยนต์', '${vehicle!.brand} ${vehicle!.model}'),
                      _detail('สี', vehicle!.color),
                      _detail('เข้า', AppUtils.formatDateTime(startTime)),
                      _detail('ออก', AppUtils.formatDateTime(endTime)),
                      _detail('ระยะเวลา', PricingService.calculateDuration(startTime: startTime, endTime: endTime)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // ราคา
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge)),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('ราคา', style: AppStyles.headingMedium),
                      const Divider(),
                      _price(AppStrings.parkingPrice, totalPrice),
                      _price(AppStrings.serviceFee, 0.0),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(AppStrings.totalPrice, style: AppStyles.headingMedium),
                          Text(
                            PricingService.formatPrice(totalPrice),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.successColor),
                          ),
                        ],
                      ),
                      if (PricingService.isFreeParking(startTime: startTime, endTime: endTime))
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                          decoration: BoxDecoration(
                            color: AppColors.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                          ),
                          child: const Text('ชั่วโมงแรกฟรี!',
                              style: TextStyle(color: AppColors.successColor, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: ElevatedButton(
          onPressed: isLoading ? null : _handlePayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.successColor,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium)),
          ),
          child: isLoading
              ? const SizedBox(height: 20, width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white)))
              : Text('ชำระเงิน ${PricingService.formatPrice(totalPrice)}',
                  style: AppStyles.buttonText),
        ),
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppStyles.bodyTextSmall),
          Text(value, style: AppStyles.bodyText, textAlign: TextAlign.right),
        ],
      ),
    );
  }

  Widget _price(String label, double price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppStyles.bodyText),
          Text(PricingService.formatPrice(price), style: AppStyles.bodyText),
        ],
      ),
    );
  }
}
