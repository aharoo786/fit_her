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

  Future<Response> getSubCategories(
      {required String accessToken, required String catId}) async {
    return await apiProvider.getData("${Constants.getSubCat}/$catId",
        headers: {"accessToken": accessToken});
  }

  Future<Response> getUserPlansDiet(
      {required String accessToken, required String userId}) async {
    return await apiProvider.getData("${Constants.getUserDietPlans}/$userId",
        headers: {"accessToken": accessToken});
  }

  Future<Response> getUserPlansWorkout(
      {required String accessToken, required String userId}) async {
    return await apiProvider.getData("${Constants.getUserWorkoutPlans}/$userId",
        headers: {"accessToken": accessToken});
  }

  Future<Response> getUserImagesProgress(
      {required String accessToken, required String userId}) async {
    return await apiProvider.getData(
        "${Constants.getUserImagesProgress}/$userId",
        headers: {"accessToken": accessToken});
  }

  Future<Response> getUserPlanDetailsDiet(
      {required String accessToken, required String planId}) async {
    return await apiProvider.getData(
        "${Constants.getUserDietPlanDetails}/$planId",
        headers: {"accessToken": accessToken});
  }

  Future<Response> getUserPlanDetailsWorkout(
      {required String accessToken, required String planId}) async {
    return await apiProvider.getData(
        "${Constants.getUserWorkoutPlanDetails}/$planId",
        headers: {"accessToken": accessToken});
  }

  Future<Response> getSubCategoriesBasedOnUserTypes(
      {required String accessToken, required String userType}) async {
    return await apiProvider.getData(
        "${Constants.getSubCatBasedOnUserType}/$userType",
        headers: {"accessToken": accessToken});
  }

  Future<Response> getSubUserBasedOnUserTypes(
      {required String accessToken, required String userType}) async {
    return await apiProvider.getData(
        "${Constants.getUsersOnUserType}/$userType",
        headers: {"accessToken": accessToken});
  }

  Future<Response> getPlansBasedOnSubCat(
      {required String accessToken, required String subCat}) async {
    return await apiProvider.getData(
        "${Constants.getPlansBasedOnSubCat}/$subCat",
        headers: {"accessToken": accessToken});
  }

  Future<Response> getWorkoutAndTrainerPlan(
      {required String accessToken}) async {
    return await apiProvider.getData(Constants.getWorkoutAndTrainersPlan,
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

  Future<Response> getFreePlan(
      {required String accessToken}) async {
    return await apiProvider.getData("${Constants.getFreePlan}",
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

  Future<Response> getTeamMembersRepo({
    required String accessToken,
  }) async {
    return await apiProvider.getData(Constants.getTeamMembers,
        headers: {"accessToken": accessToken});
  }

  Future<Response> getUserHome(
      {required String accessToken, required String userId}) async {
    return await apiProvider.getData("${Constants.getUserHome}/$userId",
        headers: {"accessToken": accessToken});
  }

  Future<Response> getAllPlans({required String accessToken}) async {
    return await apiProvider.getData(Constants.getAllPlans,
        headers: {"accessToken": accessToken},);
  }

  Future<Response> getHealthTips({required String accessToken}) async {
    return await apiProvider.getData(Constants.getAllHealthTips,
        headers: {"accessToken": accessToken},);
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
  Future<Response> changeFreeTrialStatus(
      {required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.changeFreeTrialStatus,
        body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> assignWorkoutAndTrainer(
      {required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.assignWorkoutAndTrainerPlan,
        body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> addDietitionPlan(
      {required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.addDietionPlan,
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

  Future<Response> updateUserPayment(
      {required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.paymentSuccess,
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

  Future<Response> updateUserProfile(
      {required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.setFormData(
        url: Constants.updateUserProfile,
        formData: map,
        headers: {"accessToken": accessToken});
  }

  Future<Response> updateUserDietOfWeek(
      {required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.updateUserDietOfWeek,
        body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> addPlanImageRepo(
      {required String accessToken, required Map<String, dynamic> map}) async {
    print("map $map");
    return await apiProvider.setFormData(
        url: Constants.addPlanImage,
        formData: map,
        headers: {"accessToken": accessToken});
  }

  Future<Response> addProgressImages(
      {required String accessToken, required Map<String, dynamic> map}) async {
    print("map $map");
    return await apiProvider.setFormData(
        url: Constants.addProgressImages,
        formData: map,
        isProgress: true,
        headers: {"accessToken": accessToken});
  }

  buyDescription(
      {required Map<String, dynamic> body, required String accessToken}) async {
    return await apiProvider.postData(Constants.stripePayment,
        body: body, headers: {"accessToken": accessToken});
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
