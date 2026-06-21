import 'admin_models.dart';
import 'client.dart';
import 'rest.dart';
import 'storage_paths.dart';
import 'types.dart';

/// File storage operations via REST (aligned with js/go admin SDKs).
extension ApitoStorage on ApitoClient {
  ApitoRestClient get _rest => ApitoRestClient(
        config: config,
        httpClient: httpClient,
        buildHeaders: buildHeaders,
      );

  /// Upload a project file via POST /files/upload.
  Future<ApitoFile> uploadFile(UploadFileParams params) async {
    if (params.content.isEmpty) {
      throw ApitoError('file content is required');
    }
    final fileName = params.fileName.trim().isEmpty ? 'upload' : params.fileName.trim();
    final body = await _rest.postMultipart(
      filesUploadPath,
      fileBytes: params.content,
      fileName: fileName,
      fileType: params.fileType,
    );
    final fileJson = body['file'] as Map<String, dynamic>?;
    if (fileJson == null || (fileJson['id'] as String?)?.isEmpty != false) {
      throw ApitoError('Invalid response format for uploadFile');
    }
    return ApitoFile.fromJson(fileJson);
  }

  /// List project files via GET /files/list.
  Future<FilesListResponse> listFiles({
    String? fileType,
    int? limit,
    int? offset,
  }) async {
    final query = <String, String>{};
    if (fileType != null && fileType.trim().isNotEmpty) {
      query['file_type'] = fileType.trim();
    }
    if (limit != null) query['limit'] = '$limit';
    if (offset != null) query['offset'] = '$offset';

    final body = await _rest.get(filesListPath, query: query);
    final files = (body['files'] as List<dynamic>? ?? [])
        .map((f) => ApitoFile.fromJson(f as Map<String, dynamic>))
        .toList();
    return FilesListResponse(
      files: files,
      total: (body['total'] as num?)?.toInt() ?? files.length,
    );
  }

  /// Delete project files via POST /files/delete.
  Future<DeleteFilesResponse> deleteFiles(List<String> ids) async {
    if (ids.isEmpty) throw ApitoError('ids are required');
    final body = await _rest.postJson(
      filesDeletePath,
      body: {'ids': ids},
      allowFailure: true,
    );
    final result = DeleteFilesResponse(
      success: body['success'] == true,
      deletedIds: (body['deleted_ids'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      storageFailed: (body['storage_failed'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      message: body['message'] as String?,
    );
    if (!result.success && result.message != null && result.message!.isNotEmpty) {
      throw ApitoError(result.message!);
    }
    return result;
  }
}
