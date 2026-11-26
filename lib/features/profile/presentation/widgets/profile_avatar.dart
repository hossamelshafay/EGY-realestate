import 'package:material_ui/material_ui.dart';
import 'package:egy/app/theme/app_colors.dart';
import '../../domain/entities/avatar_catalog.dart';

/// Six lightweight vector portraits, rendered locally at any density.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, this.avatarId, this.size = 72});
  final String? avatarId;
  final double size;
  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: ClipOval(
      child: CustomPaint(
        painter: _PortraitPainter(
          AvatarCatalog.valid(avatarId)
              ? AvatarCatalog.ids.indexOf(avatarId!)
              : 0,
        ),
      ),
    ),
  );
}

class _PortraitPainter extends CustomPainter {
  const _PortraitPainter(this.index);
  final int index;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    final paint = Paint()..isAntiAlias = true;
    final skin = [
      AppColors.avatarSkinLight,
      AppColors.avatarSkinMedium,
      AppColors.avatarSkinDeep,
    ][index % 3];
    final shirt = [
      AppColors.primaryGold,
      AppColors.avatarTeal,
      AppColors.secondaryNavy,
      AppColors.avatarRose,
      AppColors.primaryGold,
      AppColors.avatarTeal,
    ][index];
    void oval(Rect rect, Color color) {
      canvas.drawOval(rect, paint..color = color);
    }

    oval(const Rect.fromLTWH(0, 0, 100, 100), AppColors.secondaryNavy);
    oval(const Rect.fromLTWH(6, 56, 88, 74), shirt);
    if (index >= 3) {
      oval(
        Rect.fromLTWH(index == 5 ? 17 : 20, 13, index == 5 ? 66 : 60, 76),
        AppColors.primaryNavy,
      );
      if (index == 4) {
        oval(const Rect.fromLTWH(34, 4, 32, 28), AppColors.primaryNavy);
      }
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(41, 56, 18, 23),
        const Radius.circular(7),
      ),
      paint..color = skin,
    );
    oval(const Rect.fromLTWH(25, 25, 50, 44), skin);
    oval(const Rect.fromLTWH(24, 14, 52, 29), AppColors.primaryNavy);
    oval(const Rect.fromLTWH(30, 30, 40, 35), skin);
    if (index == 1) {
      canvas.drawPath(
        Path()
          ..moveTo(26, 32)
          ..lineTo(36, 13)
          ..lineTo(65, 16)
          ..lineTo(72, 28)
          ..lineTo(44, 25)
          ..close(),
        paint..color = AppColors.primaryNavy,
      );
    }
    if (index >= 3) {
      canvas.drawPath(
        Path()
          ..moveTo(25, 38)
          ..quadraticBezierTo(37, 12, 67, 24)
          ..quadraticBezierTo(47, 37, 25, 38),
        paint..color = AppColors.primaryNavy,
      );
      oval(const Rect.fromLTWH(25, 49, 4, 6), AppColors.primaryGold);
      oval(const Rect.fromLTWH(71, 49, 4, 6), AppColors.primaryGold);
    }
    oval(const Rect.fromLTWH(37, 43, 3, 4), AppColors.primaryNavy);
    oval(const Rect.fromLTWH(60, 43, 3, 4), AppColors.primaryNavy);
    canvas.drawPath(
      Path()
        ..moveTo(44, 56)
        ..quadraticBezierTo(50, 60, 56, 56),
      paint
        ..color = AppColors.primaryNavy
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    paint.style = PaintingStyle.fill;
    if (index == 2) {
      canvas.drawPath(
        Path()
          ..moveTo(33, 54)
          ..quadraticBezierTo(50, 76, 67, 54)
          ..lineTo(62, 68)
          ..quadraticBezierTo(50, 77, 38, 68)
          ..close(),
        paint..color = AppColors.primaryNavy,
      );
    }
    canvas.drawPath(
      Path()
        ..moveTo(39, 73)
        ..lineTo(50, 82)
        ..lineTo(61, 73),
      paint
        ..color = AppColors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PortraitPainter old) => old.index != index;
}
