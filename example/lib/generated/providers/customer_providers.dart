// AUTO-GENERATED — DO NOT EDIT
import 'package:flutter_admin_sdk/flutter_admin_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/customer.dart';
import '../models/customer.where.dart';
import '../models/customer.payloads.dart';
import '../apito_client_provider.dart';

part 'customer_providers.g.dart';

@riverpod
class CustomerList extends _$CustomerList {
  @override
  Future<ApitoListResponseTyped<Customer>> build({
    CustomerWhere? where,
    int page = 1,
    int limit = 50,
    String? sortBy,
    bool descending = false,
  }) async {
    final client = ref.read(apitoClientProvider);
    final response = await client
        .from('customer')
        .select(Customer.allFields)
        .where(where?.toJson() ?? {})
        .page(page).limit(limit)
        .sort(sortBy ?? 'created_at', descending: descending)
        .list();
    return ApitoListResponseTyped(
      data: response.data
          .map((r) => Customer.fromJson({...r.data, 'id': r.id}))
          .toList(),
      total: response.total,
    );
  }
}

@riverpod
class CustomerDetail extends _$CustomerDetail {
  @override
  Future<Customer> build(String id) async {
    final client = ref.read(apitoClientProvider);
    final record = await client.from('customer').select(Customer.allFields).get(id);
    return Customer.fromJson({...record.data, 'id': record.id});
  }
}

@riverpod
class CreateCustomer extends _$CreateCustomer {
  @override
  FutureOr<void> build() {}

  Future<Customer> execute({
    required CustomerCreatePayload payload,
    CustomerConnect? connect,
  }) async {
    final client = ref.read(apitoClientProvider);
    final result = await client.from('customer').insert(payload: payload.toJson())
        .connectWith(connect?.toJson() ?? {})
        .execute();
    ref.invalidate(customerListProvider);
    return Customer.fromJson({...result.data, 'id': result.id});
  }
}

@riverpod
class UpdateCustomer extends _$UpdateCustomer {
  @override
  FutureOr<void> build() {}

  Future<Customer> execute({
    required String id,
    required CustomerUpdatePayload payload,
    CustomerConnect? connect,
    CustomerConnect? disconnect,
    bool deltaUpdate = false,
  }) async {
    final client = ref.read(apitoClientProvider);
    final builder = client.from('customer').update(id: id, payload: payload.toJson(), deltaUpdate: deltaUpdate);
    final mutation = connect != null || disconnect != null
        ? builder.connectWith(connect?.toJson() ?? {}).disconnectFrom(disconnect?.toJson() ?? {})
        : builder;
    final result = await mutation.execute();
    ref.invalidate(customerListProvider);
    ref.invalidate(customerDetailProvider(id));
    return Customer.fromJson({...result.data, 'id': result.id});
  }
}

@riverpod
class DeleteCustomer extends _$DeleteCustomer {
  @override
  FutureOr<void> build() {}

  Future<void> execute(String id) async {
    final client = ref.read(apitoClientProvider);
    await client.from('customer').delete(id: id).execute();
    ref.invalidate(customerListProvider);
    ref.invalidate(customerDetailProvider(id));
  }
}
