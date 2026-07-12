// ไฟล์สำหรับหน้าเข้าสู่ระบบ (Login Screen)
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_utils.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  bool isLoading = false;
  bool obscurePassword = true;
  bool isLoginByPhone = true; // Toggle between Phone and Email

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
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 28),
                // Logo
                Center(
                  child: Image.asset(
                    'assets/image/logo.png',
                    height: 130,
                  ),
                ),
                const SizedBox(height: 16),
                // App Name
                const Text(
                  'JordDeePeeKhum',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                // Welcome Text
                const Text(
                  'ยินดีต้อนรับ',
                  style: AppStyles.headingLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'กรุณาป้อนหมายเลขโทรศัพท์หรืออีเมลเพื่อเข้าสู่ระบบ',
                  style: TextStyle(color: AppColors.charcoal, fontSize: 14),
                ),
                const SizedBox(height: 24),
                
                // Toggle Button
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isLoginByPhone = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isLoginByPhone ? AppColors.primaryBlue : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'เบอร์โทรศัพท์',
                              style: TextStyle(
                                fontWeight: isLoginByPhone ? FontWeight.bold : FontWeight.normal,
                                color: isLoginByPhone ? AppColors.primaryBlue : AppColors.charcoal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isLoginByPhone = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: !isLoginByPhone ? AppColors.primaryBlue : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'อีเมล',
                              style: TextStyle(
                                fontWeight: !isLoginByPhone ? FontWeight.bold : FontWeight.normal,
                                color: !isLoginByPhone ? AppColors.primaryBlue : AppColors.charcoal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Form Area
                if (isLoginByPhone) ...[
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.lightgray),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: const BoxDecoration(
                            border: Border(right: BorderSide(color: AppColors.lightgray)),
                          ),
                          child: const Text('+66', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        Expanded(
                          child: TextField(
                            controller: emailController, // Reusing controller for phone number
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              hintText: '0812345678',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 16.0),
                          child: Icon(Icons.check_circle, color: AppColors.primaryBlue),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      final phone = emailController.text.trim();
                      if (phone.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('กรุณากรอกเบอร์โทรศัพท์')));
                        return;
                      }
                      Navigator.of(context).pushNamed('/otp', arguments: phone);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('รับรหัส OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white)),
                  ),
                ] else ...[
                  // Email Login
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Password',
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
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
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
                        : const Text('เข้าสู่ระบบ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white)),
                  ),
                ],
                const SizedBox(height: 24),
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('ลงทะเบียนบัญชีใหม่? ', style: TextStyle(color: AppColors.charcoal)),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/register');
                      },
                      child: const Text(
                        'สร้างบัญชี',
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