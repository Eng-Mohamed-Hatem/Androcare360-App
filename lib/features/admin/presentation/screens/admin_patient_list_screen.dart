import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/admin/presentation/providers/admin_provider.dart';
import 'package:elajtech/features/admin/presentation/screens/admin_patient_detail_screen.dart';
import 'package:elajtech/features/admin/presentation/widgets/admin_account_status_chip.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Displays a searchable list of all patients for admin management.
class AdminPatientListScreen extends ConsumerStatefulWidget {
  const AdminPatientListScreen({super.key});

  @override
  ConsumerState<AdminPatientListScreen> createState() =>
      _AdminPatientListScreenState();
}

class _AdminPatientListScreenState
    extends ConsumerState<AdminPatientListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showInactiveOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadPatients().ignore();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UserModel> _filtered(List<UserModel> patients) {
    var list = patients;
    if (_showInactiveOnly) list = list.where((p) => !p.isActive).toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where(
            (p) =>
                p.fullName.toLowerCase().contains(q) ||
                p.email.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProvider);
    final filtered = _filtered(state.patients);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: const Text('إدارة المرضى'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'بحث بالاسم أو البريد...',
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
                    '${filtered.length} مريض',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (state.isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (filtered.isEmpty)
              const Expanded(
                child: Center(child: Text('لا يوجد مرضى')),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      ref.read(adminProvider.notifier).loadPatients(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final patient = filtered[i];
                      return _PatientTile(patient: patient);
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

class _PatientTile extends StatelessWidget {
  const _PatientTile({required this.patient});

  final UserModel patient;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => AdminPatientDetailScreen(patient: patient),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: patient.profileImage != null
                  ? NetworkImage(patient.profileImage!)
                  : null,
              backgroundColor: Colors.teal.withValues(alpha: 0.15),
              child: patient.profileImage == null
                  ? Text(
                      patient.fullName.isNotEmpty ? patient.fullName[0] : '?',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
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
                    patient.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    patient.email,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            AdminAccountStatusChip(isActive: patient.isActive),
          ],
        ),
      ),
    ),
  );
}
