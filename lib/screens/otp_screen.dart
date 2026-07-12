import 'package:flutter/material.dart';
import '../utils/app_constants.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  String _phoneNumber = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String) {
      _phoneNumber = args;
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 3) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        _focusNodes[index].unfocus();
        _verifyOtp();
      }
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  void _verifyOtp() {
    String otp = _controllers.map((c) => c.text).join();
    if (otp.length == 4) {
      // จำลองการตรวจสอบ OTP
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เข้าสู่ระบบสำเร็จ!')),
      );
      Navigator.of(context).pushNamedAndRemoveUntil('/parking-lots', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.dark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'OTP',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'โปรดพิมพ์รหัสที่เราส่งไปให้',
                style: TextStyle(fontSize: 16, color: AppColors.charcoal),
              ),
              const SizedBox(height: 4),
              Text(
                '+66 $_phoneNumber',
                style: const TextStyle(fontSize: 16, color: AppColors.charcoal, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 60,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                        ),
                      ),
                      onChanged: (value) => _onOtpChanged(value, index),
                    ),
                  );
                }),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('ไม่ได้รับรหัส? ', style: TextStyle(color: AppColors.charcoal)),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ส่งรหัส OTP ใหม่แล้ว')),
                      );
                    },
                    child: const Text(
                      'ส่งอีกครั้ง',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
