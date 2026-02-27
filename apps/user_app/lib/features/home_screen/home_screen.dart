import 'package:flutter/material.dart';
import 'package:shared/styles/fonts/app_text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('Home Screen', style: AppTextStyles().fontBlack20Bold),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.search, color: Colors.black),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
        children: [
          _PromoCard(),
          const SizedBox(height: 16),
          _SectionHeader(title: 'Recommended'),
          const SizedBox(height: 12),
          ...List.generate(6, (index) => _ListingCard(index: index)),
          const SizedBox(height: 16),
          _SectionHeader(title: 'Popular'),
          const SizedBox(height: 12),
          ...List.generate(4, (index) => _ListingCard(index: index + 6)),
        ],
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFECE7E1), Color(0xFFDCD4CB)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Discover modern living spaces',
            style: AppTextStyles().fontBlack20Bold,
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTextStyles().fontBlack16Medium);
  }
}

class _ListingCard extends StatelessWidget {
  final int index;
  const _ListingCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              gradient: LinearGradient(
                colors: index.isEven
                    ? const [Color(0xFFDDD3C8), Color(0xFFCABFAF)]
                    : const [Color(0xFFD9E2EC), Color(0xFFBBC8D9)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Modern villa in the city',
                  style: AppTextStyles().fontBlack16Medium,
                ),
                const SizedBox(height: 6),
                Text(
                  '2 beds • 1 bath • 1200 sqft',
                  style: AppTextStyles().fontGrey14Regular,
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${(index + 3) * 120}',
                  style: AppTextStyles().fontGoldDark16Bold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

