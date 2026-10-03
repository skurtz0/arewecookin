import 'package:flutter/material.dart';

/// Reliable, beautiful recipe image widget with shimmer loading and artistic fallback.
class RecipeImage extends StatelessWidget {
  final String? imageUrl;
  final String category;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final Widget? overlay;

  const RecipeImage({
    super.key,
    required this.imageUrl,
    required this.category,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.overlay,
  });

  Color _categoryBaseColor(String cat) {
    switch (cat) {
      case 'Ana Yemek':
        return const Color(0xFFEF4444);
      case 'Tatlı':
        return const Color(0xFFEC4899);
      case 'Çorba':
        return const Color(0xFFF97316);
      case 'Kahvaltılık':
        return const Color(0xFFEAB308);
      case 'Pratik':
        return const Color(0xFF06B6D4);
      case 'Hamur İşi':
        return const Color(0xFF8B5CF6);
      case 'Salata':
        return const Color(0xFF10B981);
      case 'Vegan':
        return const Color(0xFF14B8A6);
      default:
        return const Color(0xFFFF5722);
    }
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Ana Yemek':
        return Icons.restaurant_rounded;
      case 'Tatlı':
        return Icons.cake_rounded;
      case 'Çorba':
        return Icons.soup_kitchen_rounded;
      case 'Kahvaltılık':
        return Icons.egg_alt_rounded;
      case 'Pratik':
        return Icons.bolt_rounded;
      case 'Hamur İşi':
        return Icons.bakery_dining_rounded;
      case 'Salata':
        return Icons.eco_rounded;
      case 'Vegan':
        return Icons.spa_rounded;
      default:
        return Icons.dinner_dining_rounded;
    }
  }

  Widget _buildFallback() {
    final baseColor = _categoryBaseColor(category);
    final iconData = _categoryIcon(category);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            baseColor.withValues(alpha: 0.85),
            baseColor,
            Color.lerp(baseColor, Colors.black, 0.25)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background subtle pattern
          Positioned(
            right: -15,
            bottom: -15,
            child: Icon(
              iconData,
              size: 90,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final validRadius = borderRadius ?? BorderRadius.zero;

    Widget imageContent;

    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      imageContent = _buildFallback();
    } else {
      imageContent = Image.network(
        imageUrl!,
        headers: const {'User-Agent': 'AreWeCookinApp/1.0 (culinary-app)'},
        width: width,
        height: height,
        fit: fit,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return Container(
            width: width,
            height: height,
            color: Colors.grey.shade100,
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _categoryBaseColor(category).withValues(alpha: 0.7),
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildFallback();
        },
      );
    }

    return ClipRRect(
      borderRadius: validRadius,
      child: Stack(
        children: [
          imageContent,
          ?overlay,
        ],
      ),
    );
  }
}
