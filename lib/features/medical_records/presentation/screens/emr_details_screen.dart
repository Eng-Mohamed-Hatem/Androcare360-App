import 'package:elajtech/shared/models/emr_model.dart';
import 'package:elajtech/shared/widgets/emr/emr_record_view.dart';
import 'package:flutter/material.dart';

class EMRDetailsScreen extends StatelessWidget {
  const EMRDetailsScreen({required this.emr, super.key});
  final EMRModel emr;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('تفاصيل EMR'),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: EmrRecordView(
        record: emr,
        isReadOnly: false,
      ),
    ),
  );
}
