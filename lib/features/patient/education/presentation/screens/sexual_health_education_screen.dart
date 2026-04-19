import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/patient/education/content/sexual_health_treatment_content.dart';
import 'package:elajtech/features/patient/appointments/presentation/screens/select_doctor_for_appointment_screen.dart';
import 'package:flutter/material.dart';

class SexualHealthEducationHubScreen extends StatelessWidget {
  const SexualHealthEducationHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أحدث أساليب علاج الضعف الجنسي'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.sexualHealthLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.sexualHealth.withValues(alpha: 0.18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: AppColors.sexualHealth,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'معلومات تثقيفية تساعدك على فهم الخيارات العلاجية المتاحة قبل الاستشارة.',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimaryLight,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    sexualHealthEducationDisclaimer,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryLight,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'الخيارات العلاجية',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...sexualHealthTreatments.map(
              (treatment) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _TreatmentCategoryCard(treatment: treatment),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () async {
                await Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) =>
                        const SelectDoctorForAppointmentScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.calendar_today_outlined),
              label: const Text('احجز استشارة لتحديد العلاج المناسب'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.sexualHealth,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SexualHealthTreatmentDetailsScreen extends StatelessWidget {
  const SexualHealthTreatmentDetailsScreen({
    required this.treatment,
    super.key,
  });

  final TreatmentInfo treatment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(treatment.title), centerTitle: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    treatment.color,
                    treatment.color.withValues(alpha: 0.75),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      treatment.tag,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    treatment.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    treatment.englishTitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    treatment.summary,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _InfoSectionCard(
              title: 'مهم',
              icon: Icons.info_outline,
              items: const [sexualHealthEducationDisclaimer],
              color: Colors.amber.shade800,
            ),
            const SizedBox(height: 16),
            _InfoSectionCard(
              title: 'طريقة العمل',
              icon: Icons.settings_suggest_outlined,
              items: treatment.howItWorks,
              color: treatment.color,
            ),
            const SizedBox(height: 16),
            _InfoSectionCard(
              title: 'دواعي الاستعمال',
              icon: Icons.check_circle_outline,
              items: treatment.useCases,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            _InfoSectionCard(
              title: 'من قد لا يناسبه العلاج؟',
              icon: Icons.health_and_safety_outlined,
              items: treatment.precautions,
              color: Colors.deepOrange,
            ),
            const SizedBox(height: 16),
            _InfoSectionCard(
              title: 'عدد الجلسات أو مدة الإجراء',
              icon: Icons.schedule_outlined,
              items: treatment.sessionInfo,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 16),
            _InfoSectionCard(
              title: 'ماذا تتوقع بعد العلاج؟',
              icon: Icons.trending_up_outlined,
              items: treatment.expectedOutcome,
              color: Colors.purple,
            ),
            const SizedBox(height: 16),
            _FaqSection(faqs: treatment.faqs),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () async {
                await Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) =>
                        const SelectDoctorForAppointmentScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.calendar_today_outlined),
              label: const Text('احجز استشارة'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.sexualHealth,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.grid_view_rounded),
              label: const Text('جميع الطرق العلاجية'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TreatmentCategoryCard extends StatelessWidget {
  const _TreatmentCategoryCard({required this.treatment});

  final TreatmentInfo treatment;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${treatment.title}، يفتح صفحة معلومات العلاج',
      child: InkWell(
        key: ValueKey<String>(treatment.id),
        onTap: () async {
          await Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (context) =>
                  SexualHealthTreatmentDetailsScreen(treatment: treatment),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: treatment.color.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: treatment.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(treatment.icon, color: treatment.color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      treatment.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      treatment.summary,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryLight,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: treatment.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        treatment.tag,
                        style: TextStyle(
                          color: treatment.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: treatment.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoSectionCard extends StatelessWidget {
  const _InfoSectionCard({
    required this.title,
    required this.icon,
    required this.items,
    required this.color,
  });

  final String title;
  final IconData icon;
  final List<String> items;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Icon(Icons.circle, size: 8, color: color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqSection extends StatelessWidget {
  const _FaqSection({required this.faqs});

  final List<TreatmentFaq> faqs;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ExpansionPanelList.radio(
        elevation: 0,
        expandedHeaderPadding: EdgeInsets.zero,
        children: faqs
            .map(
              (faq) => ExpansionPanelRadio(
                value: faq.question,
                canTapOnHeader: true,
                headerBuilder: (context, isExpanded) => ListTile(
                  title: Text(
                    faq.question,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                body: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    faq.answer,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
