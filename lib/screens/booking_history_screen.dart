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
        title: const Text('ประวัติการจอง', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.dark,
        elevation: 0,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_toggle_off, size: 64, color: AppColors.lightgray.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      const Text('ยังไม่มีข้อมูลการจอง', style: TextStyle(color: AppColors.charcoal, fontSize: 16)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async => _loadBookings(),
                  child: ListView.builder(
                    itemCount: bookings.length,
                    padding: const EdgeInsets.all(24),
                    itemBuilder: (context, index) {
                      final booking = bookings[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
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
                        child: Padding(
                          padding: const EdgeInsets.all(20),
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
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                  Text(
                                    'ID: ${booking.id}',
                                    style: const TextStyle(color: AppColors.charcoal, fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // เวลา
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.access_time, color: AppColors.primaryBlue, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppUtils.formatDateTime(booking.startTime),
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.dark),
                                        ),
                                        if (booking.endTime != null)
                                          Text(
                                            'ถึง ${AppUtils.formatDateTime(booking.endTime!)}',
                                            style: const TextStyle(fontSize: 12, color: AppColors.charcoal),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Divider(height: 1, color: AppColors.lightgray),
                              ),
                              
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
                                      color: AppColors.dark,
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
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      booking.status.toUpperCase(),
                                      style: TextStyle(
                                        color: booking.status == 'paid' ? Colors.green : Colors.orange,
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
