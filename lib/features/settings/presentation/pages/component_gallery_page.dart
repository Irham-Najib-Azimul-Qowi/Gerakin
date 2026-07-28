import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/gallery_sections/buttons_section.dart';
import '../widgets/gallery_sections/cards_section.dart';
import '../widgets/gallery_sections/colors_section.dart';
import '../widgets/gallery_sections/feedback_section.dart';
import '../widgets/gallery_sections/indicators_section.dart';
import '../widgets/gallery_sections/inputs_section.dart';
import '../widgets/gallery_sections/loading_section.dart';
import '../widgets/gallery_sections/states_section.dart';
import '../widgets/gallery_sections/typography_section.dart';

/// Halaman Component Gallery (Storybook-style UI Showcase).
///
/// Menampilkan seluruh Design Tokens dan Reusable Components GERAKIN
/// untuk pengujian visual tanpa ketergantungan fitur aplikasi.
class ComponentGalleryPage extends StatelessWidget {
  const ComponentGalleryPage({super.key});

  static const List<Tab> _tabs = [
    Tab(text: 'Colors'),
    Tab(text: 'Typography'),
    Tab(text: 'Buttons'),
    Tab(text: 'Cards'),
    Tab(text: 'Inputs'),
    Tab(text: 'Indicators'),
    Tab(text: 'Loading'),
    Tab(text: 'Feedback'),
    Tab(text: 'States'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Component Gallery'),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.neutral600,
            tabs: _tabs,
          ),
        ),
        body: const TabBarView(
          children: [
            _GalleryTabWrapper(child: ColorsSection()),
            _GalleryTabWrapper(child: TypographySection()),
            _GalleryTabWrapper(child: ButtonsSection()),
            _GalleryTabWrapper(child: CardsSection()),
            _GalleryTabWrapper(child: InputsSection()),
            _GalleryTabWrapper(child: IndicatorsSection()),
            _GalleryTabWrapper(child: LoadingSection()),
            _GalleryTabWrapper(child: FeedbackSection()),
            _GalleryTabWrapper(child: StatesSection()),
          ],
        ),
      ),
    );
  }
}

class _GalleryTabWrapper extends StatelessWidget {
  const _GalleryTabWrapper({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingPage,
      child: child,
    );
  }
}
