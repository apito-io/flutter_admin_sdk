/// Plan tier parse/rank helpers (engine `pro_tenants.plan_tier`).

/// Known plan tier wire values.
enum PlanTier {
  free,
  paid,
  paidPlus,
  ultra;

  int get rank => switch (this) {
        PlanTier.free => 0,
        PlanTier.paid => 1,
        PlanTier.paidPlus => 2,
        PlanTier.ultra => 3,
      };

  bool atLeast(PlanTier min) => rank >= min.rank;

  /// Wire-format value (`paid_plus` for [paidPlus]).
  String get wireValue => switch (this) {
        PlanTier.paidPlus => 'paid_plus',
        _ => name,
      };

  /// Normalize unknown/empty plan strings to a known tier (default free).
  static PlanTier parse(String? raw) {
    final key = (raw ?? '').trim().toLowerCase();
    switch (key) {
      case 'paid':
        return PlanTier.paid;
      case 'paid_plus':
      case 'paid+':
      case 'paidplus':
        return PlanTier.paidPlus;
      case 'ultra':
        return PlanTier.ultra;
      case 'free':
      case '':
      default:
        return PlanTier.free;
    }
  }
}

/// True when [tier] meets or exceeds [min].
bool planAtLeast(String? tier, String? min) =>
    PlanTier.parse(tier).atLeast(PlanTier.parse(min));
