// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:cloud_functions/cloud_functions.dart' as _i809;
import 'package:elajtech/core/auth/clinic_access_resolver.dart' as _i838;
import 'package:elajtech/core/di/core_module.dart' as _i35;
import 'package:elajtech/core/di/firebase_module.dart' as _i859;
import 'package:elajtech/core/services/call_monitoring_service.dart' as _i748;
import 'package:elajtech/core/services/cloud_functions_version_service.dart'
    as _i108;
import 'package:elajtech/core/services/fcm_service.dart' as _i990;
import 'package:elajtech/core/services/storage_service.dart' as _i1028;
import 'package:elajtech/core/services/token_refresh_service.dart' as _i839;
import 'package:elajtech/core/services/voip_call_service.dart' as _i15;
import 'package:elajtech/features/admin/data/repositories/admin_repository_impl.dart'
    as _i423;
import 'package:elajtech/features/admin/domain/repositories/admin_repository.dart'
    as _i341;
import 'package:elajtech/features/appointments/data/repositories/appointment_repository_impl.dart'
    as _i1049;
import 'package:elajtech/features/appointments/domain/repositories/appointment_repository.dart'
    as _i980;
import 'package:elajtech/features/auth/data/repositories/auth_repository_impl.dart'
    as _i235;
import 'package:elajtech/features/auth/domain/repositories/auth_repository.dart'
    as _i1019;
import 'package:elajtech/features/device_requests/data/repositories/device_request_repository_impl.dart'
    as _i75;
import 'package:elajtech/features/device_requests/domain/repositories/device_request_repository.dart'
    as _i574;
import 'package:elajtech/features/doctor/data/repositories/doctor_repository_impl.dart'
    as _i601;
import 'package:elajtech/features/doctor/domain/repositories/doctor_repository.dart'
    as _i580;
import 'package:elajtech/features/doctor/medical_records/data/repositories/physiotherapy_emr_repository.dart'
    as _i602;
import 'package:elajtech/features/emr/data/repositories/emr_repository_impl.dart'
    as _i900;
import 'package:elajtech/features/emr/data/repositories/internal_medicine_emr_repository_impl.dart'
    as _i283;
import 'package:elajtech/features/emr/data/repositories/nutrition_emr_repository_impl.dart'
    as _i772;
import 'package:elajtech/features/emr/data/repositories/physiotherapy_emr_repository_impl.dart'
    as _i980;
import 'package:elajtech/features/emr/domain/repositories/emr_repository.dart'
    as _i668;
import 'package:elajtech/features/emr/domain/repositories/internal_medicine_emr_repository.dart'
    as _i281;
import 'package:elajtech/features/emr/domain/repositories/nutrition_emr_repository.dart'
    as _i563;
import 'package:elajtech/features/emr/domain/repositories/physiotherapy_emr_repository.dart'
    as _i691;
import 'package:elajtech/features/lab_requests/data/repositories/lab_request_repository_impl.dart'
    as _i1022;
import 'package:elajtech/features/lab_requests/domain/repositories/lab_request_repository.dart'
    as _i558;
import 'package:elajtech/features/notifications/data/repositories/notification_repository_impl.dart'
    as _i838;
import 'package:elajtech/features/notifications/domain/repositories/notification_repository.dart'
    as _i70;
import 'package:elajtech/features/nutrition/data/repositories/nutrition_emr_repository_impl.dart'
    as _i605;
import 'package:elajtech/features/nutrition/domain/repositories/nutrition_emr_repository.dart'
    as _i205;
import 'package:elajtech/features/packages/data/adapters/package_payment_adapter_impl.dart'
    as _i827;
import 'package:elajtech/features/packages/data/datasources/firebase_storage_package_datasource.dart'
    as _i958;
import 'package:elajtech/features/packages/data/datasources/firestore_package_datasource.dart'
    as _i220;
import 'package:elajtech/features/packages/data/repositories/package_document_repository_impl.dart'
    as _i789;
import 'package:elajtech/features/packages/data/repositories/patient_package_repository_impl.dart'
    as _i720;
import 'package:elajtech/features/packages/domain/adapters/package_payment_adapter.dart'
    as _i399;
import 'package:elajtech/features/packages/domain/repositories/package_document_repository.dart'
    as _i28;
import 'package:elajtech/features/packages/domain/repositories/patient_package_repository.dart'
    as _i302;
