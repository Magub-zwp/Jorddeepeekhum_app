import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_utils.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  final authService = AuthService();
  final apiService = ApiService();

  List<Booking> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() async {
    if (authService.currentUser == null) {
      setState(() => isLoading = false);
      return;
    }

    final userBookings = await apiService.getBookingsByUserId(
      authService.currentUser!.id,
    );
    
    if (mounted) {
      setState(() {
        bookings = userBookings;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ประวัติการจอด'),
        backgroundColor: AppColors.primaryColor,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? const Center(
                  child: Text('ยังไม่มีข้อมูลการจอด'),
                )
              : RefreshIndicator(
                  onRefresh: () async => _loadBookings(),
                  child: ListView.builder(
                    itemCount: bookings.length,
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    itemBuilder: (context, index) {
                      final booking = bookings[index];

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.borderRadiusLarge,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ✅ แสดง Visit Number แทน UUID
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    booking.visitNumber.isNotEmpty
                                        ? booking.visitNumber
                                        : 'BK-${booking.id}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                  Text(
                                    'ID: ${booking.id}',
                                    style: AppStyles.bodyTextSmall,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              
                              // เวลา
                              Text(
                                AppUtils.formatDateTime(booking.startTime),
                                style: AppStyles.headingMedium,
                              ),
                              if (booking.endTime != null)
                                Text(
                                  'ถึง ${AppUtils.formatDateTime(booking.endTime!)}',
                                  style: AppStyles.bodyTextSmall,
                                ),
                              
                              const Divider(),
                              
                              // ราคา และ สถานะ
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // ราคา
                                  Text(
                                    '${booking.totalPrice.toStringAsFixed(2)} บาท',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.successColor,
                                    ),
                                  ),
                                  // สถานะ
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: booking.status == 'paid'
                                          ? AppColors.successColor
                                          : AppColors.warningColor,
                                      borderRadius: BorderRadius.circular(
                                        AppDimensions.borderRadiusSmall,
                                      ),
                                    ),
                                    child: Text(
                                      booking.status.toUpperCase(),
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
