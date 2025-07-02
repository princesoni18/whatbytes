import 'package:flutter/material.dart';

class CheckmarkIcon extends StatelessWidget {
  final double? size;
  const CheckmarkIcon({super.key,this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size??80, 
      height: size??80,
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF), 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.check_circle_outline_rounded,
          color: Colors.white,
          size: 50,
        ),
      ),
    );
  }
}
