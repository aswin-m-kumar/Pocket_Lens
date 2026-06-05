import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../core/theme/app_colors.dart';

class InsightsCard extends StatefulWidget {
  final List<String> insights;

  const InsightsCard({super.key, required this.insights});

  @override
  State<InsightsCard> createState() => _InsightsCardState();
}

class _InsightsCardState extends State<InsightsCard> {
  int _currentPage = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Fallback if list is empty
    final List<String> displayInsights = widget.insights.isEmpty
        ? <String>['Add more expense records to discover spending trends and insights.']
        : widget.insights;

    return Container(
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderSubtle, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header Row
          Row(
            children: <Widget>[
              Icon(
                PhosphorIconsRegular.lightbulb,
                color: kAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Insights',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: kTextSecondary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // PageView content
          SizedBox(
            height: 56,
            child: PageView.builder(
              controller: _pageController,
              itemCount: displayInsights.length,
              onPageChanged: (int index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (BuildContext context, int index) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    displayInsights[index],
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: kTextPrimary,
                      height: 1.4,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Dot Indicators
          if (displayInsights.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(displayInsights.length, (int index) {
                final bool isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: isActive ? 16 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: isActive ? kAccent : kTextMuted,
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}
