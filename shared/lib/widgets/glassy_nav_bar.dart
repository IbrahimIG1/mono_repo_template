import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GlassyNavItem {
  final String label;
  final IconData icon;

  const GlassyNavItem({required this.label, required this.icon});
}

class GlassyNavBar extends StatelessWidget {
  final List<GlassyNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final double width;
  final double height;
  final EdgeInsets padding;
  final double radius;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final List<BoxShadow> boxShadow;
  final TextDirection textDirection;
  final Color activeColor;
  final Color inactiveColor;
  final double indicatorWidth;
  final double indicatorHeight;

  const GlassyNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.width = double.infinity,
    this.height = 72,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    this.radius = 8,
    this.backgroundColor = const Color(0xB3000000),
    this.borderColor = const Color(0x14FFFFFF),
    this.borderWidth = 1,
    this.boxShadow = const [
      BoxShadow(
        color: Color(0x40000000),
        blurRadius: 24,
        offset: Offset(0, 12),
      ),
    ],
    this.textDirection = TextDirection.ltr,
    this.activeColor = const Color(0xFFF2F2F2),
    this.inactiveColor = const Color(0xFF9B9B9B),
    this.indicatorWidth = 18,
    this.indicatorHeight = 2,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: width.w,
        height: height.h,
        padding: padding,
        decoration: BoxDecoration(
          // Overlay color: tweak opacity to reveal more/less background.
          color: backgroundColor,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: boxShadow,
        ),
        child: Directionality(
          textDirection: textDirection,
          child: Row(
            children: List.generate(
              items.length,
              (index) => Expanded(
                child: _NavButton(
                  item: items[index],
                  isActive: index == currentIndex,
                  onTap: () => onTap(index),
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                  indicatorWidth: indicatorWidth,
                  indicatorHeight: indicatorHeight,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final GlassyNavItem item;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;
  final double indicatorWidth;
  final double indicatorHeight;

  const _NavButton({
    required this.item,
    required this.isActive,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
    required this.indicatorWidth,
    required this.indicatorHeight,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : inactiveColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              height: indicatorHeight,
              width: isActive ? indicatorWidth : 0,
              decoration: BoxDecoration(
                color: isActive ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
