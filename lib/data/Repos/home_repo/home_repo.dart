import 'package:get/get.dart';
import 'dart:io';
import '../../../values/constants.dart';
import '../../api_provider/api_provider.dart';

class HomeRepo extends GetxService {
  ApiProvider apiProvider;

  HomeRepo({
    required this.apiProvider,
  });

  Future<Response> getAllCategories({required String accessToken}) async {
    return await apiProvider.getData(Constants.getAllCategories, headers: {"accessToken": accessToken});
  }

  Future<Response> getSubCategories({required String accessToken, required String catId}) async {
    return await apiProvider.getData("${Constants.getSubCat}/$catId", headers: {"accessToken": accessToken});
  }

  Future<Response> getUserPlansDiet({required String accessToken, required String userId}) async {
    return await apiProvider.getData("${Constants.getUserDietPlans}/$userId", headers: {"accessToken": accessToken});
  }

  Future<Response> getClients({required String accessToken, required String userId}) async {
    return await apiProvider.getData("${Constants.getClients}/$userId", headers: {"accessToken": accessToken});
  }

  Future<Response> getAppointments({required String accessToken, required String userId}) async {
    return await apiProvider.getData("${Constants.getAppointments}/$userId", headers: {"accessToken": accessToken});
  }

  Future<Response> getRescheduleAppointments({
    required String accessToken,
    required bool reschedule,
  }) async {
    return await apiProvider.getData("${Constants.rescheduleAppointments}/$reschedule", headers: {"accessToken": accessToken});
  }

  Future<Response> getConsultationStatus({
    required String accessToken,
  }) async {
    return await apiProvider.getData(Constants.getConsultationStatus, headers: {"accessToken": accessToken});
  }

  Future<Response> getReschedulePdfStatus({
    required String accessToken,
  }) async {
    return await apiProvider.getData(Constants.getSchedulePdfStatus, headers: {"accessToken": accessToken});
  }

  Future<Response> getTimesOfDiet({required String accessToken, required String userId}) async {
    return await apiProvider.getData(Constants.dietTimes, headers: {"accessToken": accessToken});
  }

  Future<Response> getDaySlots({required String accessToken, required String userId, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.dietTimes, headers: {"accessToken": accessToken}, body: map);
  }

  Future<Response> getUserPlansWorkout({required String accessToken, required String userId}) async {
    return await apiProvider.getData("${Constants.getUserWorkoutPlans}/$userId", headers: {"accessToken": accessToken});
  }

  Future<Response> getUserImagesProgress({required String accessToken, required String userId}) async {
    return await apiProvider.getData("${Constants.getUserImagesProgress}/$userId", headers: {"accessToken": accessToken});
  }

  Future<Response> getUserPlanDetailsDiet({required String accessToken, required String planId}) async {
    return await apiProvider.getData("${Constants.getUserDietPlanDetails}/$planId", headers: {"accessToken": accessToken});
  }

  Future<Response> getDietPdfRepo({required String accessToken, required String planId, required String userId}) async {
    return await apiProvider.postData(Constants.getDietPdf, body: {"userId": userId, "userPlanId": planId}, headers: {"accessToken": accessToken});
  }

  Future<Response> getUserPlanDetailsWorkout(
      {required String accessToken, required String planId, required bool showSlots, required String userId}) async {
    return await apiProvider.getData("${Constants.getUserWorkoutPlanDetails}/$planId/$userId/$showSlots", headers: {"accessToken": accessToken});
  }

  Future<Response> getSubCategoriesBasedOnUserTypes({required String accessToken, required String userType}) async {
    return await apiProvider.getData("${Constants.getSubCatBasedOnUserType}/$userType", headers: {"accessToken": accessToken});
  }

  Future<Response> getSubUserBasedOnUserTypes({required String accessToken, required String userType}) async {
    return await apiProvider.getData("${Constants.getUsersOnUserType}/$userType", headers: {"accessToken": accessToken});
  }

  Future<Response> getPlansBasedOnSubCat({required String accessToken, required String subCat}) async {
    return await apiProvider.getData("${Constants.getPlansBasedOnSubCat}/$subCat", headers: {"accessToken": accessToken});
  }

  Future<Response> getWorkoutAndTrainerPlan({required String accessToken}) async {
    return await apiProvider.getData(Constants.getWorkoutAndTrainersPlan, headers: {"accessToken": accessToken});
  }

  Future<Response> getDietAndTrain({required String accessToken}) async {
    return await apiProvider.getData(Constants.getAllDietAndTrain, headers: {"accessToken": accessToken});
  }

  Future<Response> getAllUsers({bool isCustomerSupport = false, required String accessToken, required String userId}) async {
    if (isCustomerSupport) {
      return await apiProvider.getData("${Constants.getAllUserWithSpecificCustomer}/${userId}", headers: {"accessToken": accessToken});
    } else {
      return await apiProvider.getData(Constants.getAllUsers, headers: {"accessToken": accessToken});
    }
  }

