import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../utils/app_constants.dart';
import '../utils/app_utils.dart';

class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({super.key});
  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  Booking? booking;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (booking == null) {
      booking = ModalRoute.of(context)?.settings.arguments as Booking?;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (booking == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ไอคอนสำเร็จ
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.successColor,
                  ),
                  child: const Icon(Icons.check, color: AppColors.white, size: 40),
                ),
                const SizedBox(height: 24),
                const Text(
                  'จองสำเร็จ!',
                  style: AppStyles.headingLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'ขอบคุณที่ใช้บริการของเรา',
                  style: AppStyles.bodyText,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // การ์ดข้อมูล
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ✅ แสดง Visit Number แทน UUID
                        const Text('เลขที่การจอง', style: AppStyles.bodyTextSmall),
                        Text(
                          booking!.visitNumber.isNotEmpty 
                              ? booking!.visitNumber 
                              : 'BK-${booking!.id}',
                          style: AppStyles.headingMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Booking ID: ${booking!.id}',
                          style: AppStyles.bodyTextSmall,
                        ),
                        
                        const Divider(height: 24),
                        _row('เวลาเข้า', AppUtils.formatDateTime(booking!.startTime)),
                        _row(
                          'เวลาออก',
                          booking!.endTime != null
                              ? AppUtils.formatDateTime(booking!.endTime!)
                              : '-',
                        ),
                        _row('ราคารวม', '${booking!.totalPrice.toStringAsFixed(2)} บาท'),
                        _row('สถานะ', booking!.status.toUpperCase()),
                        
                        const Divider(height: 24),
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                          decoration: BoxDecoration(
                            color: AppColors.accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                          ),
                          child: Text(
                            'โปรดบันทึกหมายเลข ${booking!.visitNumber} '
                            'เพื่อไว้ยืนยันในการออกจากลานจอด',
                            style: AppStyles.bodyTextSmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/parking-lots',
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                      ),
                    ),
                    child: const Text('กลับไปจองที่อื่น', style: AppStyles.buttonText),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppStyles.bodyTextSmall),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
