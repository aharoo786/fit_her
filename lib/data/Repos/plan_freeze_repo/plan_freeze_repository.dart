import 'package:get/get.dart';
import '../../../values/constants.dart';
import '../../api_provider/api_provider.dart';

/// Plan freeze (user-button flow).
///
/// Backend contract: see partner_backend/docs/Freeze_Logic_Audit.md and
/// partner_backend/controllers/FrontSite/planFreezeController.js.
/// All endpoints require the accessToken header. The userId is derived
/// from the JWT — never sent in the body.
class PlanFreezeRepository extends GetxService {
  final ApiProvider apiProvider;

  PlanFreezeRepository({required this.apiProvider});

  Future<Response> getStatus({required String accessToken}) async {
    return apiProvider.getData(
      Constants.planFreezeStatus,
      headers: {'accessToken': accessToken},
    );
  }

  Future<Response> freeze({
    required String accessToken,
    required int days,
  }) async {
    return apiProvider.postData(
      Constants.planFreeze,
      body: {'days': days},
      headers: {'accessToken': accessToken},
    );
  }

  Future<Response> unfreeze({required String accessToken}) async {
    return apiProvider.postData(
      Constants.planUnfreeze,
      body: const {},
      headers: {'accessToken': accessToken},
    );
  }
}