import 'package:elajtech/features/packages/domain/usecases/create_clinic_package_usecase.dart'
    as _i413;
import 'package:elajtech/features/packages/domain/usecases/duplicate_package_usecase.dart'
    as _i254;
import 'package:elajtech/features/packages/domain/usecases/get_patient_packages_for_admin_usecase.dart'
    as _i257;
import 'package:elajtech/features/packages/domain/usecases/list_clinic_packages_for_admin_usecase.dart'
    as _i256;
import 'package:elajtech/features/packages/domain/usecases/toggle_package_status_usecase.dart'
    as _i799;
import 'package:elajtech/features/packages/domain/usecases/update_clinic_package_usecase.dart'
    as _i793;
import 'package:elajtech/features/packages/domain/usecases/update_package_service_usage_usecase.dart'
    as _i674;
import 'package:elajtech/features/packages/domain/usecases/upload_package_document_usecase.dart'
    as _i1063;
import 'package:elajtech/features/patient/home/data/repositories/medical_screening_repository_impl.dart'
    as _i902;
import 'package:elajtech/features/patient/home/domain/repositories/medical_screening_repository.dart'
    as _i1026;
import 'package:elajtech/features/prescriptions/data/repositories/prescription_repository_impl.dart'
    as _i681;
import 'package:elajtech/features/prescriptions/domain/repositories/prescription_repository.dart'
    as _i824;
import 'package:elajtech/features/radiology_requests/data/repositories/radiology_request_repository_impl.dart'
    as _i174;
import 'package:elajtech/features/radiology_requests/domain/repositories/radiology_request_repository.dart'
    as _i54;
import 'package:elajtech/features/user/data/repositories/user_repository_impl.dart'
    as _i431;
import 'package:elajtech/features/user/domain/repositories/user_repository.dart'
    as _i21;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:firebase_storage/firebase_storage.dart' as _i457;
