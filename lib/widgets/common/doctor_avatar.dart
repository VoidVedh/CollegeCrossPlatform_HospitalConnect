import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';

/// Reusable Doctor Avatar with initials fallback and optional Hero animation.
class DoctorAvatar extends StatelessWidget {
  const DoctorAvatar({
    super.key,
    required this.name,
    this.imageUrl = '',
    this.radius = 28.0,
    this.heroTag,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String name;
  final String imageUrl;
  final double radius;
  final String? heroTag;
  final Color? backgroundColor;
  final Color? foregroundColor;

  static String getInitials(String fullName) {
    var clean = fullName.trim();
    if (clean.toLowerCase().startsWith('dr.') ||
        clean.toLowerCase().startsWith('dr ')) {
      clean = clean.substring(3).trim();
    }
    final tokens = clean
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .where((t) {
          final upper = t.toUpperCase().replaceAll('.', '');
          return upper != 'MD' &&
              upper != 'MS' &&
              upper != 'MBBS' &&
              upper != 'DNB' &&
              upper != 'PHD';
        })
        .toList();

    if (tokens.isEmpty) return 'DR';
    if (tokens.length == 1) return tokens.first[0].toUpperCase();
    return '${tokens[0][0]}${tokens[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = getInitials(name);
    final bg = backgroundColor ?? AppColors.primaryContainer;
    final fg = foregroundColor ?? AppColors.primary;

    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      foregroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
      child: Text(
        initials,
        style: theme.textTheme.titleMedium?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.7,
        ),
      ),
    );

    if (heroTag != null && heroTag!.isNotEmpty) {
      avatar = Hero(
        tag: heroTag!,
        child: avatar,
      );
    }

    return Semantics(
      label: 'Doctor $name avatar',
      child: avatar,
    );
  }
}
