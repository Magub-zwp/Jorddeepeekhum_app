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

  int selectedPaymentMethod = 0; // 0: Credit Card, 1: PromptPay, 2: Cash

  @override
  Widget build(BuildContext context) {
    if (parkingLot == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('ชำระเงิน', style: TextStyle(fontWeight: FontWeight.bold)),
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
              // สรุปการจอด
              const Text('สรุปการจองรถ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.dark)),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _detail('สถานที่', parkingLot!.name, isBold: true),
                    const Divider(height: 24, color: AppColors.lightgray),
                    _detail('ช่องจอด', parkingSpot!.spotNumber),
                    const SizedBox(height: 8),
                    _detail('ทะเบียนรถ', vehicle!.licensePlate),
                    const SizedBox(height: 8),
                    _detail('รถยนต์', '${vehicle!.brand} ${vehicle!.model}'),
                    const SizedBox(height: 8),
                    _detail('เวลาเข้า', AppUtils.formatDateTime(startTime)),
                    const SizedBox(height: 8),
                    _detail('เวลาออก', AppUtils.formatDateTime(endTime)),
                    const SizedBox(height: 8),
                    _detail('ระยะเวลา', PricingService.calculateDuration(startTime: startTime, endTime: endTime)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // วิธีการชำระเงิน
              const Text('วิธีการชำระเงิน', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.dark)),
              const SizedBox(height: 16),
              _buildPaymentMethod(0, 'บัตรเครดิต/เดบิต', Icons.credit_card),
              const SizedBox(height: 12),
              _buildPaymentMethod(1, 'พร้อมเพย์ (PromptPay)', Icons.qr_code_2),
              const SizedBox(height: 12),
              _buildPaymentMethod(2, 'เงินสด', Icons.money),
              
              const SizedBox(height: 32),

              // ราคา
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _price('ค่าที่จอดรถ', totalPrice),
                    const SizedBox(height: 8),
                    _price('ค่าบริการ', 0.0),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1, color: AppColors.lightgray),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('ยอดชำระทั้งหมด', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.dark)),
                        Text(
                          PricingService.formatPrice(totalPrice),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                        ),
                      ],
                    ),
                    if (PricingService.isFreeParking(startTime: startTime, endTime: endTime))
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('ชั่วโมงแรกฟรี!',
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
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
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : _handlePayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: isLoading
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.white)))
              : Text('ยืนยันชำระเงิน ${PricingService.formatPrice(totalPrice)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white)),
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(int index, String title, IconData icon) {
    final isSelected = selectedPaymentMethod == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.lightgray,
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(color: AppColors.primaryBlue.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryBlue : AppColors.lightgray.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? AppColors.white : AppColors.charcoal, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.dark),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primaryBlue : AppColors.lightgray,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle)))
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _detail(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.charcoal, fontSize: 14)),
        Text(value, style: TextStyle(color: AppColors.dark, fontSize: isBold ? 16 : 14, fontWeight: isBold ? FontWeight.bold : FontWeight.w600)),
      ],
    );
  }

  Widget _price(String label, double price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.dark, fontSize: 16, fontWeight: FontWeight.w500)),
        Text(PricingService.formatPrice(price), style: const TextStyle(color: AppColors.dark, fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
