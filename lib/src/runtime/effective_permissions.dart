import 'client.dart';
import 'types.dart';

/// Per-model CRUD scopes from `myEffectivePermissions.api_permissions`.
class EffectiveModelPermission {
  const EffectiveModelPermission({
    this.read,
    this.create,
    this.update,
    this.delete,
    this.grace = false,
  });

  final String? read;
  final String? create;
  final String? update;
  final String? delete;
  final bool grace;

  factory EffectiveModelPermission.fromJson(Map<String, dynamic> json) {
    return EffectiveModelPermission(
      read: json['read']?.toString(),
      create: json['create']?.toString(),
      update: json['update']?.toString(),
      delete: json['delete']?.toString(),
      grace: json['grace'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        if (read != null) 'read': read,
        if (create != null) 'create': create,
        if (update != null) 'update': update,
        if (delete != null) 'delete': delete,
        if (grace) 'grace': true,
      };
}

/// Engine public query `myEffectivePermissions` payload.
class EffectivePermissionsSnapshot {
  const EffectivePermissionsSnapshot({
    this.planSlug,
    this.roleId,
    this.planClamped,
    this.apiPermissions,
    this.logicExecutions,
    this.quotas,
    this.usage,
    this.graceModels,
    this.isAdmin,
  });

  final String? planSlug;
  final String? roleId;
  final bool? planClamped;
  final Map<String, EffectiveModelPermission>? apiPermissions;
  final List<String>? logicExecutions;
  final Map<String, num>? quotas;
  final Map<String, num>? usage;
  final List<String>? graceModels;
  final bool? isAdmin;

  factory EffectivePermissionsSnapshot.fromJson(Map<String, dynamic> json) {
    final rawPerms = json['api_permissions'];
    Map<String, EffectiveModelPermission>? perms;
    if (rawPerms is Map) {
      perms = {};
      for (final e in rawPerms.entries) {
        final v = e.value;
        if (v is Map) {
          perms[e.key.toString()] =
              EffectiveModelPermission.fromJson(Map<String, dynamic>.from(v));
        }
      }
    }
    Map<String, num>? quotas;
    final rawQ = json['quotas'];
    if (rawQ is Map) {
      quotas = {
        for (final e in rawQ.entries)
          if (e.value is num) e.key.toString(): e.value as num,
      };
    }
    Map<String, num>? usage;
    final rawU = json['usage'];
    if (rawU is Map) {
      usage = {
        for (final e in rawU.entries)
          if (e.value is num) e.key.toString(): e.value as num,
      };
    }
    List<String>? grace;
    final rawG = json['grace_models'];
    if (rawG is List) {
      grace = rawG
          .whereType<Object?>()
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }
    List<String>? logic;
    final rawL = json['logic_executions'];
    if (rawL is List) {
      logic = rawL
          .whereType<Object?>()
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return EffectivePermissionsSnapshot(
      planSlug: json['plan_slug']?.toString(),
      roleId: json['role_id']?.toString(),
      planClamped: json['plan_clamped'] as bool?,
      apiPermissions: perms,
      logicExecutions: logic,
      quotas: quotas,
      usage: usage,
      graceModels: grace,
      isAdmin: json['is_admin'] as bool?,
    );
  }

  /// Loose map form for apps that already store JSON-ish snapshots.
  Map<String, dynamic> toJson() => {
        if (planSlug != null) 'plan_slug': planSlug,
        if (roleId != null) 'role_id': roleId,
        if (planClamped != null) 'plan_clamped': planClamped,
        if (apiPermissions != null)
          'api_permissions': {
            for (final e in apiPermissions!.entries) e.key: e.value.toJson(),
          },
        if (logicExecutions != null) 'logic_executions': logicExecutions,
        if (quotas != null) 'quotas': quotas,
        if (usage != null) 'usage': usage,
        if (graceModels != null) 'grace_models': graceModels,
        if (isAdmin != null) 'is_admin': isAdmin,
      };
}

/// Helpers over [EffectivePermissionsSnapshot].
class EffectivePermissions {
  EffectivePermissions._();

  static bool scopeAllows(String? scope) {
    final s = (scope ?? 'none').trim().toLowerCase();
    return s.isNotEmpty && s != 'none';
  }

  static String scopeForAction(String action) {
    switch (action.trim().toLowerCase()) {
      case 'list':
      case 'show':
      case 'read':
        return 'read';
      case 'create':
        return 'create';
      case 'edit':
      case 'update':
        return 'update';
      case 'delete':
        return 'delete';
      default:
        return action.trim().toLowerCase();
    }
  }

  /// Check snapshot scopes for a resource + Refine-style action.
  static bool can(
    EffectivePermissionsSnapshot? snap,
    String resource,
    String action,
  ) {
    if (snap == null) return false;
    if (snap.isAdmin == true && snap.planClamped != true) return true;
    final perms = snap.apiPermissions;
    if (perms == null) return false;
    final model =
        perms[resource] ?? perms[resource.replaceAll('-', '_')];
    if (model == null) return false;
    final key = scopeForAction(action);
    switch (key) {
      case 'read':
        return scopeAllows(model.read);
      case 'create':
        return scopeAllows(model.create);
      case 'update':
        return scopeAllows(model.update);
      case 'delete':
        return scopeAllows(model.delete);
      default:
        return false;
    }
  }

  /// Also accepts a raw JSON map (Protiva legacy shape).
  static bool canFromMap(
    Map<String, dynamic>? snapshot,
    String resource,
    String action,
  ) {
    if (snapshot == null) return false;
    return can(EffectivePermissionsSnapshot.fromJson(snapshot), resource, action);
  }

  static List<String> graceModels(EffectivePermissionsSnapshot? snap) {
    if (snap == null) return const [];
    final fromList = snap.graceModels
            ?.where((m) => m.trim().isNotEmpty)
            .toList() ??
        const [];
    if (fromList.isNotEmpty) return fromList;
    final fromPerms = <String>[];
    for (final e in (snap.apiPermissions ?? {}).entries) {
      if (e.value.grace) fromPerms.add(e.key);
    }
    return fromPerms;
  }
}

extension ApitoEffectivePermissions on ApitoClient {
  /// Public GraphQL `myEffectivePermissions` for the authenticated app-user token.
  Future<EffectivePermissionsSnapshot> myEffectivePermissions() async {
    const query = r'''
      query MyEffectivePermissions {
        myEffectivePermissions {
          plan_slug
          role_id
          plan_clamped
          api_permissions
          logic_executions
          quotas
          usage
          grace_models
          is_admin
        }
      }
    ''';
    final data = await execute(query);
    final raw = data['myEffectivePermissions'];
    if (raw is! Map) {
      throw ApitoError('Invalid response format for myEffectivePermissions');
    }
    return EffectivePermissionsSnapshot.fromJson(
      Map<String, dynamic>.from(raw),
    );
  }
}
