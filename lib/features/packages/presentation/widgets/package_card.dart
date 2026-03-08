/// PackageCard — بطاقة عرض الباقة في قائمة الباقات
///
/// تعرض هذه البطاقة: اسم الباقة، وصفًا مختصرًا، السعر، وشارة "الأكثر اختيارًا"
/// إذا كانت الباقة مميزة.
///
/// **English**: Displays a single [PackageEntity] in a card format.
/// Tapping navigates to [PackageDetailsPage].
///
/// **Spec**: tasks.md T037.
library;

import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/presentation/pages/package_details_page.dart';
import 'package:flutter/material.dart';

/// A card widget representing a single clinic package in a list.
///
/// **English**
/// Shows: package name, short description, price in EGP, and an amber badge
/// "الأكثر اختيارًا" when [PackageEntity.isFeatured] is true.
/// RTL layout, tappable — navigates to [PackageDetailsPage].
///
/// **Arabic**
/// بطاقة باقة سريرية تعرض: الاسم، الوصف المختصر، السعر، وشارة المميزة.
///
/// **Usage / الاستخدام**:
/// ```dart
/// PackageCard(package: packageEntity)
/// ```
class PackageCard extends StatelessWidget {
  /// Creates a [PackageCard] for [package].
  const PackageCard({required this.package, super.key});

  /// The package to display.
  final PackageEntity package;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        key: Key('package_card_${package.id}'),
        onTap: () async {
          await Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (_) => PackageDetailsPage(
                clinicId: package.clinicId,
                packageId: package.id,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Featured badge (conditional)
              if (package.isFeatured) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'الأكثر اختيارًا',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // Package name
              Text(
                package.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),

              // Short description
              Text(
                package.shortDescription,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),

              // Price row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${package.price.toStringAsFixed(0)} جنيه',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  // Validity info
                  Text(
                    '${package.validityDays} يوم',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
