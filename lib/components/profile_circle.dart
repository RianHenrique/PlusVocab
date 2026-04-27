import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/auth/controllers/auth_controller.dart';
import 'package:plus_vocab/features/configs/views/config_screen.dart';
import 'package:provider/provider.dart';

class ProfileCircle extends StatefulWidget {
  const ProfileCircle({super.key});

  @override
  State<ProfileCircle> createState() => _ProfileCircleState();
}

class _ProfileCircleState extends State<ProfileCircle> {
  String? _initialFrom(AuthController auth) {
    final name = auth.userProfile?.name.trim();
    if (name != null && name.isNotEmpty) {
      return name[0].toUpperCase();
    }
    final email = auth.currentUser?.email;
    if (email != null && email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final initial = _initialFrom(auth);

    return InkWell(
      onTap: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ConfigScreen(),
          ),
        );
      },
      customBorder: const CircleBorder(),
      child: Center(
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.fundoClaro,
            border: Border.all(
              color: AppColors.primaria,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.sombraElevacao,
                blurRadius: 4,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: initial != null
              ? Center(
                  child: Text(
                    initial,
                    style: GoogleFonts.lexend(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaria,
                    ),
                  ),
                )
              : const Icon(
                  Icons.person,
                  color: AppColors.primaria,
                  size: 30,
                ),
        ),
      ),
    );
  }
}