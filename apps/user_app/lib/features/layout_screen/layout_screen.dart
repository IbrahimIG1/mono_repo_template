import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:monorepo_template/features/home_screen/home_screen.dart';
import 'package:shared/widgets/glassy_nav_bar.dart';

class LayoutScreen extends StatefulWidget {
  const LayoutScreen({super.key});

  @override
  State<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen> {
  final List<GlassyNavItem> _items = const [
    GlassyNavItem(
      label: 'الرئيسية',
      icon: Icons.home_rounded,
    ),
    GlassyNavItem(
      label: 'الخدمات',
      icon: Icons.miscellaneous_services_rounded,
    ),
    GlassyNavItem(
      label: 'العقارات',
      icon: Icons.apartment_rounded,
    ),
    GlassyNavItem(
      label: 'الطلبات',
      icon: Icons.receipt_long_rounded,
    ),
    GlassyNavItem(
      label: 'صفحتي',
      icon: Icons.person_rounded,
    ),
  ];

  final List<Widget> _screens = const [
    HomeScreen(),
    _PlaceholderScreen(title: 'Explore'),
    _PlaceholderScreen(title: 'Orders'),
    _PlaceholderScreen(title: 'Saved'),
    _PlaceholderScreen(title: 'Profile'),
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens),
          Align(
            alignment: Alignment.bottomCenter,
            child: LiquidGlassLayer(
              settings: const LiquidGlassSettings(
                thickness: 10,
                blur: 4,
                glassColor: Color(0xB3000000),
              ),
              child: LiquidGlass(
                shape: LiquidRoundedRectangle(borderRadius: 8),
                child: GlassyNavBar(
                  items: _items,
                  currentIndex: _currentIndex,
                  onTap: (index) => setState(() => _currentIndex = index),
                  width: 375.w,
                  height: 101.h,
                  radius: 8,
                  backgroundColor: Colors.transparent,
                  borderColor: Colors.transparent,
                  borderWidth: 0,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFFF7F5F2),
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

