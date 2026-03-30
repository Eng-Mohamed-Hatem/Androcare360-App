import 'package:flutter/material.dart';
import 'package:elajtech/core/domain/usecases/register_doctor_usecase.dart';
import 'package:elajtech/core/presentation/providers/doctor_registration_provider.dart';
import 'package:injectable/injectable.dart';

@module
abstract class CoreModule {
  @lazySingleton
  GlobalKey<NavigatorState> get navigatorKey => GlobalKey<NavigatorState>();

  @lazySingleton
  DoctorRegistrationNotifier doctorRegistrationNotifier(
    RegisterDoctorUseCase registerDoctorUseCase,
  ) => DoctorRegistrationNotifier(registerDoctorUseCase);
}
