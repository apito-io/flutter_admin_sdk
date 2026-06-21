// AUTO-GENERATED — DO NOT EDIT
import 'package:flutter_admin_sdk/flutter_admin_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/payment.dart';
import '../models/payment.where.dart';
import '../models/payment.payloads.dart';
import '../apito_client_provider.dart';

part 'payment_providers.g.dart';

@riverpod
class PaymentList extends _$PaymentList {
  @override
  Future<ApitoListResponseTyped<Payment>> build({
    PaymentWhere? where,
    int page = 1,
    int limit = 50,
    String? sortBy,
    bool descending = false,
  }) async {
    final client = ref.read(apitoClientProvider);
    final response = await client
        .from('payment')
        .select(Payment.allFields)
        .where(where?.toJson() ?? {})
        .page(page).limit(limit)
        .sort(sortBy ?? 'created_at', descending: descending)
        .list();
    return ApitoListResponseTyped(
      data: response.data
          .map((r) => Payment.fromJson({...r.data, 'id': r.id}))
          .toList(),
      total: response.total,
    );
  }
}

@riverpod
class PaymentDetail extends _$PaymentDetail {
  @override
  Future<Payment> build(String id) async {
    final client = ref.read(apitoClientProvider);
    final record = await client.from('payment').select(Payment.allFields).get(id);
    return Payment.fromJson({...record.data, 'id': record.id});
  }
}

@riverpod
class CreatePayment extends _$CreatePayment {
  @override
  FutureOr<void> build() {}

  Future<Payment> execute({
    required PaymentCreatePayload payload,
    PaymentConnect? connect,
  }) async {
    final client = ref.read(apitoClientProvider);
    final result = await client.from('payment').insert(payload: payload.toJson())
        .connectWith(connect?.toJson() ?? {})
        .execute();
    ref.invalidate(paymentListProvider);
    return Payment.fromJson({...result.data, 'id': result.id});
  }
}

@riverpod
class UpdatePayment extends _$UpdatePayment {
  @override
  FutureOr<void> build() {}

  Future<Payment> execute({
    required String id,
    required PaymentUpdatePayload payload,
    PaymentConnect? connect,
    PaymentConnect? disconnect,
    bool deltaUpdate = false,
  }) async {
    final client = ref.read(apitoClientProvider);
    final builder = client.from('payment').update(id: id, payload: payload.toJson(), deltaUpdate: deltaUpdate);
    final mutation = connect != null || disconnect != null
        ? builder.connectWith(connect?.toJson() ?? {}).disconnectFrom(disconnect?.toJson() ?? {})
        : builder;
    final result = await mutation.execute();
    ref.invalidate(paymentListProvider);
    ref.invalidate(paymentDetailProvider(id));
    return Payment.fromJson({...result.data, 'id': result.id});
  }
}

@riverpod
class DeletePayment extends _$DeletePayment {
  @override
  FutureOr<void> build() {}

  Future<void> execute(String id) async {
    final client = ref.read(apitoClientProvider);
    await client.from('payment').delete(id: id).execute();
    ref.invalidate(paymentListProvider);
    ref.invalidate(paymentDetailProvider(id));
  }
}