  Future<Response> getTrainerHome({required String accessToken, required String userId}) async {
    return await apiProvider.getData("${Constants.getTrainerHome}/$userId", headers: {"accessToken": accessToken});
  }

  Future<Response> getWeeklyReportsRepo({required String accessToken}) async {
    return await apiProvider.getData(Constants.getReports, headers: {"accessToken": accessToken});
  }

  Future<Response> getDietHome({required String accessToken, required String userId}) async {
    return await apiProvider.getData("${Constants.getDietHome}/$userId", headers: {"accessToken": accessToken});
  }

  Future<Response> getFreePlan({required String accessToken}) async {
    return await apiProvider.getData("${Constants.getFreePlan}", headers: {"accessToken": accessToken});
  }

  Future<Response> getGuestUsers({required String accessToken, required String userId}) async {
    return await apiProvider.getData(Constants.getGuestUsers, headers: {"accessToken": accessToken});
  }

  Future<Response> getPlanImages({
    required String accessToken,
  }) async {
    return await apiProvider.getData(Constants.getAllUsersPlanImages, headers: {"accessToken": accessToken});
  }

  Future<Response> getTeamMembersRepo({
    required String accessToken,
  }) async {
    return await apiProvider.getData(Constants.getTeamMembers, headers: {"accessToken": accessToken});
  }

  Future<Response> getUserHome({required String accessToken, required String userId, required String code}) async {
    return await apiProvider.getData("${Constants.getUserHome}/$userId/$code", headers: {"accessToken": accessToken});
  }

  Future<Response> getAllPlans({required String accessToken, required String code}) async {
    return await apiProvider.getData(
      "${Constants.getAllPlans}/${code}",
      headers: {"accessToken": accessToken},
    );
  }

