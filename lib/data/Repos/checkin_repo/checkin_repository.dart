import 'package:get/get.dart';
import '../../../values/constants.dart';
import '../../api_provider/api_provider.dart';

class CheckinRepository extends GetxService {
  ApiProvider apiProvider;

  CheckinRepository({
    required this.apiProvider,
  });

  Future<Response> saveDailyCheckin({
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    return await apiProvider.postData(
      Constants.saveDailyCheckin,
      body: body,
      headers: {"accessToken": accessToken},
    );
  }

  Future<Response> getDailyCheckin({
    required String accessToken,
    required String date,
  }) async {
    return await apiProvider.getData(
      '${Constants.getDailyCheckin}?date=$date',
      headers: {"accessToken": accessToken},
    );
  }

  Future<Response> getDailyCheckinsWeek({
    required String accessToken,
  }) async {
    return await apiProvider.getData(
      Constants.getDailyCheckinsWeek,
      headers: {"accessToken": accessToken},
    );
  }

  Future<Response> getDailyCheckinsRecent({
    required String accessToken,
    int limit = 7,
  }) async {
    return await apiProvider.getData(
      '${Constants.getDailyCheckinsRecent}?limit=$limit',
      headers: {"accessToken": accessToken},
    );
  }

  Future<Response> saveWeeklyCheckin({
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    return await apiProvider.postData(
      Constants.saveWeeklyCheckin,
      body: body,
      headers: {"accessToken": accessToken},
    );
  }

  Future<Response> getWeeklyCheckinsRecent({
    required String accessToken,
  }) async {
    return await apiProvider.getData(
      Constants.getWeeklyCheckinsRecent,
      headers: {"accessToken": accessToken},
    );
  }
}
