import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:whatbytes_assignment/features/auth/ui/signup_screen.dart';

class BottomRightQuarterCircle extends StatelessWidget {
  const BottomRightQuarterCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300.h,
      width: 300.w,
      child: GestureDetector(
        onTap: (){

 Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen(),));
               
        },
        child: Stack(
          children: [
            // Background Quarter Circle
            Positioned(
              bottom: 0,
              right: 0,
              child: ClipPath(
                clipper: QuarterCircleClipper(),
                child:  Container(
                    width: 160, // Adjust as needed
                    height: 160,
                    color: const Color(0xFF6C63FF),
                  ),
                ),
              
            ),
        
            // Arrow Icon
            const Positioned(
              bottom: 40,
              right: 30,
              child: Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Clipper for Quarter Circle
class QuarterCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width, 0);
    path.arcToPoint(
      Offset(0, size.height),
      radius: Radius.circular(size.width),
      clockwise: false,
    );
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}