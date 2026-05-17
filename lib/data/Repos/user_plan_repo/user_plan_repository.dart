import 'package:get/get.dart';

import '../../../values/constants.dart';
import '../../api_provider/api_provider.dart';

/// Reads the user's assigned plans from the live backend.
///
/// Backend: `GET /users/get_user_plans` (partner_backend
/// controllers/FrontSite/userController.js `get_user_plans`). Auth via
/// the standard `accessToken` header — userId is taken from the JWT,
/// never sent in the body.
class UserPlanRepository extends GetxService {
  final ApiProvider apiProvider;

  UserPlanRepository({required this.apiProvider});

  Future<Response> getMyPlans({required String accessToken}) {
    return apiProvider.getData(
      Constants.getUserPlan,
      headers: {'accessToken': accessToken},
    );
  }
}