import 'package:flutter/material.dart' as _i409;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final coreModule = _$CoreModule();
    final firebaseModule = _$FirebaseModule();
    gh.lazySingleton<_i409.GlobalKey<_i409.NavigatorState>>(
      () => coreModule.navigatorKey,
    );
    gh.lazySingleton<_i59.FirebaseAuth>(() => firebaseModule.firebaseAuth);
    gh.lazySingleton<_i974.FirebaseFirestore>(
      () => firebaseModule.firebaseFirestore,
    );
    gh.lazySingleton<_i809.FirebaseFunctions>(
      () => firebaseModule.firebaseFunctions,
    );
    gh.lazySingleton<_i457.FirebaseStorage>(
      () => firebaseModule.firebaseStorage,
    );
    gh.lazySingleton<_i602.PhysiotherapyEMRRepository>(
      () => _i602.PhysiotherapyEMRRepository(),
    );
    gh.lazySingleton<_i799.TogglePackageStatusUseCase>(
      () => _i799.TogglePackageStatusUseCase(),
    );
    gh.lazySingleton<_i793.UpdateClinicPackageUseCase>(
      () => _i793.UpdateClinicPackageUseCase(),
    );
    gh.lazySingleton<_i838.ClinicAccessResolver>(
      () => _i838.ClinicAccessResolver(
        gh<_i59.FirebaseAuth>(),
        gh<_i974.FirebaseFirestore>(),
      ),
    );
    gh.lazySingleton<_i413.CreateClinicPackageUseCase>(
      () => _i413.CreateClinicPackageUseCase(gh<_i838.ClinicAccessResolver>()),
    );
    gh.lazySingleton<_i254.DuplicatePackageUseCase>(
      () => _i254.DuplicatePackageUseCase(gh<_i838.ClinicAccessResolver>()),
    );
    gh.lazySingleton<_i256.ListClinicPackagesForAdminUseCase>(
      () => _i256.ListClinicPackagesForAdminUseCase(
        gh<_i838.ClinicAccessResolver>(),
      ),
    );
    gh.lazySingleton<_i399.PackagePaymentAdapter>(
      () => const _i827.PackagePaymentAdapterImpl(),
    );
    gh.lazySingleton<_i1026.MedicalScreeningRepository>(
      () => _i902.MedicalScreeningRepositoryImpl(),
    );
    gh.lazySingleton<_i281.InternalMedicineEMRRepository>(
      () => _i283.InternalMedicineEMRRepositoryImpl(
        firestore: gh<_i974.FirebaseFirestore>(),
      ),
    );
    gh.lazySingleton<_i21.UserRepository>(
      () => _i431.UserRepositoryImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i54.RadiologyRequestRepository>(
      () => _i174.RadiologyRequestRepositoryImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i980.AppointmentRepository>(
      () => _i1049.AppointmentRepositoryImpl(
        gh<_i974.FirebaseFirestore>(),
        gh<_i809.FirebaseFunctions>(),
      ),
    );
    gh.lazySingleton<_i70.NotificationRepository>(
      () => _i838.NotificationRepositoryImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i341.AdminRepository>(
      () => _i423.AdminRepositoryImpl(
        gh<_i974.FirebaseFirestore>(),
        gh<_i809.FirebaseFunctions>(),
      ),
    );
    gh.lazySingleton<_i1028.StorageService>(
      () => _i1028.StorageService(gh<_i457.FirebaseStorage>()),
    );
    gh.lazySingleton<_i958.FirebaseStoragePackageDatasource>(
      () => _i958.FirebaseStoragePackageDatasource(gh<_i457.FirebaseStorage>()),
    );
    gh.lazySingleton<_i668.EMRRepository>(
      () => _i900.EMRRepositoryImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i824.PrescriptionRepository>(
      () => _i681.PrescriptionRepositoryImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i108.CloudFunctionsVersionService>(
      () => _i108.CloudFunctionsVersionService(gh<_i809.FirebaseFunctions>()),
    );
    gh.lazySingleton<_i205.NutritionEMRRepository>(
      () => _i605.NutritionEMRRepositoryImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i574.DeviceRequestRepository>(
      () => _i75.DeviceRequestRepositoryImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i558.LabRequestRepository>(
      () => _i1022.LabRequestRepositoryImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i748.CallMonitoringService>(
      () => _i748.CallMonitoringService(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i220.FirestorePackageDatasource>(
      () => _i220.FirestorePackageDatasource(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i674.UpdatePackageServiceUsageUseCase>(
      () =>
          _i674.UpdatePackageServiceUsageUseCase(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i563.NutritionEMRRepository>(
      () => _i772.NutritionEMRRepositoryImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i839.TokenRefreshService>(
      () => _i839.TokenRefreshService(gh<_i59.FirebaseAuth>()),
    );
    gh.lazySingleton<_i580.DoctorRepository>(
      () => _i601.DoctorRepositoryImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i691.PhysiotherapyEMRRepository>(
      () => _i980.PhysiotherapyEMRRepositoryImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i28.PackageDocumentRepository>(
      () => _i789.PackageDocumentRepositoryImpl(
        gh<_i220.FirestorePackageDatasource>(),
        gh<_i958.FirebaseStoragePackageDatasource>(),
      ),
    );
    gh.lazySingleton<_i15.VoIPCallService>(
      () => _i15.VoIPCallService(gh<_i748.CallMonitoringService>()),
    );
    gh.lazySingleton<_i1063.UploadPackageDocumentUseCase>(
      () => _i1063.UploadPackageDocumentUseCase(
        gh<_i28.PackageDocumentRepository>(),
        gh<_i70.NotificationRepository>(),
      ),
    );
    gh.lazySingleton<_i302.PatientPackageRepository>(
      () => _i720.PatientPackageRepositoryImpl(
        gh<_i220.FirestorePackageDatasource>(),
      ),
    );
    gh.lazySingleton<_i990.FCMService>(
      () => _i990.FCMService(
        gh<_i974.FirebaseFirestore>(),
        gh<_i59.FirebaseAuth>(),
        gh<_i748.CallMonitoringService>(),
        gh<_i15.VoIPCallService>(),
      ),
    );
    gh.lazySingleton<_i257.GetPatientPackagesForAdminUseCase>(
      () => _i257.GetPatientPackagesForAdminUseCase(
        gh<_i302.PatientPackageRepository>(),
      ),
    );
    gh.lazySingleton<_i1019.AuthRepository>(
      () => _i235.AuthRepositoryImpl(
        gh<_i59.FirebaseAuth>(),
        gh<_i974.FirebaseFirestore>(),
        gh<_i839.TokenRefreshService>(),
        gh<_i990.FCMService>(),
      ),
    );
    return this;
  }
}

class _$CoreModule extends _i35.CoreModule {}

class _$FirebaseModule extends _i859.FirebaseModule {}
