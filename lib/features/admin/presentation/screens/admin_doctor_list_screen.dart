import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/admin/presentation/providers/admin_provider.dart';
import 'package:elajtech/features/admin/presentation/screens/admin_doctor_detail_screen.dart';
import 'package:elajtech/features/admin/presentation/widgets/admin_account_status_chip.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Displays a searchable, filterable list of all doctors.
///
/// Tap a row to open [AdminDoctorDetailScreen] for full profile management.
class AdminDoctorListScreen extends ConsumerStatefulWidget {
  const AdminDoctorListScreen({super.key});

  @override
  ConsumerState<AdminDoctorListScreen> createState() =>
      _AdminDoctorListScreenState();
}

class _AdminDoctorListScreenState extends ConsumerState<AdminDoctorListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showInactiveOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadDoctors();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UserModel> _filtered(List<UserModel> doctors) {
    var list = doctors;
    if (_showInactiveOnly) list = list.where((d) => !d.isActive).toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where(
            (d) =>
                d.fullName.toLowerCase().contains(q) ||
                (d.specializations?.any((s) => s.toLowerCase().contains(q)) ??
                    false) ||
                d.email.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProvider);
    final filtered = _filtered(state.doctors);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: const Text('إدارة الأطباء'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => const AdminDoctorDetailScreen(doctor: null),
            ),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('إضافة طبيب'),
        ),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'بحث بالاسم أو التخصص...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
            // Filter chip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('معطّلون فقط'),
                    selected: _showInactiveOnly,
                    onSelected: (v) => setState(() => _showInactiveOnly = v),
                    selectedColor: Colors.red.shade100,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${filtered.length} طبيب',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // List
            if (state.isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (filtered.isEmpty)
              const Expanded(
                child: Center(child: Text('لا يوجد أطباء')),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      ref.read(adminProvider.notifier).loadDoctors(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final doctor = filtered[i];
                      return _DoctorTile(doctor: doctor);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DoctorTile extends StatelessWidget {
  const _DoctorTile({required this.doctor});

  final UserModel doctor;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => AdminDoctorDetailScreen(doctor: doctor),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundImage: doctor.profileImage != null
                  ? NetworkImage(doctor.profileImage!)
                  : null,
              backgroundColor: AppColors.primary.withOpacity(0.15),
              child: doctor.profileImage == null
                  ? Text(
                      doctor.fullName.isNotEmpty ? doctor.fullName[0] : '?',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  if (doctor.specializations?.isNotEmpty ?? false)
                    Text(
                      doctor.specializations!.first,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  Text(
                    doctor.email,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            AdminAccountStatusChip(isActive: doctor.isActive),
          ],
        ),
      ),
    ),
  );
}
