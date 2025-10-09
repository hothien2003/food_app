import 'package:flutter/material.dart';
import '../const/colors.dart';

class CustomTextInput extends StatelessWidget {
  final String hintText;
  final EdgeInsets padding;
  final TextEditingController? controller;
  final bool obscureText;
  final String? Function(String?)? validator;

  const CustomTextInput({
    super.key,
    required this.hintText,
    this.padding = const EdgeInsets.only(left: 40),
    this.controller,
    this.obscureText = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: ShapeDecoration(
        color: AppColor.placeholderBg,
        shape: const StadiumBorder(),
      ),
      child: Center(
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText,
            hintStyle: TextStyle(color: AppColor.placeholder),
            contentPadding: padding,
          ),
        ),
      ),
    );
  }
}
