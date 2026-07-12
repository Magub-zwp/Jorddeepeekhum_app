// ไฟล์สำหรับหน้าลงทะเบียน (Register Screen)
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_utils.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Logo
                Center(
                  child: Image.asset(
                    'assets/image/logo.png',
                    height: 80,
                  ),
                ),
                const SizedBox(height: 8),
                // App Name
                const Text(
                  'JordDeePeeKhum',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Welcome Text
                const Text(
                  'เริ่มต้นเลย',
                  style: AppStyles.headingLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'สร้างบัญชีของคุณ',
                  style: TextStyle(color: AppColors.charcoal, fontSize: 14),
                ),
                const SizedBox(height: 32),
                
                // Username Field
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    hintText: 'ชื่อผู้ใช้ (Name)',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Email Field
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'อีเมล (Email)',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Phone Field
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'เบอร์โทรศัพท์ (Phone Number)',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Password Field
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'รหัสผ่าน (Password)',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Confirm Password Field
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'ยืนยันรหัสผ่าน (Confirm Password)',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Register Button
                ElevatedButton(
                  onPressed: isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Rounded corners like Figma
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
                      : const Text(
                          'เริ่มต้นใช้งาน',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white),
                        ),
                ),
                const SizedBox(height: 24),
                
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('มีบัญชีอยู่แล้ว? ', style: TextStyle(color: AppColors.charcoal)),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                
                // Google Button
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('กำลังพัฒนาระบบ Google Login')),
                    );
                  },
                  icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red, size: 20),
                  label: const Text(
                    'Continue With Google',
                    style: TextStyle(color: AppColors.dark, fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.lightgray),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}