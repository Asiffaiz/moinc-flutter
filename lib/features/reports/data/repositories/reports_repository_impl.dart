import 'package:moinc/features/reports/data/services/reports_service.dart';
import 'package:moinc/features/reports/domain/models/reports_model.dart';
import 'package:moinc/features/reports/domain/repositories/reports_repository.dart';

class ReportsRepositoryImpl extends ReportsRepository {
  final ReportsService _reportsService;

  ReportsRepositoryImpl({required ReportsService reportsService})
    : _reportsService = reportsService;

  @override
  Future<List<ReportsModel>> getReportsData() async {
    // final reportsData = await _reportsService.getReportsData();
    // return reportsData;

    // Dummy data for testing
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return [
      ReportsModel(
        id: 101,
        title: 'Monthly Sales Report - October 2025',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        publishedAt: DateTime.now().subtract(const Duration(days: 4)),
        reportStatus: 1,
        status: 'processed',
        url:
            'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      ),
      ReportsModel(
        id: 102,
        title: 'Customer Feedback Analysis',
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        publishedAt: DateTime.now().subtract(const Duration(days: 10)),
        reportStatus: 1,
        status: 'processed',
        url:
            'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      ),
      ReportsModel(
        id: 103,
        title: 'Q3 Financial Overview',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        publishedAt: DateTime.now().subtract(const Duration(days: 19)),
        reportStatus: 1,
        status: 'processed',
        url:
            'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      ),
      ReportsModel(
        id: 104,
        title: 'Weekly Team Performance',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        reportStatus: 1,
        status: 'processed',
        url:
            'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      ),
      ReportsModel(
        id: 105,
        title: 'Inventory Status Report',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        publishedAt: DateTime.now(),
        reportStatus: 1,
        status: 'processed',
        url:
            'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      ),
    ];
  }

  @override
  Future<Map<String, String>> getReportUrl(int reportId) async {
    final urlData = await _reportsService.getReportUrl(reportId);
    return urlData;
  }
}
