/// Detect engine plan quota errors (create blocked by max_records.*).
bool isPlanQuotaError(Object? error) {
  final msg = error?.toString().toLowerCase() ?? '';
  return msg.contains('plan quota exceeded') || msg.contains('max_records.');
}
