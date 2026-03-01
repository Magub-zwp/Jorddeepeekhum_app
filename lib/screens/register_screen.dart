// ไฟล์สำหรับหน้าลงทะเบียน (Register Screen)
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_utils.dart';

class RegisterScreen extends StatefulWidget {
  // สร้าง StatefulWidget สำหรับหน้า Register
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ตัวแปรสำหรับจัดการ Authentication
  final authService = AuthService();

  // ตัวควบคุมการป้อนข้อมูล (Controller)
  late TextEditingController usernameController; // ควบคุมการป้อนชื่อผู้ใช้
  late TextEditingController emailController; // ควบคุมการป้อนอีเมล
  late TextEditingController phoneController; // ควบคุมการป้อนเบอร์โทร
  late TextEditingController passwordController; // ควบคุมการป้อนรหัสผ่าน
  late TextEditingController confirmPasswordController; // ควบคุมการยืนยันรหัสผ่าน

  // ตัวแปรสำหรับการแสดงข้อมูล
  bool isLoading = false; // แสดงว่ากำลังโหลดหรือไม่
  bool obscurePassword = true; // ซ่อนรหัสผ่านหรือไม่
  bool obscureConfirmPassword = true; // ซ่อนการยืนยันรหัสผ่านหรือไม่

  @override
  void initState() {
    // เรียกใช้เมื่อสร้าง Widget
    super.initState();
    // สร้าง Controller ใหม่
    usernameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    // เรียกใช้เมื่อ Widget ถูกลบ
    // ลบ Controller เพื่อยากความจำ
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // ฟังก์ชั่นสำหรับจัดการการลงทะเบียน
  void _handleRegister() async {
    // ดึงค่าที่ป้อนเข้ามา
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // ตรวจสอบว่าป้อนข้อมูลหมด
    if (username.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      // แสดงข้อความแจ้งเตือน
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
      );
      return;
    }

    // ตรวจสอบความถูกต้องของชื่อผู้ใช้
    if (!AppUtils.isValidInput(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ชื่อผู้ใช้ต้องมีอย่างน้อย 2 ตัวอักษร')),
      );
      return;
    }

    // ตรวจสอบความถูกต้องของอีเมล
    if (!AppUtils.isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('อีเมลไม่ถูกต้อง')),
      );
      return;
    }

    // ตรวจสอบความถูกต้องของหมายเลขโทรศัพท์
    if (!AppUtils.isValidPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('หมายเลขโทรศัพท์ต้องเป็นตัวเลข 10 หลักขึ้นไป')),
      );
      return;
    }

    // ตรวจสอบความถูกต้องของรหัสผ่าน
    if (!AppUtils.isValidPassword(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร')),
      );
      return;
    }

    // ตรวจสอบว่ารหัสผ่านและการยืนยันตรงกัน
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('รหัสผ่านไม่ตรงกัน')),
      );
      return;
    }

    // เริ่มสถานะการโหลด
    setState(() {
      isLoading = true;
    });

    // ลงทะเบียน
    // ✅ แก้ไขตรงนี้: ลบชื่อ parameter ออก ให้เป็น positional arguments
    final success = await authService.register(
      username,
      email,
      phone,
      password,
    );

    // สิ้นสุดสถานะการโหลด
    setState(() {
      isLoading = false;
    });

    // ตรวจสอบผลการลงทะเบียน
    if (success) {
      // สำเร็จ -> แสดงข้อความและย้อนกลับ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลงทะเบียนสำเร็จ')),
        );
        // ทำให้หน้า Login เป็นหน้าเดียว (ลบหน้า Register ออก)
        Navigator.of(context).pop();
      }
    } else {
      // ล้มเหลว -> แสดงข้อความผิดพลาด
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('อีเมลนี้มีในระบบแล้ว')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // สร้าง UI สำหรับหน้า Register
    return Scaffold(
      // แถบด้านบน
      appBar: AppBar(
        // ชื่อแอป
        title: const Text('สมัครสมาชิก'),
        // สีของแถบด้านบน
        backgroundColor: AppColors.primaryColor,
      ),
      // พื้นหลัง
      backgroundColor: AppColors.backgroundColor,
      // เนื้อหา
      body: SingleChildScrollView(
        // เลื่อนได้เมื่อเนื้อหามากขึ้น
        child: Padding(
          // ระยะห่างรอบ ๆ
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          // สดมภ์ไว้ตรงกลาง
          child: Column(
            // จัดตำแหน่ง
            mainAxisAlignment: MainAxisAlignment.center,
            // จัดแนวตั้ง
            crossAxisAlignment: CrossAxisAlignment.stretch,
            // ส่วนประกอบ
            children: [
              // ห่างจากด้านบน
              const SizedBox(height: 20),
              // หัวข้อ
              const Text(
                AppStrings.register,
                style: AppStyles.headingLarge,
                textAlign: TextAlign.center,
              ),
              // ห่างระหว่างส่วนประกอบ
              const SizedBox(height: 32),
              // ช่องป้อนชื่อผู้ใช้
              TextField(
                // ตั้งค่า Controller
                controller: usernameController,
                // ตั้งค่า Decoration
                decoration: InputDecoration(
                  // ข้อความ hint
                  hintText: AppStrings.username,
                  // ไอคอน
                  prefixIcon: const Icon(Icons.person),
                  // ขอบ
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusMedium,
                    ),
                  ),
                ),
              ),
              // ห่างระหว่างส่วนประกอบ
              const SizedBox(height: 16),
              // ช่องป้อนอีเมล
              TextField(
                // ตั้งค่า Controller
                controller: emailController,
                // ตั้งค่า Keyboard
                keyboardType: TextInputType.emailAddress,
                // ตั้งค่า Decoration
                decoration: InputDecoration(
                  // ข้อความ hint
                  hintText: AppStrings.email,
                  // ไอคอน
                  prefixIcon: const Icon(Icons.email),
                  // ขอบ
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusMedium,
                    ),
                  ),
                ),
              ),
              // ห่างระหว่างส่วนประกอบ
              const SizedBox(height: 16),
              // ช่องป้อนหมายเลขโทรศัพท์
              TextField(
                // ตั้งค่า Controller
                controller: phoneController,
                // ตั้งค่า Keyboard
                keyboardType: TextInputType.phone,
                // ตั้งค่า Decoration
                decoration: InputDecoration(
                  // ข้อความ hint
                  hintText: AppStrings.phone,
                  // ไอคอน
                  prefixIcon: const Icon(Icons.phone),
                  // ขอบ
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusMedium,
                    ),
                  ),
                ),
              ),
              // ห่างระหว่างส่วนประกอบ
              const SizedBox(height: 16),
              // ช่องป้อนรหัสผ่าน
              TextField(
                // ตั้งค่า Controller
                controller: passwordController,
                // ซ่อนข้อความ
                obscureText: obscurePassword,
                // ตั้งค่า Decoration
                decoration: InputDecoration(
                  // ข้อความ hint
                  hintText: AppStrings.password,
                  // ไอคอน
                  prefixIcon: const Icon(Icons.lock),
                  // ปุ่มสำหรับซ่อน/แสดงรหัสผ่าน
                  suffixIcon: IconButton(
                    // ไอคอน
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    // จัดการเมื่อกด
                    onPressed: () {
                      // เปลี่ยนสถานะ
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                  // ขอบ
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusMedium,
                    ),
                  ),
                ),
              ),
              // ห่างระหว่างส่วนประกอบ
              const SizedBox(height: 16),
              // ช่องยืนยันรหัสผ่าน
              TextField(
                // ตั้งค่า Controller
                controller: confirmPasswordController,
                // ซ่อนข้อความ
                obscureText: obscureConfirmPassword,
                // ตั้งค่า Decoration
                decoration: InputDecoration(
                  // ข้อความ hint
                  hintText: 'ยืนยันรหัสผ่าน',
                  // ไอคอน
                  prefixIcon: const Icon(Icons.lock),
                  // ปุ่มสำหรับซ่อน/แสดงรหัสผ่าน
                  suffixIcon: IconButton(
                    // ไอคอน
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    // จัดการเมื่อกด
                    onPressed: () {
                      // เปลี่ยนสถานะ
                      setState(() {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      });
                    },
                  ),
                  // ขอบ
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusMedium,
                    ),
                  ),
                ),
              ),
              // ห่างระหว่างส่วนประกอบ
              const SizedBox(height: 24),
              // ปุ่มลงทะเบียน
              ElevatedButton(
                // จัดการเมื่อกด
                onPressed: isLoading ? null : _handleRegister,
                // สไตล์ปุ่ม
                style: ElevatedButton.styleFrom(
                  // สีพื้นหลัง
                  backgroundColor: AppColors.primaryColor,
                  // สีข้อความ
                  foregroundColor: AppColors.white,
                  // ความสูง
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  // มุมโค้ง
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusMedium,
                    ),
                  ),
                ),
                // ข้อความปุ่ม
                child: isLoading
                    ? const SizedBox(
                        // ความสูง
                        height: 20,
                        // ความกว้าง
                        width: 20,
                        // สปินเนอร์โหลด
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.white,
                          ),
                        ),
                      )
                    : const Text(
                        AppStrings.register,
                        style: AppStyles.buttonText,
                      ),
              ),
              // ห่างระหว่างส่วนประกอบ
              const SizedBox(height: 16),
              // ข้อความและลิงค์ไปหน้าเข้าสู่ระบบ
              Row(
                // จัดตำแหน่ง
                mainAxisAlignment: MainAxisAlignment.center,
                // ส่วนประกอบ
                children: [
                  // ข้อความ
                  const Text(AppStrings.haveAccount),
                  // ปุ่มลิงค์
                  TextButton(
                    // จัดการเมื่อกด
                    onPressed: () {
                      // ย้อนกลับไปหน้า Login
                      Navigator.of(context).pop();
                    },
                    // ข้อความลิงค์
                    child: const Text(
                      AppStrings.login,
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}