import 'package:flutter/material.dart';
import 'package:packagekit_dart/packagekit_dart.dart';

import '../theme/colors.dart';

class StatusBadge extends StatelessWidget {
  final PkInfo info;

  const StatusBadge({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (info) {
      PkInfo.installed => ('Installed', AppColors.installed),
      PkInfo.available => ('Available', AppColors.available),
      PkInfo.updating => ('Update', AppColors.update),
      PkInfo.security => ('Security', AppColors.security),
      PkInfo.bugfix => ('Bugfix', AppColors.update),
      PkInfo.removing => ('Removing', AppColors.removing),
      PkInfo.installing => ('Installing', AppColors.available),
      _ => (info.name, Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(120)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
