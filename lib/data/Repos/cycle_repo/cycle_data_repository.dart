import 'package:get/get.dart';
import '../../../values/constants.dart';
import '../../api_provider/api_provider.dart';

class CycleDataRepository extends GetxService {
  ApiProvider apiProvider;

  CycleDataRepository({
    required this.apiProvider,
  });

  Future<Response> getCycleData({required String accessToken}) async {
    return await apiProvider.getData(
      Constants.getCycleData,
      headers: {"accessToken": accessToken},
    );
  }

  Future<Response> saveCycleData({
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    return await apiProvider.postData(
      Constants.saveCycleData,
      body: body,
      headers: {"accessToken": accessToken},
    );
  }
}
