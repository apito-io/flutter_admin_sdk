import 'package:flutter_admin_sdk/flutter_admin_sdk.dart';

import 'generated/models/loan.dart';
import 'generated/models/loan.where.dart';

/// Uses codegen output under [lib/generated/] (`dart run build_runner build`).
Future<void> runGeneratedDemo(
  ApitoClient client, {
  required String tenantId,
}) async {
  final response = await client
      .from(Loan.modelName)
      .select(Loan.allFields)
      .where(LoanWhere(tenantId: Eq(tenantId)).toJson())
      .limit(3)
      .list();

  if (response.data.isEmpty) {
    print('\nGenerated Loan model: OK (0 rows in list)');
    return;
  }

  final first = Loan.fromJson({
    ...response.data.first.data,
    'id': response.data.first.id,
  });
  print('\nGenerated Loan.fromJson: ${first.loanId} | ${first.loanStatus}');
}
