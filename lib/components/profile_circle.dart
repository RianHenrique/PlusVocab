import 'package:flutter/material.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/configs/views/config_screen.dart';

class ProfileCircle extends StatefulWidget {
  const ProfileCircle({super.key});

  @override
  State<ProfileCircle> createState() => _ProfileCircleState();
}

class _ProfileCircleState extends State<ProfileCircle> {

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ConfigScreen()
          ),
        )
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
            ], // Cor de fundo do círculo
          ),
          child: const Icon(
            Icons.person,
            color: AppColors.primaria,
            size: 30,
          ),
        ),
      ),
    );
  }
}