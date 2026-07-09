/// Dhaka calendar-day range for report API `date between` filters.
class ReportDateRange {
  const ReportDateRange({
    required this.start,
    required this.end,
    required this.apiStart,
    required this.apiEnd,
  });

  final DateTime start;
  final DateTime end;
  final String apiStart;
  final String apiEnd;
}

ReportDateRange defaultReportDateRange([DateTime? day]) {
  final local = day ?? DateTime.now();
  final dhaka = local.toUtc().add(const Duration(hours: 6));
  final startLocal = DateTime(dhaka.year, dhaka.month, dhaka.day);
  final endLocal = startLocal
      .add(const Duration(days: 1))
      .subtract(const Duration(milliseconds: 1));
  final startUtc = startLocal.subtract(const Duration(hours: 6));
  final endUtc = endLocal.subtract(const Duration(hours: 6));
  return ReportDateRange(
    start: startLocal,
    end: startLocal,
    apiStart: startUtc.toIso8601String(),
    apiEnd: endUtc.toIso8601String(),
  );
}

ReportDateRange reportDateRangeForDays(int daysBack, [DateTime? anchor]) {
  final end = defaultReportDateRange(anchor);
  final startDay = end.start.subtract(Duration(days: daysBack - 1));
  final startUtc =
      DateTime(startDay.year, startDay.month, startDay.day)
          .subtract(const Duration(hours: 6));
  return ReportDateRange(
    start: startDay,
    end: end.start,
    apiStart: startUtc.toIso8601String(),
    apiEnd: end.apiEnd,
  );
}

Map<String, dynamic> reportDateBetweenWhere(ReportDateRange range) => {
      'date': {
        'between': [range.apiStart, range.apiEnd],
      },
    };
