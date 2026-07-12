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
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ไอคอนสำเร็จ
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withOpacity(0.1),
                  ),
                  child: Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                        boxShadow: [
                          BoxShadow(color: Colors.green, blurRadius: 10, offset: Offset(0, 4)),
                        ],
                      ),
                      child: const Icon(Icons.check, color: AppColors.white, size: 40),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'การจองสำเร็จ!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.dark),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'คุณสามารถดูรายละเอียดการจองได้ที่ประวัติการจอง',
                  style: TextStyle(fontSize: 14, color: AppColors.charcoal),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // การ์ดข้อมูลแบบตั๋ว
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      // ส่วนบนของการ์ด
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('เลขที่การจอง (Visit Number)', style: TextStyle(color: AppColors.charcoal, fontSize: 14)),
                            const SizedBox(height: 8),
                            Text(
                              booking!.visitNumber.isNotEmpty 
                                  ? booking!.visitNumber 
                                  : 'BK-${booking!.id}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: AppColors.primaryBlue),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Booking ID: ${booking!.id}',
                              style: const TextStyle(color: AppColors.charcoal, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      
                      // รอยประ
                      Row(
                        children: [
                          Container(
                            width: 15,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: AppColors.backgroundColor,
                              borderRadius: BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15)),
                            ),
                          ),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Flex(
                                  direction: Axis.horizontal,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: List.generate(
                                    (constraints.constrainWidth() / 10).floor(),
                                    (index) => const SizedBox(
                                      width: 5,
                                      height: 1,
                                      child: DecoratedBox(decoration: BoxDecoration(color: AppColors.lightgray)),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Container(
                            width: 15,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: AppColors.backgroundColor,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
                            ),
                          ),
                        ],
                      ),
                      
                      // ส่วนล่างของการ์ด
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            _row('เวลาเข้า', AppUtils.formatDateTime(booking!.startTime)),
                            _row(
                              'เวลาออก',
                              booking!.endTime != null
                                  ? AppUtils.formatDateTime(booking!.endTime!)
                                  : '-',
                            ),
                            _row('ราคารวม', '${booking!.totalPrice.toStringAsFixed(2)} บาท', isBold: true),
                            _row('สถานะ', 'จ่ายเงินแล้ว', valueColor: Colors.green, isBold: true),
                          ],
                        ),
                      ),
                    ],
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
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('กลับสู่หน้าหลัก', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.charcoal, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? AppColors.dark,
            ),
          ),
        ],
      ),
    );
  }
}
