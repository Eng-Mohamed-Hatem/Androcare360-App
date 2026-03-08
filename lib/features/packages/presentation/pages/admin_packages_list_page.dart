import 'dart:async';
import 'package:elajtech/core/constants/app_colors.dart';

import 'package:elajtech/features/packages/data/constants/clinic_ids.dart';
import 'package:elajtech/features/packages/domain/entities/package_entity.dart';
import 'package:elajtech/features/packages/presentation/pages/create_edit_package_page.dart';
import 'package:elajtech/features/packages/presentation/providers/admin_packages_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminPackagesListPage extends ConsumerStatefulWidget {
  const AdminPackagesListPage({super.key});

  @override
  ConsumerState<AdminPackagesListPage> createState() =>
      _AdminPackagesListPageState();
}

class _AdminPackagesListPageState extends ConsumerState<AdminPackagesListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Map<String, String> _clinicNames = {
    ClinicIds.andrology: 'عيادة الذكورة والتأخر الإنجابي',
    ClinicIds.physiotherapy: 'عيادة العلاج الطبيعي',
    ClinicIds.nutrition: 'عيادة التغذية',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedClinicId = ref.watch(adminSelectedClinicProvider);
    final packagesAsync = ref.watch(adminPackagesListProvider);

    // Listen for write operations (create, edit, duplicate, toggle status)
    ref.listen(adminPackageWriteProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_getFailureMessage(next.error))));
      } else if (!next.isLoading && (previous?.isLoading ?? false)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تمت العملية بنجاح')));
      }
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: const Text('إدارة الباقات'),
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'النشطة'),
              Tab(text: 'غير النشطة / المخفية'),
            ],
          ),
          actions: [
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedClinicId,
                dropdownColor: AppColors.primary,
                iconEnabledColor: Colors.white,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                items: _clinicNames.entries.map((e) {
                  return DropdownMenuItem<String>(
                    value: e.key,
                    child: Text(e.value),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    ref.read(adminSelectedClinicProvider.notifier).state = val;
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: packagesAsync.when(
          data: (packages) {
            final activePackages = packages
                .where((p) => p.status == PackageStatus.active)
                .toList();
            final inactivePackages = packages
                .where((p) => p.status != PackageStatus.active)
                .toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildListView(activePackages),
                _buildListView(inactivePackages),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Text(
              'حدث خطأ: $err',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            unawaited(
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const CreateEditPackagePage(),
                ),
              ),
            );
          },
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'إضافة باقة',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildListView(List<PackageEntity> packages) {
    if (packages.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد باقات',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: packages.length,
      itemBuilder: (context, index) {
        final pkg = packages[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        pkg.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (pkg.isFeatured)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'مميزة',
                          style: TextStyle(color: Colors.amber, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${pkg.price} ${pkg.currency}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        unawaited(
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  CreateEditPackagePage(packageToEdit: pkg),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('تعديل'),
                    ),
                    TextButton.icon(
                      onPressed: () => _confirmDuplicate(pkg),
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('نسخ'),
                    ),
                    Switch(
                      value: pkg.status == PackageStatus.active,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) {
                        final newStatus = val
                            ? PackageStatus.active
                            : PackageStatus.inactive;
                        unawaited(
                          ref
                              .read(adminPackageWriteProvider.notifier)
                              .toggleStatus(
                                clinicId: pkg.clinicId,
                                packageId: pkg.id,
                                status: newStatus,
                              ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDuplicate(PackageEntity pkg) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('نسخ الباقة'),
          content: Text('هل تريد إنشاء نسخة من باقة "${pkg.name}"؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                unawaited(
                  ref
                      .read(adminPackageWriteProvider.notifier)
                      .duplicatePackage(
                        clinicId: pkg.clinicId,
                        packageId: pkg.id,
                      ),
                );
              },
              child: const Text('نعم، انسخ'),
            ),
          ],
        ),
      ),
    );
  }

  String _getFailureMessage(Object? error) {
    if (error == null) return 'حدث خطأ غير معروف';
    return error.toString();
  }
}
