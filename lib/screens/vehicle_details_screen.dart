import 'package:flutter/material.dart';
import '../models/parking_lot_model.dart';
import '../models/parking_spot_model.dart';
import '../models/vehicle_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_utils.dart';

class VehicleDetailsScreen extends StatefulWidget {
  const VehicleDetailsScreen({super.key});
  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  final authService = AuthService();
  final apiService = ApiService();

  ParkingLot? parkingLot;
  ParkingSpot? parkingSpot;
  DateTime? startTime;
  DateTime? endTime;
  List<Vehicle> savedVehicles = [];
  Vehicle? selectedVehicle;

  final licensePlateCtrl = TextEditingController();
  final brandCtrl = TextEditingController();
  final modelCtrl = TextEditingController();
  final colorCtrl = TextEditingController();

  bool isNewVehicle = true;
  bool isLoading = false;
  bool _dataLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dataLoaded) {
      _dataLoaded = true;
      _loadData();
    }
  }
  
  @override
  void dispose() {
    licensePlateCtrl.dispose();
    brandCtrl.dispose();
    modelCtrl.dispose();
    colorCtrl.dispose();
    super.dispose();
  }

  void _loadData() async {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args == null) return;

    setState(() {
      parkingLot = args['parkingLot'] as ParkingLot;
      parkingSpot = args['parkingSpot'] as ParkingSpot;
      startTime = args['startTime'] as DateTime?;
      endTime = args['endTime'] as DateTime?;
    });

    if (authService.currentUser != null) {
      final vehicles = await apiService.getVehiclesByUserId(authService.currentUser!.id);
      if (mounted) {
        setState(() {
          savedVehicles = vehicles;
          isNewVehicle = vehicles.isEmpty;
        });
      }
    }
  }

  void _handleNext() async {
    if (parkingLot == null || parkingSpot == null) {
      _snack('เกิดข้อผิดพลาด: ไม่พบข้อมูลลานจอดรถ');
      return;
    }
    if (authService.currentUser == null) {
      _snack('Session หมดอายุ กรุณาเข้าสู่ระบบใหม่');
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    Vehicle vehicle;

    if (isNewVehicle) {
      final plate = licensePlateCtrl.text.trim();
      final brand = brandCtrl.text.trim();
      final model = modelCtrl.text.trim();
      final color = colorCtrl.text.trim();

      if (plate.isEmpty || brand.isEmpty || model.isEmpty || color.isEmpty) {
        _snack('กรุณากรอกข้อมูลให้ครบถ้วน');
        return;
      }
      if (!AppUtils.isValidLicensePlate(plate)) {
        _snack('ทะเบียนรถไม่ถูกต้อง (ต้องมีอย่างน้อย 4 ตัวอักษร)');
        return;
      }

      // ✅ สร้าง Vehicle ด้วย id = 0 ก่อน (จะได้จาก API)
      vehicle = Vehicle(
        id: 0,  // ✅ ใช้ 0 แทน UUID
        userId: authService.currentUser!.id,
        licensePlate: plate,
        brand: brand,
        model: model,
        color: color,
      );

      setState(() => isLoading = true);
      try {
        // ✅ insertVehicle return int
        final newId = await apiService.insertVehicle(vehicle);
        print('✅ Vehicle created with id: $newId');
        
        // สร้าง Vehicle ใหม่ด้วย id จาก API
        vehicle = Vehicle(
          id: newId,
          userId: vehicle.userId,
          licensePlate: vehicle.licensePlate,
          brand: vehicle.brand,
          model: vehicle.model,
          color: vehicle.color,
        );
      } catch (e) {
        print('⚠️ insertVehicle failed: $e');
        if (mounted) {
          _snack('ไม่สามารถบันทึกข้อมูลรถได้: $e');
          setState(() => isLoading = false);
          return;
        }
      } finally {
        if (mounted) setState(() => isLoading = false);
      }
    } else {
      if (selectedVehicle == null) {
        _snack('กรุณาเลือกรถยนต์');
        return;
      }
      vehicle = selectedVehicle!;
    }

    if (mounted) {
      Navigator.of(context).pushNamed('/time-selection', arguments: {
        'parkingLot': parkingLot,
        'parkingSpot': parkingSpot,
        'vehicle': vehicle,
        'startTime': startTime,
        'endTime': endTime,
      });
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.errorColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดรถ', style: TextStyle(fontWeight: FontWeight.bold)),
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
              // Header Text
              const Text(
                'เพิ่มข้อมูลรถยนต์ของคุณ',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.dark),
              ),
              const SizedBox(height: 8),
              const Text(
                'กรุณากรอกข้อมูลรถยนต์เพื่อใช้ในการจองที่จอดรถ',
                style: TextStyle(fontSize: 14, color: AppColors.charcoal),
              ),
              const SizedBox(height: 32),
              
              // Tab
              Container(
                decoration: BoxDecoration(
                  color: AppColors.lightgray.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isNewVehicle = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isNewVehicle ? AppColors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: isNewVehicle
                                ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]
                                : [],
                          ),
                          child: const Center(
                            child: Text('รถยนต์ใหม่', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),
                    if (savedVehicles.isNotEmpty)
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isNewVehicle = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !isNewVehicle ? AppColors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: !isNewVehicle
                                  ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]
                                  : [],
                            ),
                            child: Center(
                              child: Text('รถที่บันทึก (${savedVehicles.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Form
              if (isNewVehicle) ...[
                _field(licensePlateCtrl, 'ทะเบียนรถ', 'เช่น กข1234', Icons.pin_outlined, caps: TextCapitalization.characters),
                const SizedBox(height: 16),
                _field(brandCtrl, 'ยี่ห้อรถ', 'เช่น Toyota, Honda', Icons.directions_car_outlined),
                const SizedBox(height: 16),
                _field(modelCtrl, 'รุ่นรถ', 'เช่น Civic, Camry', Icons.info_outline),
                const SizedBox(height: 16),
                _field(colorCtrl, 'สีรถ', 'เช่น ขาว, ดำ, เทา', Icons.color_lens_outlined),
              ],

              // Saved Vehicles
              if (!isNewVehicle && savedVehicles.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: savedVehicles.length,
                  itemBuilder: (_, i) {
                    final v = savedVehicles[i];
                    final sel = selectedVehicle?.id == v.id;
                    return GestureDetector(
                      onTap: () => setState(() => selectedVehicle = v),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: sel ? AppColors.primaryBlue : AppColors.lightgray,
                            width: 2,
                          ),
                          boxShadow: [
                            if (sel)
                              BoxShadow(
                                color: AppColors.primaryBlue.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: sel ? AppColors.primaryBlue : AppColors.lightgray.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.directions_car,
                                color: sel ? AppColors.white : AppColors.charcoal,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    v.licensePlate,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.dark),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${v.brand} ${v.model} • ${v.color}',
                                    style: const TextStyle(color: AppColors.charcoal, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            if (sel)
                              const Icon(Icons.check_circle, color: AppColors.primaryBlue, size: 28),
                          ],
                        ),
                      ),
                    );
                  },
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
          onPressed: isLoading ? null : _handleNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.white)),
                )
              : const Text('ต่อไป', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white)),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    String hint,
    IconData icon, {
    TextCapitalization caps = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.dark, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          textCapitalization: caps,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.charcoal),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}
