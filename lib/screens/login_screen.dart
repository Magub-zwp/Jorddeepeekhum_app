// ไฟล์สำหรับหน้าเข้าสู่ระบบ (Login Screen)
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_utils.dart';

class LoginScreen extends StatefulWidget {
  // สร้าง StatefulWidget สำหรับหน้า Login
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ตัวแปรสำหรับจัดการ Authentication
  final authService = AuthService();

  // ตัวควบคุมการป้อนข้อมูล (Controller)
  late TextEditingController emailController; // ควบคุมการป้อนอีเมล
  late TextEditingController passwordController; // ควบคุมการป้อนรหัสผ่าน

  // ตัวแปรสำหรับการแสดงข้อมูล
  bool isLoading = false; // แสดงว่ากำลังโหลดหรือไม่
  bool obscurePassword = true; // ซ่อนรหัสผ่านหรือไม่

  @override
  void initState() {
    // เรียกใช้เมื่อสร้าง Widget
    super.initState();
    // สร้าง Controller ใหม่
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    // เรียกใช้เมื่อ Widget ถูกลบ
    // ลบ Controller เพื่อยากความจำ
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ฟังก์ชั่นสำหรับจัดการการเข้าสู่ระบบ
  void _handleLogin() async {
    // ดึงค่าที่ป้อนเข้ามา
    final email = emailController.text.trim();
    final password = passwordController.text;

    // ตรวจสอบว่าป้อนข้อมูลหรือยัง
    if (email.isEmpty || password.isEmpty) {
      // แสดงข้อความแจ้งเตือน
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกอีเมลและรหัสผ่าน')),
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

    // เริ่มสถานะการโหลด
    setState(() {
      isLoading = true;
    });

    // ✅ แก้ไขตรงนี้: ลบ email: และ password: ออก (ใช้ Positional Arguments)
    final success = await authService.login(
      email,
      password,
    );

    // สิ้นสุดสถานะการโหลด
    setState(() {
      isLoading = false;
    });

    // ตรวจสอบเข้าสู่ระบบ
    if (success) {
      // สำเร็จ -> ไปหน้า Home
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/parking-lots');
      }
    } else {
      // เมื่อล้มเหลว -> แสดงข้อความผิดพลาด
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('อีเมลหรือรหัสผ่านไม่ถูกต้อง')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // สร้าง UI สำหรับหน้า Login
    return Scaffold(
      // แถบด้านบน
      appBar: AppBar(
        // ซ่อนปุ่มย้อนกลับ
        automaticallyImplyLeading: false,
        // ชื่อแอป
        title: const Text('JordDeePeeKhum'),
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
              const SizedBox(height: 40),
              // หัวข้อ
              const Text(
                AppStrings.login,
                style: AppStyles.headingLarge,
                textAlign: TextAlign.center,
              ),
              // ห่างระหว่างส่วนประกอบ
              const SizedBox(height: 32),
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
              const SizedBox(height: 24),
              // ปุ่มเข้าสู่ระบบ
              ElevatedButton(
                // จัดการเมื่อกด
                onPressed: isLoading ? null : _handleLogin,
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
                        AppStrings.login,
                        style: AppStyles.buttonText,
                      ),
              ),
              // ห่างระหว่างส่วนประกอบ
              const SizedBox(height: 16),
              // ข้อความและลิงค์ไปหน้าสมัครสมาชิก
              Row(
                // จัดตำแหน่ง
                mainAxisAlignment: MainAxisAlignment.center,
                // ส่วนประกอบ
                children: [
                  // ข้อความ
                  const Text(AppStrings.dontHaveAccount),
                  // ปุ่มลิงค์
                  TextButton(
                    // จัดการเมื่อกด
                    onPressed: () {
                      // ไปหน้าสมัครสมาชิก
                      Navigator.of(context).pushNamed('/register');
                    },
                    // ข้อความลิงค์
                    child: const Text(
                      AppStrings.register,
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