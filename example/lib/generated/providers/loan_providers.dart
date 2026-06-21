// AUTO-GENERATED — DO NOT EDIT
import 'package:flutter_admin_sdk/flutter_admin_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/loan.dart';
import '../models/loan.where.dart';
import '../models/loan.payloads.dart';
import '../apito_client_provider.dart';

part 'loan_providers.g.dart';

@riverpod
class LoanList extends _$LoanList {
  @override
  Future<ApitoListResponseTyped<Loan>> build({
    LoanWhere? where,
    int page = 1,
    int limit = 50,
    String? sortBy,
    bool descending = false,
  }) async {
    final client = ref.read(apitoClientProvider);
    final response = await client
        .from('loan')
        .select(Loan.allFields)
        .where(where?.toJson() ?? {})
        .page(page).limit(limit)
        .sort(sortBy ?? 'created_at', descending: descending)
        .list();
    return ApitoListResponseTyped(
      data: response.data
          .map((r) => Loan.fromJson({...r.data, 'id': r.id}))
          .toList(),
      total: response.total,
    );
  }
}

@riverpod
class LoanDetail extends _$LoanDetail {
  @override
  Future<Loan> build(String id) async {
    final client = ref.read(apitoClientProvider);
    final record = await client.from('loan').select(Loan.allFields).get(id);
    return Loan.fromJson({...record.data, 'id': record.id});
  }
}

@riverpod
class CreateLoan extends _$CreateLoan {
  @override
  FutureOr<void> build() {}

  Future<Loan> execute({
    required LoanCreatePayload payload,
    LoanConnect? connect,
  }) async {
    final client = ref.read(apitoClientProvider);
    final result = await client.from('loan').insert(payload: payload.toJson())
        .connectWith(connect?.toJson() ?? {})
        .execute();
    ref.invalidate(loanListProvider);
    return Loan.fromJson({...result.data, 'id': result.id});
  }
}

@riverpod
class UpdateLoan extends _$UpdateLoan {
  @override
  FutureOr<void> build() {}

  Future<Loan> execute({
    required String id,
    required LoanUpdatePayload payload,
    LoanConnect? connect,
    LoanConnect? disconnect,
    bool deltaUpdate = false,
  }) async {
    final client = ref.read(apitoClientProvider);
    final builder = client.from('loan').update(id: id, payload: payload.toJson(), deltaUpdate: deltaUpdate);
    final mutation = connect != null || disconnect != null
        ? builder.connectWith(connect?.toJson() ?? {}).disconnectFrom(disconnect?.toJson() ?? {})
        : builder;
    final result = await mutation.execute();
    ref.invalidate(loanListProvider);
    ref.invalidate(loanDetailProvider(id));
    return Loan.fromJson({...result.data, 'id': result.id});
  }
}

@riverpod
class DeleteLoan extends _$DeleteLoan {
  @override
  FutureOr<void> build() {}

  Future<void> execute(String id) async {
    final client = ref.read(apitoClientProvider);
    await client.from('loan').delete(id: id).execute();
    ref.invalidate(loanListProvider);
    ref.invalidate(loanDetailProvider(id));
  }
}
