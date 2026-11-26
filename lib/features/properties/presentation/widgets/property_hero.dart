import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:egy/app/router/route_names.dart';

import '../../domain/entities/property_listing.dart';
import 'property_photo.dart';
import 'property_image_clipper.dart';
import 'package:egy/core/widgets/curve_divider.dart';

/// Carries the tapped image into the first frame of the details route.
class PropertyPreview {
  const PropertyPreview(this.property, this.tag);

  final PropertyListing property;
  final Object tag;

  void open(BuildContext context) {
    context.pushNamed(
      RouteNames.propertyDetails,
      pathParameters: {'id': '${property.id}'},
      extra: this,
    );
  }
}

/// Uses the same image and clipping on both sides of the route transition.
class PropertyHero extends StatelessWidget {
  const PropertyHero({
    super.key,
    required this.property,
    this.tag,
    this.radius = 24,
    this.curved = false,
  });

  final PropertyListing property;
  final Object? tag;
  final double radius;
  final bool curved;

  /// Picks the primary image or the first valid gallery image.
  static String? imageUrl(PropertyListing property) =>
      PropertyPhoto.isValidUrl(property.imageUrl)
      ? property.imageUrl
      : property.images.where(PropertyPhoto.isValidUrl).firstOrNull;

  @override
  Widget build(BuildContext context) {
    final clipper = PropertyImageClipper(radius: radius, curve: curved ? 1 : 0);
    final photo = ClipPath(
      clipper: clipper,
      child: PropertyPhoto(url: imageUrl(property)),
    );
    final heroTag = tag;
    if (heroTag == null || MediaQuery.disableAnimationsOf(context)) {
      return curved ? CurveDivider(clipper: clipper, child: photo) : photo;
    }

    final hero = Hero(
      tag: heroTag,
      flightShuttleBuilder: (_, animation, direction, from, to) {
        final flightPhoto = (from.widget as Hero).child as ClipPath;
        final fromShape = flightPhoto.clipper! as PropertyImageClipper;
        final toShape =
            ((to.widget as Hero).child as ClipPath).clipper!
                as PropertyImageClipper;
        return AnimatedBuilder(
          animation: animation,
          child: flightPhoto.child,
          builder: (_, child) => ClipPath(
            clipper: PropertyImageClipper.lerp(
              fromShape,
              toShape,
              direction == HeroFlightDirection.push
                  ? animation.value
                  : 1 - animation.value,
            ),
            child: child,
          ),
        );
      },
      child: photo,
    );
    return curved ? CurveDivider(clipper: clipper, child: hero) : hero;
  }
}
