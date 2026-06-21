import 'admin_models.dart';
import 'client.dart';
import 'types.dart';

/// Auth and admin user operations (system GraphQL, aligned with js/go admin SDKs).
extension ApitoAuth on ApitoClient {
  /// Generate a tenant-scoped API key.
  Future<String> generateTenantToken(
    String tenantId, {
    String? duration,
    String? role,
  }) async {
    var dur = (duration ?? '').trim();
    if (dur.isEmpty) {
      final now = DateTime.now().toUtc();
      dur =
          '${now.year + 1}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    }
    const query = r'''
      mutation GenerateTenantToken($tenantId: String!, $duration: String!, $role: String) {
        generateTenantToken(tenant_id: $tenantId, duration: $duration, role: $role) {
          token
        }
      }
    ''';
    final data = await execute(query, variables: {
      'tenantId': tenantId,
      'duration': dur,
      'role': (role != null && role.trim().isNotEmpty) ? role.trim() : null,
    });
    final token = (data['generateTenantToken'] as Map?)?['token'] as String?;
    if (token == null || token.isEmpty) {
      throw ApitoError('Invalid response format for tenant token');
    }
    return token;
  }

  /// Project user login (password or Google OAuth). Google paths may auto-link
  /// a verified email to an existing user; handle engine errors for unverified email,
  /// conflicting google_sub, or multiple email matches.
  Future<LoginUserResponse> loginUser(LoginUserParams params) async {
    final authMethod =
        (params.authMethod.trim().isEmpty ? 'general' : params.authMethod)
            .toLowerCase();
    final variables = <String, dynamic>{'project_id': params.projectId};
    final tenantId = (params.tenantId ?? '').trim();
    if (tenantId.isNotEmpty) {
      variables['tenant_id'] = tenantId;
    }

    if (authMethod == 'google') {
      variables['auth_method'] = 'google';
      final code = (params.code ?? '').trim();
      final state = (params.state ?? '').trim();
      if (code.isEmpty || state.isEmpty) {
        throw ApitoError('code and state are required for Google login');
      }
      variables['code'] = code;
      variables['state'] = state;
    } else if (authMethod == 'google_id_token') {
      variables['auth_method'] = 'google_id_token';
      final idToken = (params.idToken ?? '').trim();
      if (idToken.isEmpty) {
        throw ApitoError('id_token is required for google_id_token login');
      }
      variables['id_token'] = idToken;
    } else {
      final password = (params.password ?? '').trim();
      if (password.isEmpty) throw ApitoError('password is required');
      variables['password'] = password;
      final email = (params.email ?? '').trim();
      final phone = (params.phone ?? '').trim();
      if (email.isEmpty && phone.isEmpty) {
        throw ApitoError('email or phone is required');
      }
      if (email.isNotEmpty) variables['email'] = email;
      if (phone.isNotEmpty) variables['phone'] = phone;
    }

    const query = r'''
      query LoginUser($project_id: String!, $tenant_id: String, $password: String, $auth_method: String, $email: String, $phone: String, $code: String, $state: String, $id_token: String) {
        loginUser(project_id: $project_id, tenant_id: $tenant_id, password: $password, auth_method: $auth_method, email: $email, phone: $phone, code: $code, state: $state, id_token: $id_token) {
          token
          user {
            id email phone role provider tenant_id status created_at updated_at
          }
        }
      }
    ''';
    final data = await execute(query, variables: variables);
    final raw = data['loginUser'] as Map<String, dynamic>?;
    final token = raw?['token'] as String?;
    if (token == null || token.isEmpty) {
      throw ApitoError('Invalid response format for loginUser');
    }
    return LoginUserResponse(
      token: token,
      user: raw?['user'] != null
          ? ApitoUser.fromJson(raw!['user'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Signed OAuth state for Google login.
  Future<GoogleOAuthStateResponse> googleOAuthState(String projectId) async {
    const query = r'''
      query GoogleOAuthState($project_id: String!) {
        googleOAuthState(project_id: $project_id) { state }
      }
    ''';
    final data = await execute(query, variables: {'project_id': projectId});
    final state =
        ((data['googleOAuthState'] as Map?)?['state'] as String?)?.trim() ?? '';
    if (state.isEmpty) {
      throw ApitoError('Invalid response format for googleOAuthState');
    }
    return GoogleOAuthStateResponse(state: state);
  }

  /// Search project end-users.
  Future<UsersResponse> searchUsers(
    String projectId, {
    int? limit,
    int? offset,
    String? tenantId,
  }) async {
    const query = r'''
      query SearchUsers($project_id: String!, $limit: Int, $offset: Int, $tenant_id: String) {
        searchUsers(project_id: $project_id, limit: $limit, offset: $offset, tenant_id: $tenant_id) {
          count
          users {
            id email phone role provider tenant_id status created_at updated_at
          }
        }
      }
    ''';
    final variables = <String, dynamic>{'project_id': projectId};
    if (limit != null) variables['limit'] = limit;
    if (offset != null) variables['offset'] = offset;
    final tid = (tenantId ?? '').trim();
    if (tid.isNotEmpty) variables['tenant_id'] = tid;
    final data = await execute(query, variables: variables);
    final raw = data['searchUsers'] as Map<String, dynamic>?;
    if (raw == null) throw ApitoError('Invalid response format for searchUsers');
    final users = (raw['users'] as List<dynamic>? ?? [])
        .map((u) => ApitoUser.fromJson(u as Map<String, dynamic>))
        .toList();
    return UsersResponse(
      users: users,
      count: (raw['count'] as num?)?.toInt() ?? users.length,
    );
  }

  /// Resolve SaaS catalog tenant by exact domain match.
  Future<TenantByDomainResponse> searchTenantsByDomain(
    String projectId,
    String domain,
  ) async {
    const query = r'''
      query SearchTenantsByDomain($project_id: String!, $domain: String!) {
        searchTenantsByDomain(project_id: $project_id, domain: $domain) {
          tenant { id name status domain data }
        }
      }
    ''';
    final data = await execute(query, variables: {
      'project_id': projectId,
      'domain': domain,
    });
    final raw = data['searchTenantsByDomain'] as Map<String, dynamic>?;
    if (raw == null) {
      throw ApitoError('Invalid response format for searchTenantsByDomain');
    }
    final tenantJson = raw['tenant'] as Map<String, dynamic>?;
    return TenantByDomainResponse(
      tenant: tenantJson != null
          ? TenantCatalogSearchRow.fromJson(tenantJson)
          : null,
    );
  }

  /// List SaaS catalog tenants (system GraphQL only).
  Future<GetTenantsResponse> getTenants() async {
    const query = r'''
      query GetTenants {
        getTenants {
          tenants { id name domain icon data }
        }
      }
    ''';
    final data = await execute(query);
    final raw = data['getTenants'] as Map<String, dynamic>?;
    if (raw == null) {
      throw ApitoError('Invalid response format for getTenants');
    }
    final tenants = (raw['tenants'] as List<dynamic>? ?? [])
        .map((e) => TenantCatalogListItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return GetTenantsResponse(tenants: tenants);
  }

  /// Provision a SaaS catalog tenant (system GraphQL only).
  Future<TenantCatalogSearchRow> createTenant(CreateTenantParams params) async {
    final name = params.name.trim();
    if (name.isEmpty) throw ApitoError('name is required');
    const query = r'''
      mutation CreateTenant($name: String!, $data: String, $domain: String) {
        createTenant(name: $name, data: $data, domain: $domain) {
          id name status domain data
        }
      }
    ''';
    final variables = <String, dynamic>{'name': name};
    final dataJson = (params.data ?? '').trim();
    if (dataJson.isNotEmpty) variables['data'] = dataJson;
    final domain = (params.domain ?? '').trim();
    if (domain.isNotEmpty) variables['domain'] = domain;
    final data = await execute(query, variables: variables);
    final row = data['createTenant'] as Map<String, dynamic>?;
    if (row == null || (row['id'] as String?)?.isEmpty != false) {
      throw ApitoError('Invalid response format for createTenant');
    }
    return TenantCatalogSearchRow.fromJson(row);
  }

  /// Update catalog tenant name/data/domain.
  Future<TenantCatalogSearchRow> updateTenant(
    String tenantId,
    UpdateTenantParams params,
  ) async {
    final tid = tenantId.trim();
    if (tid.isEmpty) throw ApitoError('tenantId is required');
    if (params.name == null && params.data == null && params.domain == null) {
      throw ApitoError('at least one field must be provided');
    }
    const query = r'''
      mutation UpdateTenant($tenant_id: String!, $name: String, $data: String, $domain: String) {
        updateTenant(tenant_id: $tenant_id, name: $name, data: $data, domain: $domain) {
          id name status domain data
        }
      }
    ''';
    final variables = <String, dynamic>{'tenant_id': tid};
    if (params.name != null) variables['name'] = params.name;
    if (params.data != null) variables['data'] = params.data;
    if (params.domain != null) variables['domain'] = params.domain;
    final data = await execute(query, variables: variables);
    final row = data['updateTenant'] as Map<String, dynamic>?;
    if (row == null || (row['id'] as String?)?.isEmpty != false) {
      throw ApitoError('Invalid response format for updateTenant');
    }
    return TenantCatalogSearchRow.fromJson(row);
  }

  /// Hard-delete a catalog tenant row.
  Future<bool> deleteTenant(String tenantId) async {
    final tid = tenantId.trim();
    if (tid.isEmpty) throw ApitoError('tenantId is required');
    const query = r'''
      mutation DeleteTenant($tenant_id: String!) {
        deleteTenant(tenant_id: $tenant_id)
      }
    ''';
    final data = await execute(query, variables: {'tenant_id': tid});
    final ok = data['deleteTenant'];
    if (ok is! bool) {
      throw ApitoError('Invalid response format for deleteTenant');
    }
    return ok;
  }

  /// Create a project user (local password). Engine rejects duplicate email/phone project-wide.
  Future<ApitoUser> createUser(
    String projectId,
    CreateUserParams params,
  ) async {
    final password = params.password.trim();
    if (password.isEmpty) throw ApitoError('password is required');
    const query = r'''
      mutation CreateUser($project_id: String!, $password: String!, $role: String, $email: String, $phone: String, $tenant_id: String) {
        createUser(project_id: $project_id, password: $password, role: $role, email: $email, phone: $phone, tenant_id: $tenant_id) {
          id email phone role provider tenant_id status created_at updated_at
        }
      }
    ''';
    final variables = <String, dynamic>{
      'project_id': projectId,
      'password': password,
    };
    final role = (params.role ?? '').trim();
    if (role.isNotEmpty) variables['role'] = role;
    final email = (params.email ?? '').trim();
    if (email.isNotEmpty) variables['email'] = email;
    final phone = (params.phone ?? '').trim();
    if (phone.isNotEmpty) variables['phone'] = phone;
    final tenantId = (params.tenantId ?? '').trim();
    if (tenantId.isNotEmpty) variables['tenant_id'] = tenantId;

    final data = await execute(query, variables: variables);
    final u = data['createUser'] as Map<String, dynamic>?;
    if (u == null || (u['id'] as String?)?.isEmpty != false) {
      throw ApitoError('Invalid response format for createUser');
    }
    return ApitoUser.fromJson(u);
  }

  /// Update a project user. Engine rejects duplicate email/phone project-wide.
  Future<ApitoUser> updateUser(
    String userId,
    UpdateUserParams params,
  ) async {
    final uid = userId.trim();
    if (uid.isEmpty) throw ApitoError('userId is required');
    if (params.email == null &&
        params.phone == null &&
        params.role == null &&
        (params.tenantId ?? '').trim().isEmpty) {
      throw ApitoError('at least one field must be provided');
    }
    const query = r'''
      mutation UpdateUser($user_id: String!, $email: String, $phone: String, $role: String, $tenant_id: String) {
        updateUser(user_id: $user_id, email: $email, phone: $phone, role: $role, tenant_id: $tenant_id) {
          id email phone role provider tenant_id status created_at updated_at
        }
      }
    ''';
    final variables = <String, dynamic>{'user_id': uid};
    if (params.email != null) variables['email'] = params.email;
    if (params.phone != null) variables['phone'] = params.phone;
    if (params.role != null) variables['role'] = params.role;
    final tenantId = (params.tenantId ?? '').trim();
    if (tenantId.isNotEmpty) variables['tenant_id'] = tenantId;

    final data = await execute(query, variables: variables);
    final u = data['updateUser'] as Map<String, dynamic>?;
    if (u == null || (u['id'] as String?)?.isEmpty != false) {
      throw ApitoError('Invalid response format for updateUser');
    }
    return ApitoUser.fromJson(u);
  }

  /// Set a new password for a project user.
  Future<bool> resetUserPassword(String userId, String password) async {
    final uid = userId.trim();
    if (uid.isEmpty) throw ApitoError('userId is required');
    if (password.trim().isEmpty) throw ApitoError('password is required');
    const query = r'''
      mutation ResetUserPassword($user_id: String!, $password: String!) {
        resetUserPassword(user_id: $user_id, password: $password)
      }
    ''';
    final data = await execute(query, variables: {
      'user_id': uid,
      'password': password,
    });
    final ok = data['resetUserPassword'];
    if (ok is! bool) {
      throw ApitoError('Invalid response format for resetUserPassword');
    }
    return ok;
  }

  /// Delete a project user by id.
  Future<bool> deleteUser(String userId) async {
    final uid = userId.trim();
    if (uid.isEmpty) throw ApitoError('userId is required');
    const query = r'''
      mutation DeleteUser($user_id: String!) {
        deleteUser(user_id: $user_id)
      }
    ''';
    final data = await execute(query, variables: {'user_id': uid});
    final ok = data['deleteUser'];
    if (ok is! bool) {
      throw ApitoError('Invalid response format for deleteUser');
    }
    return ok;
  }
}
