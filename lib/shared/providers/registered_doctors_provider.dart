import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:elajtech/shared/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to get list of doctors from Firestore (real-time stream)
final AutoDisposeProvider<AsyncValue<List<UserModel>>> doctorsListProvider =
    Provider.autoDispose<AsyncValue<List<UserModel>>>(
      (
        ref,
      ) => ref.watch(registeredDoctorsProvider),
    );

/// Provider to get doctors list synchronously (one-time fetch)
final AutoDisposeFutureProvider<List<UserModel>> doctorsListFutureProvider =
    FutureProvider.autoDispose<List<UserModel>>(
      (
        ref,
      ) async => await ref.watch(registeredDoctorsListProvider.future),
    );
