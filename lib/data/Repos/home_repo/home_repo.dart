import 'package:get/get.dart';

import '../../../values/constants.dart';
import '../../api_provider/api_provider.dart';

class HomeRepo extends GetxService {
  ApiProvider apiProvider;
  HomeRepo({
    required this.apiProvider,
  });

  Future<Response> getAllCategories({required String accessToken}) async {
    return await apiProvider.getData(Constants.getAllCategories,
        headers: {"accessToken": accessToken});
  }

  Future<Response> getDietAndTrain({required String accessToken}) async {
    return await apiProvider.getData(Constants.getAllDietAndTrain,
        headers: {"accessToken": accessToken});
  }

  Future<Response> getAllUsers({required String accessToken}) async {
    return await apiProvider
        .getData(Constants.getAllUsers, headers: {"accessToken": accessToken});
  }

  Future<Response> getTrainerHome(
      {required String accessToken, required String userId}) async {
    return await apiProvider.getData("${Constants.getTrainerHome}/$userId",
        headers: {"accessToken": accessToken});
  }

  Future<Response> getWeeklyReportsRepo({required String accessToken}) async {
    return await apiProvider
        .getData(Constants.getReports, headers: {"accessToken": accessToken});
  }

  Future<Response> getDietHome(
      {required String accessToken, required String userId}) async {
    return await apiProvider.getData("${Constants.getDietHome}/$userId",
        headers: {"accessToken": accessToken});
  }

  Future<Response> getGuestUsers(
      {required String accessToken, required String userId}) async {
    return await apiProvider.getData(Constants.getGuestUsers,
        headers: {"accessToken": accessToken});
  }

  Future<Response> getPlanImages({
    required String accessToken,
  }) async {
    return await apiProvider.getData(Constants.getAllUsersPlanImages,
        headers: {"accessToken": accessToken});
  }

  Future<Response> getUserHome(
      {required String accessToken, required String userId}) async {
    return await apiProvider.getData("${Constants.getUserHome}/$userId",
        headers: {"accessToken": accessToken});
  }

  Future<Response> getAllPlans({required String accessToken}) async {
    return await apiProvider.postData(Constants.getAllPlans,
        headers: {"accessToken": accessToken}, body: {});
  }

  // Future<Response> getHomeReviews({required String accessToken}) async {
  //   return await apiProvider.getData(Constants.getHomeReviews,
  //       headers: {"accessToken": accessToken});
  // }
  Future<Response> addPlanRepo(
      {required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.postAddPlan,
        body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> updatePlanRepo(
      {required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.postUpdatePlan,
        body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> addUserRepo(
      {required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.addNewUser,
        body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> getPaymentLink(
      {required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.payment,
        body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> addAnnouncement(
      {required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.addAnnouncement,
        body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> freezeMyAccount(
      {required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.freezeMyAccount,
        body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> synchronizationRepo({required String accessToken}) async {
    return await apiProvider.getData(Constants.synchronization,
        headers: {"accessToken": accessToken});
  }

  Future<Response> updateWeeklyReportRepo(
      {required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.addReport,
        body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> updateLinkRepo(
      {required String accessToken,
      required Map<String, dynamic> map,
      required bool isDiet}) async {
    return await apiProvider.postData(
        isDiet ? Constants.updateDietLink : Constants.updateLink,
        body: map,
        headers: {"accessToken": accessToken});
  }

  Future<Response> addTeamMemberRepo(
      {required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.addTeamMember,
        body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> updateUserRepo(
      {required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.updateUser,
        body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> approveUser(
      {required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.approveUser,
        body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> addTestimonials(
      {required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.setFormData(
        url: Constants.addTestimonials,
        formData: map,
        headers: {"accessToken": accessToken});
  }

  Future<Response> addPlanImageRepo(
      {required String accessToken, required Map<String, dynamic> map}) async {

    print("map $map");
    return await apiProvider.setFormData(
        url: Constants.addPlanImage,
        formData: map,
        headers: {"accessToken": accessToken});
  }
  // Future<Response> submitOrSkipFeedback({required String accessToken, required Map<String, dynamic> map}) async {
  //   return await apiProvider.postData(Constants.skipOrSubmit,
  //       body: map, headers: {"accessToken": accessToken});
  // }
  // Future<Response> cancelAppoinment({required String accessToken, required Map<String, String> map}) async {
  //   return await apiProvider.postData(Constants.removeAppointment,
  //       body: map, headers: {"accessToken": accessToken});
  // }
  //
  //
  //
  // Future<Response> getSubCategories(
  //     {required String accessToken, required Map<String, String> map}) async {
  //   return await apiProvider.postData(Constants.getSubCategories,
  //       body: map, headers: {"accessToken": accessToken});
  // }
  // Future<Response> getAllAppointmentsByDate(
  //     {required String accessToken, required Map<String, String> map}) async {
  //   return await apiProvider.postData(Constants.getAllAppointmentsByDate,
  //       body: map, headers: {"accessToken": accessToken});
  // }
  //
  // Future<Response> get(
  //     {required String accessToken, required Map<String, String> map}) async {
  //   return await apiProvider.postData(Constants.getCatByKeyword,
  //       body: map, headers: {"accessToken": accessToken});
  // }
}
