/// Admin/auth and storage DTOs (aligned with js-admin-sdk / go-admin-sdk).
library;

class ApitoUser {
  const ApitoUser({
    required this.id,
    this.email,
    this.phone,
    this.role,
    this.tenantId,
    this.provider,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? email;
  final String? phone;
  final String? role;
  final String? tenantId;
  final String? provider;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  factory ApitoUser.fromJson(Map<String, dynamic> json) => ApitoUser(
        id: json['id'] as String? ?? '',
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        role: json['role'] as String?,
        tenantId: json['tenant_id'] as String?,
        provider: json['provider'] as String?,
        status: json['status'] as String?,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
      );
}

class LoginUserParams {
  const LoginUserParams({
    required this.projectId,
    this.tenantId,
    this.password,
    this.email,
    this.phone,
    this.authMethod = 'general',
    this.code,
    this.state,
    this.idToken,
  });

  final String projectId;
  /// SaaS per-tenant separate DB: required by engine on `loginUser`.
  /// Google paths: engine may auto-link verified email to an existing user.
  /// On Cloudflare Workers v1, Google paths are unavailable; password login is supported.
  final String? tenantId;
  final String? password;
  final String? email;
  final String? phone;
  final String authMethod;
  final String? code;
  final String? state;
  final String? idToken;
}

class LoginUserResponse {
  const LoginUserResponse({required this.token, this.user});

  final String token;
  final ApitoUser? user;
}

class GoogleOAuthStateResponse {
  const GoogleOAuthStateResponse({required this.state});

  final String state;
}

class CreateUserParams {
  const CreateUserParams({
    required this.password,
    this.role,
    this.email,
    this.phone,
    this.tenantId,
  });

  /// Engine rejects duplicate email/phone project-wide.
  final String password;
  final String? role;
  final String? email;
  final String? phone;
  final String? tenantId;
}

class UpdateUserParams {
  const UpdateUserParams({this.email, this.phone, this.role, this.tenantId});

  final String? email;
  final String? phone;
  final String? role;
  final String? tenantId;
}

class UsersResponse {
  const UsersResponse({required this.users, required this.count});

  final List<ApitoUser> users;
  final int count;
}

class TenantCatalogSearchRow {
  const TenantCatalogSearchRow({
    required this.id,
    this.name,
    this.status,
    this.domain,
    this.data,
  });

  final String id;
  final String? name;
  final String? status;
  final String? domain;
  final String? data;

  factory TenantCatalogSearchRow.fromJson(Map<String, dynamic> json) =>
      TenantCatalogSearchRow(
        id: json['id'] as String? ?? '',
        name: json['name'] as String?,
        status: json['status'] as String?,
        domain: json['domain'] as String?,
        data: json['data'] as String?,
      );
}

class TenantByDomainResponse {
  const TenantByDomainResponse({this.tenant});

  final TenantCatalogSearchRow? tenant;
}

class TenantCatalogListItem {
  const TenantCatalogListItem({
    required this.id,
    this.name,
    this.domain,
    this.icon,
    this.data,
  });

  final String id;
  final String? name;
  final String? domain;
  final String? icon;
  final String? data;

  factory TenantCatalogListItem.fromJson(Map<String, dynamic> json) =>
      TenantCatalogListItem(
        id: json['id'] as String? ?? '',
        name: json['name'] as String?,
        domain: json['domain'] as String?,
        icon: json['icon'] as String?,
        data: json['data'] as String?,
      );
}

class GetTenantsResponse {
  const GetTenantsResponse({required this.tenants});

  final List<TenantCatalogListItem> tenants;
}

class CreateTenantParams {
  const CreateTenantParams({
    required this.name,
    this.data,
    this.domain,
  });

  final String name;
  final String? data;
  final String? domain;
}

class UpdateTenantParams {
  const UpdateTenantParams({this.name, this.data, this.domain});

  final String? name;
  final String? data;
  final String? domain;
}

class ApitoFile {
  const ApitoFile({
    required this.id,
    required this.fileType,
    required this.fileName,
    required this.size,
    required this.url,
    this.fileExtension,
    this.contentType,
    this.createdBy,
    this.createdAt,
  });

  final String id;
  final String fileType;
  final String fileName;
  final String? fileExtension;
  final String? contentType;
  final int size;
  final String url;
  final String? createdBy;
  final String? createdAt;

  factory ApitoFile.fromJson(Map<String, dynamic> json) => ApitoFile(
        id: json['id'] as String? ?? '',
        fileType: json['file_type'] as String? ?? '',
        fileName: json['file_name'] as String? ?? '',
        fileExtension: json['file_extension'] as String?,
        contentType: json['content_type'] as String?,
        size: (json['size'] as num?)?.toInt() ?? 0,
        url: json['url'] as String? ?? '',
        createdBy: json['created_by'] as String?,
        createdAt: json['created_at'] as String?,
      );
}

class FilesListResponse {
  const FilesListResponse({required this.files, required this.total});

  final List<ApitoFile> files;
  final int total;
}

class UploadFileParams {
  const UploadFileParams({
    required this.fileName,
    required this.content,
    this.fileType,
  });

  final String fileName;
  final List<int> content;
  final String? fileType;
}

class DeleteFilesResponse {
  const DeleteFilesResponse({
    required this.success,
    required this.deletedIds,
    this.storageFailed,
    this.message,
  });

  final bool success;
  final List<String> deletedIds;
  final List<String>? storageFailed;
  final String? message;
}
