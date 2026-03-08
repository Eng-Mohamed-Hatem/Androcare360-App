import 'dart:async';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BiometricSwitch extends ConsumerStatefulWidget {
  const BiometricSwitch({super.key});

  @override
  ConsumerState<BiometricSwitch> createState() => _BiometricSwitchState();
}

class _BiometricSwitchState extends ConsumerState<BiometricSwitch> {
  bool _isLoading = true;
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadState());
  }

  Future<void> _loadState() async {
    final enabled = await ref.read(authProvider.notifier).isBiometricEnabled();
    if (mounted) {
      setState(() {
        _isEnabled = enabled;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggle(bool value) async {
    // Optimistic update
    setState(() {
      _isEnabled = value;
    });

    // Save in background
    await ref.read(authProvider.notifier).setBiometricEnabled(enabled: value);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        width: 40,
        height: 24,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Switch(
      value: _isEnabled,
      onChanged: (val) {
        unawaited(_toggle(val));
      },
    );
  }
}
