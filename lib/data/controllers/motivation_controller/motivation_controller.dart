import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../values/constants.dart';
import '../../../widgets/toasts.dart';
import '../../Repos/home_repo/home_repo.dart';
import '../../GetServices/CheckConnectionService.dart';
import '../../models/api_response/api_response_model.dart';
import '../../models/motivation_stats/motivation_stats_model.dart';

class MotivationController extends GetxController implements GetxService {
  final SharedPreferences sharedPreferences;
  final HomeRepo homeRepo;

  MotivationController({required this.sharedPreferences, required this.homeRepo});

  final CheckConnectionService connectionService = CheckConnectionService();

  /// Loading states
  final isLoadingStats = false.obs;
  final isMarkingAttendance = false.obs;

  /// Data
  final motivationStats = Rxn<MotivationStatsData>();

  Future<void> fetchMotivationStats() async {
    isLoadingStats.value = true;
    final hasInternet = await connectionService.checkConnection();
    if (!hasInternet) {
      CustomToast.noInternetToast();
      isLoadingStats.value = false;
      return;
    }

    try {
      final String accessToken = sharedPreferences.getString(Constants.accessToken) ?? "";
      final String userId = sharedPreferences.getString(Constants.userId) ?? "";

      final response = await homeRepo.getMotivationStats(accessToken: accessToken, userId: userId);

      if (response.body["status"] == "0") {
        CustomToast.failToast(msg: response.body["message"] ?? "Failed to fetch stats");
      } else {
        // Parse the response using the model
        final ApiResponse<MotivationStatsData> model = ApiResponse.fromJson(response.body, MotivationStatsData.fromJson);

        if (model.status == "1") {
          motivationStats.value = model.data;
        }
      }
    } catch (e) {
      CustomToast.failToast(msg: e.toString());
    } finally {
      isLoadingStats.value = false;
    }
  }

  Future<void> markAttendance({String? slotId}) async {
    isMarkingAttendance.value = true;
    final hasInternet = await connectionService.checkConnection();
    if (!hasInternet) {
      CustomToast.noInternetToast();
      isMarkingAttendance.value = false;
      return;
    }

    try {
      final String accessToken = sharedPreferences.getString(Constants.accessToken) ?? "";
      final String userId = sharedPreferences.getString(Constants.userId) ?? "";
      final Map<String, dynamic> body = {
        if (slotId != null) "slotId": slotId,
      };

      final response = await homeRepo.markMotivationAttendance(accessToken: accessToken, userId: userId, map: body);

      if (response.body["status"] == "0") {
        // CustomToast.failToast(
        //     msg: response.body["message"] ?? "Attendance not marked");
      } else {
        // CustomToast.successToast(
        //     msg: response.body["message"] ?? "Attendance marked successfully");
        // Refresh stats after marking attendance
        //  await fetchMotivationStats();
      }
    } catch (e) {
      // CustomToast.failToast(msg: e.toString());
    } finally {
      isMarkingAttendance.value = false;
    }
  }

  // Getters for easy access to stats data
  int get streak => motivationStats.value?.streak ?? 0;
  int get daysAttendedLast7 => motivationStats.value?.daysAttendedLast7 ?? 0;
  int get daysAttendedLast30 => motivationStats.value?.daysAttendedLast30 ?? 0;
  int get regularityPercentage => motivationStats.value?.regularityPercentage ?? 0;
  List<AttendanceHistoryItem> get attendanceHistory => motivationStats.value?.attendanceHistory ?? [];
}