  Future<Response> addFreeTrialUser({required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(
      Constants.addFreeTrial,
      headers: {"accessToken": accessToken},
      body: map,
    );
  }

  Future<Response> getAllPlansAdmin({required String accessToken}) async {
    return await apiProvider.getData(
      Constants.getAllPlans,
      headers: {"accessToken": accessToken},
    );
  }

  Future<Response> getHealthTips({required String accessToken}) async {
    return await apiProvider.getData(
      Constants.getAllHealthTips,
      headers: {"accessToken": accessToken},
    );
  }

  // Future<Response> getHomeReviews({required String accessToken}) async {
  //   return await apiProvider.getData(Constants.getHomeReviews,
  //       headers: {"accessToken": accessToken});
  // }
  Future<Response> addPlanRepo({required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.postAddPlan, body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> updatePlanRepo({required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.postUpdatePlan, body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> addUserRepo({required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.addNewUser, body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> addUserDetails({required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.addUserDetails, body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> getPaymentLink({required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.payment, body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> getAllTimesWithSlotsTrainer({required String accessToken}) async {
    return await apiProvider.getData(Constants.getAllTimesWithSlots, headers: {"accessToken": accessToken});
  }

  Future<Response> getAllFreeTrialUsers({required String accessToken, required String id, required String slotId}) async {
    return await apiProvider.getData("${Constants.getAllFreeTrialUsers}/$id/$slotId", headers: {"accessToken": accessToken});
  }

  Future<Response> changeFreeTrialStatus({required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.changeFreeTrialStatus, body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> addCountry({required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.country, body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> addTimeDuration({required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.timeDuration, body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> getCountries({required String accessToken}) async {
    return await apiProvider.getData(Constants.country, headers: {"accessToken": accessToken});
  }

  Future<Response> getTmeDurations({required String accessToken}) async {
    return await apiProvider.getData(Constants.timeDuration, headers: {"accessToken": accessToken});
  }

  Future<Response> addTrainerSlots({required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.add_slots, body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> addClassDetails({required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.updateSlotTrainer, body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> addFreeTrialUserData({required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.addFreeTrailUser, body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> assignWorkoutAndTrainer({required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.assignWorkoutAndTrainerPlan, body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> addDietitionPlan({required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.addDietionPlan, body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> addAnnouncement({required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.addAnnouncement, body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> freezeMyAccount({required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.freezeMyAccount, body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> synchronizationRepo({required String accessToken}) async {
    return await apiProvider.getData(Constants.synchronization, headers: {"accessToken": accessToken});
  }

  Future<Response> updateWeeklyReportRepo({required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.addReport, body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> updateLinkRepo({required String accessToken, required Map<String, dynamic> map, required bool isDiet}) async {
    return await apiProvider.postData(isDiet ? Constants.updateDietLink : Constants.updateLink, body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> updateTrainerJoin({required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.updateTrainerJoin, body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> updateSlotStatus({required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.updateSlotStatus, body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> addTeamMemberRepo({required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.addTeamMember, body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> updateUserRepo({required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.updateUser, body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> updateUserPayment({required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.paymentSuccess, body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> approveUser({required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.approveUser, body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> addTestimonials({required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.setFormData(url: Constants.addTestimonials, formData: map, headers: {"accessToken": accessToken});
  }

  Future<Response> addPdfFileRepo({required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.setFormData(url: Constants.addPdfFile, formData: map, headers: {"accessToken": accessToken});
  }

  Future<Response> addDaySlots({required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData("${Constants.dietTimes}/addOrUpdateDaySlot", body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> addReview({required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.addReview, body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> bookAppointment({required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData("/appointment", body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> updateAppointment({required String accessToken, required Map<String, dynamic> map, required String id}) async {
    return await apiProvider.putData("/appointment/$id", body: map, headers: {
      "accessToken": accessToken,
    });
  }

  Future<Response> deleteAppointment({required String accessToken, required String id}) async {
    return await apiProvider.deleteData("/appointment/$id", headers: {
      "accessToken": accessToken,
    });
  }

  Future<Response> updateUserProfile({required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.setFormData(url: Constants.updateUserProfile, formData: map, headers: {"accessToken": accessToken});
  }

  Future<Response> updateUserDietOfWeek({required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.postData(Constants.updateUserDietOfWeek, body: map, headers: {"accessToken": accessToken});
  }

  Future<Response> addPlanImageRepo({required String accessToken, required Map<String, dynamic> map}) async {
    print("map $map");
    return await apiProvider.setFormData(url: Constants.addPlanImage, formData: map, headers: {"accessToken": accessToken});
  }

  Future<Response> addProgressImages({required String accessToken, required Map<String, dynamic> map}) async {
    return await apiProvider.setFormData(url: Constants.addProgressImages, formData: map, isProgress: true, headers: {"accessToken": accessToken});
  }

  Future<Response> addCalorieImage({required String accessToken, required Map<String, dynamic> map, required String id}) async {
    return await apiProvider.postData("${Constants.addCalorieImage}/$id", body: map, headers: {"accessToken": accessToken});
  }

  buyDescription({required Map<String, dynamic> body, required String accessToken}) async {
    return await apiProvider.postData(Constants.stripePayment, body: body, headers: {"accessToken": accessToken});
  }

  /// Motivation module
  Future<Response> getMotivationStats({required String accessToken, required String userId}) async {
    return await apiProvider.getData("${Constants.getMotivationStats}/$userId", headers: {"accessToken": accessToken});
  }

  Future<Response> markMotivationAttendance({required String accessToken, required String userId, required Map<String, dynamic> map}) async {
    return await apiProvider.postData("${Constants.markMotivationAttendance}/$userId", body: map, headers: {"accessToken": accessToken});
  }

  /// Post-related APIs
  Future<Response> getAllPosts({required String accessToken, bool approved = true}) async {
    return await apiProvider.getData("${Constants.getAllPosts}$approved", headers: {"accessToken": accessToken});
  }

  Future<Response> createPost({
    required String accessToken,
    required String text,
    required String userId,
    required bool isPost,
    File? file,
  }) async {
    Map<String, dynamic> body = {
      "text": text,
      "isPost": isPost,
      "userId": userId,
    };
    if (file != null) {
      body["image"] = file.path;
      return await apiProvider.setFormData(
        url: Constants.createPost,
        formData: body,
        headers: {"accessToken": accessToken},
      );
    } else {
      return await apiProvider.postData(
        Constants.createPost,
        body: body,
        headers: {"accessToken": accessToken},
      );
    }
  }

  Future<Response> deletePost({required String accessToken, required int postId}) async {
    return await apiProvider.deleteData("${Constants.deletePost}/$postId", headers: {"accessToken": accessToken});
  }

  Future<Response> approvePost({required String accessToken, required int postId, required bool approved}) async {
    return await apiProvider.putData(
      "${Constants.approvePost}/$postId",
      body: {"approved": approved},
      headers: {"accessToken": accessToken},
    );
  }

  /// Like or Unlike Post
  Future<Response> likePost({
    required String accessToken,
    required int postId,
    required String userId,
  }) async {
    final body = {
      "postId": postId.toString(),
      "userId": userId,
    };

    return await apiProvider.postData(
      Constants.likePost,
      body: body,
      headers: {"accessToken": accessToken},
    );
  }

  /// Send a Reply (WhatsApp style)
  Future<Response> sendReply({
    required String accessToken,
    required int postId,
    required String userId,
    required String message,
    int? replyToId, // optional if replying to another message
  }) async {
    final body = {
      "postId": postId.toString(),
      "userId": userId,
      "text": message,
    };

    if (replyToId != null) {
      body["replyToId"] = replyToId.toString();
    }

    return await apiProvider.postData(
      Constants.sendReply,
      body: body,
      headers: {"accessToken": accessToken},
    );
  }

  /// Get Replies for a Post
  Future<Response> getReplies({
    required String accessToken,
    required int postId,
  }) async {
    return await apiProvider.getData(
      "${Constants.getReplies}/$postId",
      headers: {"accessToken": accessToken},
    );
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
