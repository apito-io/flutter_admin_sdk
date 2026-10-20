import 'client.dart';
import 'types.dart';

/// One price row from project plan `prices` JSON.
class ProjectPlanPrice {
  const ProjectPlanPrice({
    required this.currency,
    required this.amount,
    this.isDefault = false,
  });

  final String currency;
  final double amount;
  final bool isDefault;

  factory ProjectPlanPrice.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'];
    final amount = rawAmount is num
        ? rawAmount.toDouble()
        : double.tryParse('$rawAmount') ?? 0;
    return ProjectPlanPrice(
      currency: (json['currency'] as String?)?.trim() ?? '',
      amount: amount,
      isDefault: json['default'] == true,
    );
  }
}

/// Provider product binding (e.g. Google Play SKU).
class ProjectPlanProviderProduct {
  const ProjectPlanProviderProduct({
    required this.provider,
    required this.productId,
    this.variantId,
  });

  final String provider;
  final String productId;
  final String? variantId;

  factory ProjectPlanProviderProduct.fromJson(Map<String, dynamic> json) {
    return ProjectPlanProviderProduct(
      provider: (json['provider'] as String?)?.trim() ?? '',
      productId: (json['product_id'] as String?)?.trim() ?? '',
      variantId: (json['variant_id'] as String?)?.trim(),
    );
  }
}

/// Project SaaS plan from system GraphQL `getProjectPlans`.
class ProjectPlan {
  const ProjectPlan({
    required this.id,
    this.name,
    this.description,
    this.currency,
    this.priceMonthly,
    this.playProductId,
    this.playBasePlanId,
    this.paddlePriceId,
    this.systemGenerated = false,
    this.prices = const [],
    this.providerProducts = const [],
    this.quotas,
    this.apiPermissions,
    this.logicExecutions,
  });

  final String id;
  final String? name;
  final String? description;
  final String? currency;
  final double? priceMonthly;
  final String? playProductId;
  final String? playBasePlanId;
  final String? paddlePriceId;
  final bool systemGenerated;
  final List<ProjectPlanPrice> prices;
  final List<ProjectPlanProviderProduct> providerProducts;
  final Map<String, dynamic>? quotas;
  final Map<String, dynamic>? apiPermissions;
  final List<String>? logicExecutions;

  /// Google Play product IDs from `provider_products` or legacy `play_product_id`.
  List<String> get googlePlayProductIds {
    final fromProvider = providerProducts
        .where((p) {
          final prov = p.provider.toLowerCase();
          return (prov == 'google_play' ||
                  prov == 'play' ||
                  prov == 'google') &&
              p.productId.isNotEmpty;
        })
        .map((p) => p.productId)
        .toList();
    if (fromProvider.isNotEmpty) return fromProvider;
    final legacy = playProductId?.trim();
    if (legacy != null && legacy.isNotEmpty) return [legacy];
    return const [];
  }

  factory ProjectPlan.fromJson(Map<String, dynamic> json) {
    final pricesRaw = json['prices'];
    final prices = <ProjectPlanPrice>[];
    if (pricesRaw is List) {
      for (final row in pricesRaw) {
        if (row is Map<String, dynamic>) {
          prices.add(ProjectPlanPrice.fromJson(row));
        } else if (row is Map) {
          prices.add(ProjectPlanPrice.fromJson(Map<String, dynamic>.from(row)));
        }
      }
    }

    final ppRaw = json['provider_products'];
    final providerProducts = <ProjectPlanProviderProduct>[];
    if (ppRaw is List) {
      for (final row in ppRaw) {
        if (row is Map<String, dynamic>) {
          providerProducts.add(ProjectPlanProviderProduct.fromJson(row));
        } else if (row is Map) {
          providerProducts.add(
            ProjectPlanProviderProduct.fromJson(Map<String, dynamic>.from(row)),
          );
        }
      }
    }

    final rawMonthly = json['price_monthly'];
    final priceMonthly = rawMonthly is num
        ? rawMonthly.toDouble()
        : double.tryParse('$rawMonthly');

    Map<String, dynamic>? asMap(dynamic v) {
      if (v is Map<String, dynamic>) return v;
      if (v is Map) return Map<String, dynamic>.from(v);
      return null;
    }

    List<String>? logics;
    final le = json['logic_executions'];
    if (le is List) {
      logics = le.map((e) => '$e').toList();
    }

    return ProjectPlan(
      id: (json['id'] as String?)?.trim() ?? '',
      name: json['name'] as String?,
      description: json['description'] as String?,
      currency: json['currency'] as String?,
      priceMonthly: priceMonthly,
      playProductId: json['play_product_id'] as String?,
      playBasePlanId: json['play_base_plan_id'] as String?,
      paddlePriceId: json['paddle_price_id'] as String?,
      systemGenerated: json['system_generated'] == true,
      prices: prices,
      providerProducts: providerProducts,
      quotas: asMap(json['quotas']),
      apiPermissions: asMap(json['api_permissions']),
      logicExecutions: logics,
    );
  }
}

/// System GraphQL plan catalog (requires plans-read / project admin token).
extension ApitoProjectPlans on ApitoClient {
  Future<List<ProjectPlan>> listProjectPlans() async {
    requireOperatorCredential('getProjectPlans');
    const query = r'''
      query GetProjectPlans {
        getProjectPlans {
          id
          name
          description
          api_permissions
          logic_executions
          quotas
          system_generated
          currency
          price_monthly
          play_product_id
          play_base_plan_id
          paddle_price_id
          prices
          provider_products
        }
      }
    ''';
    final data = await execute(query);
    final raw = data['getProjectPlans'];
    if (raw == null) return const [];
    if (raw is! List) {
      throw ApitoError('Invalid response format for getProjectPlans');
    }
    final out = <ProjectPlan>[];
    for (final row in raw) {
      if (row is Map<String, dynamic>) {
        out.add(ProjectPlan.fromJson(row));
      } else if (row is Map) {
        out.add(ProjectPlan.fromJson(Map<String, dynamic>.from(row)));
      }
    }
    return out;
  }
}
