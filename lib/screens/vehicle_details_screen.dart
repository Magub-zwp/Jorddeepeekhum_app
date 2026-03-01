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
        title: const Text(AppStrings.vehicleDetails),
        backgroundColor: AppColors.primaryColor,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // แสดงช่องที่เลือก
              if (parkingLot != null && parkingSpot != null)
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.charcoal,
                    borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_parking, color: AppColors.primaryColor),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            parkingLot!.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'ช่องจอด: ${parkingSpot!.spotNumber}',
                            style: AppStyles.bodyTextSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // Tab
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => isNewVehicle = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isNewVehicle ? AppColors.primaryColor : Colors.grey,
                      ),
                      child: const Text('รถยนต์ใหม่', style: AppStyles.buttonText),
                    ),
                  ),
                  if (savedVehicles.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => setState(() => isNewVehicle = false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !isNewVehicle ? AppColors.primaryColor : Colors.grey,
                        ),
                        child: Text(
                          'รถที่บันทึก (${savedVehicles.length})',
                          style: AppStyles.buttonText,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),

              // ฟอร์มรถใหม่
              if (isNewVehicle) ...[
                _field(licensePlateCtrl, 'ทะเบียนรถ *', 'เช่น กข1234', Icons.directions_car,
                    caps: TextCapitalization.characters),
                const SizedBox(height: 16),
                _field(brandCtrl, 'ยี่ห้อรถ *', 'เช่น Toyota, Honda', Icons.label),
                const SizedBox(height: 16),
                _field(modelCtrl, 'รุ่นรถ *', 'เช่น Civic, Camry', Icons.info),
                const SizedBox(height: 16),
                _field(colorCtrl, 'สีรถ *', 'เช่น ขาว, ดำ, เทา', Icons.palette),
              ],

              // รายการรถที่บันทึก
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
                      child: Card(
                        color: sel ? AppColors.primaryColor : AppColors.charcoal,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                          child: Row(
                            children: [
                              Icon(
                                sel ? Icons.check_circle : Icons.directions_car,
                                color: AppColors.white,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      v.licensePlate,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white,
                                      ),
                                    ),
                                    Text(
                                      '${v.brand} ${v.model} • ${v.color}',
                                      style: const TextStyle(color: AppColors.lightgray),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: ElevatedButton(
          onPressed: isLoading ? null : _handleNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                )
              : const Text(AppStrings.next, style: AppStyles.buttonText),
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
    return TextField(
      controller: ctrl,
      textCapitalization: caps,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        ),
      ),
    );
  }
}
