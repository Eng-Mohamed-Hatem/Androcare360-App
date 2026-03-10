import 'package:elajtech/core/constants/specialty_constants.dart';
import 'package:elajtech/features/patient/home/presentation/widgets/doctor_card.dart';
import 'package:elajtech/shared/providers/registered_doctors_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DoctorsListScreen extends ConsumerStatefulWidget {
  const DoctorsListScreen({super.key, this.category, this.searchQuery});
  final String? category;
  final String? searchQuery;

  @override
  ConsumerState<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends ConsumerState<DoctorsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _currentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.searchQuery != null) {
      _searchController.text = widget.searchQuery!;
      _currentSearchQuery = widget.searchQuery!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(doctorsListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.category ?? 'جميع الأطباء')),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'بحث عن طبيب...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _currentSearchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _currentSearchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _currentSearchQuery = value;
                });
              },
            ),
          ),

          // Doctors List
          Expanded(
            child: doctorsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('خطأ: $err')),
              data: (doctors) {
                // Filter Logic
                final filteredDoctors = doctors.where((doctor) {
                  // Filter by Category
                  if (widget.category != null) {
                    final specs = doctor.specializations ?? [];

                    // Use SpecialtyConstants for more robust matching if available
                    var isMatch = false;
                    final category = widget.category!;

                    if (category.contains('ذكورة') ||
                        category.contains('andrology')) {
                      isMatch = SpecialtyConstants.isAndrologyDoctor(specs);
                    } else if (category.contains('تغذية') ||
                        category.contains('nutrition') ||
                        category.contains('سمنة')) {
                      isMatch = SpecialtyConstants.isNutritionDoctor(specs);
                    } else if (category.contains('طبيعي') ||
                        category.contains('physiotherapy')) {
                      isMatch = SpecialtyConstants.isPhysiotherapyDoctor(specs);
                    } else if (category.contains('باطنة') ||
                        category.contains('internal')) {
                      isMatch = SpecialtyConstants.isInternalMedicineDoctor(
                        specs,
                      );
                    } else {
                      // Fallback to existing logic for other categories
                      isMatch =
                          specs.contains(category) ||
                          specs.any((s) => s.contains(category));
                    }

                    if (!isMatch) return false;
                  }

                  // Filter by Search
                  if (_currentSearchQuery.isNotEmpty) {
                    final query = _currentSearchQuery.toLowerCase();
                    final name = doctor.fullName.toLowerCase();
                    final specs = (doctor.specializations ?? [])
                        .map((s) => s.toLowerCase())
                        .toList();
                    final matchesSpec = specs.any((s) => s.contains(query));
                    if (!name.contains(query) && !matchesSpec) {
                      return false;
                    }
                  }

                  return true;
                }).toList();

                if (filteredDoctors.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('لا يوجد أطباء مطابقين للبحث'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 100,
                  ),
                  itemCount: filteredDoctors.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DoctorCard(doctor: filteredDoctors[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
