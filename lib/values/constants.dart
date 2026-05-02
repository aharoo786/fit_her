import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class Constants {
  static const String robotoFamily = "Roboto";
  static const String RobotoFamily = "Roboto";
  static const String isGuest = "isGuest";
  static const String chatRoom = "chatRoom";
  static const String allMessages = "allMessages";
  static const String reviewDate = "reviewDate";
  static const String giveReview = "giveReview";

  static const String subscriptionDuration = "subscriptionDuration";
  static String countryCode = "92";
  static String countryName = "PK";
  static String screenShot = "screenShot";
  static String notificationList = "notificationList";
  static String upcomingSlot = "upcomingSlot";
  static String type = "type";
  static String recording = "recording";
  static String fullName = "fullName";
  static String packageState = "packageState";
  static String userId = "userId";
  static String trialToken = "trialToken";

  static String email = "email";
  static String password = "p";
  static String loginAsa = "loginAsa";
  static String userMobileNumber = "userMobileNumber";
  static String userUid = "userUid";
  static String userCountryCode = "userCountryCode";
  static String trainer = "Trainer";
  static String dietitian = "Dietition";
  static String customerSupport = "Customer_Support_Representative";
  static String admin = "Admin";
  static String GYNECOLOGIST = "Gynecologist";
  static String PSYCHIATRIST = "Psychiatrist";

  static String user = "User";
  static String accessToken = "accessToken";
  static String login = "login";
  static String weeklyReports = "weeklyReports";

  ///base url
  // static String baseUrl = "https://test.thefither.com";
  // static String baseUrl = "http://192.168.1.31:9005";
//   static String baseUrl = "https://backend.thefither.com";
static String baseUrl = dotenv.env['BASE_URL'] ?? "http://10.47.229.64:8000";
  static String customerSupportLink =
      "https://backend.thefither.com/customerSupport/";
  static const chatBaseUrl =
      "https://fcm.googleapis.com/v1/projects/fither-e7a36/messages:send";

  /// Firebase collections and document collection
  static String customers = "customers";
  static String fcmToken = "fcmToken";
  static String members = "members";
  static String deviceToken = "deviceToken";
  static String announcementNotification = "announcementNotification";
  static String serverKey = dotenv.env['FCM_SERVER_KEY'] ?? '';

  /// Apis end points

  static String signupPath = "/users/registration";
  static String loginPath = "/admin/login";
  static String socialLogin = "/admin/socialLogin";
  static String guestLogin = "/admin/guestlogin";
  static String forgotPassword = "/users/forget_password";
  static String resetPassword = "/users/change_password_after_otp";
  static String dietitianLogin = "/users/dietition_login";
  static String trainerLogin = "/users/trainer_login";
  static String getAllCategories = "/admin/all_categories";
  static String getSubCat = "/admin/get_subcategories";
  static String getUserDietPlans = "/admin/userDietPlans";
  static String getClients = "/dietTimes/getClients";
  static String addCalorieImage = "/dietTimes/checkNutrition";
  static String getAppointments = "/appointment/dietAppointments";
  static String rescheduleAppointments =
      "/appointment/rescheduled/appointments";
  static String getConsultationStatus = "/appointment/status";
  static String getSchedulePdfStatus = "/admin/getDietPlanStatus";
  static String dietTimes = "/dietTimes";
  static String addReview = "/admin/addReview";
  static String getUserWorkoutPlans = "/admin/user_workout_plans";
  static String getUserImagesProgress = "/admin/getProgressImages";
  static String getUserDietPlanDetails = "/admin/dietPlanDetails";
  static String getDietPdf = "/admin/getDietPdf";
  static String getUserWorkoutPlanDetails = "/admin/workout_plan_details";
  static String getSubCatBasedOnUserType =
      "/admin/get_subcategories_based_on_user_types";
  static String getUsersOnUserType = "/admin/get_users_based_on_types";
  static String getPlansBasedOnSubCat =
      "/admin/get_plans_based_on_sub_categories";
  static String getWorkoutAndTrainersPlan = "/admin/workout_plans";
  static String getAllDietAndTrain = "/admin/getAllDeititions";
  static String getAllUsers = "/admin/get_all_users";
  static String getAllUserWithSpecificCustomer =
      "/admin/getAllCustomSupporters";
  static String getTrainerHome = "/admin/trainerHome";
  static String getReports = "/admin/userReports";
  static String getDietHome = "/admin/dietitionHome";
  static String getFreePlan = "/admin/getFreePlan";
  static String getGuestUsers = "/admin/getGuest";
  static String getAllUsersPlanImages = "/admin/getAllPlanImages";
  static String getTeamMembers = "/admin/getTeamMember";
  static String getUserHome = "/admin/userHome";
  static String getAllPlans = "/admin/get_plans";
  static String addFreeTrial = "/admin/assignFreePlan";
  static String getAllHealthTips = "/admin/getAllHealthTips";
  static String postAddPlan = "/admin/add_plan";
  static String postUpdatePlan = "/admin/update_plan";
  static String addNewUser = "/admin/addUser";
  static String addUserDetails = "/admin/addUserDetails";
  static String payment = "/admin/payment";
  static String getAllTimesWithSlots = "/admin/getAllTimesWithSlots";
  static String getAllFreeTrialUsers = "/admin/getFreeTrialUserById";
  static String changeFreeTrialStatus = "/admin/changeFreeTrialStatus";
  static String assignWorkoutAndTrainerPlan = "/admin/assign_workout_diet_plan";
  static String addDietionPlan = "/admin/dietition_add_plan";
  static String addAnnouncement = "/admin/addAnnouncement";
  static String freezeMyAccount = "/admin/freeze";
  static String synchronization = "/admin/syncrhonize";
  static String addReport = "/admin/addReport";
  static String updateLink = "/admin/updateLink";
  static String updateDietLink = "/admin/updateDietitionLink";
  static String updateTrainerJoin = "/admin/updateTrainerJoin";
  static String updateSlotStatus = "/admin/updateSlotStatus";
  static String addTeamMember = "/admin/addTeamMember";
  static String updateUser = "/admin/updateUser";
  static String paymentSuccess = "/admin/payment_success";
  static String approveUser = "/admin/approvedImage";
  static String addTestimonials = "/admin/add_testimonial";
  static String addPdfFile = "/admin/addDietPdf";
  static String updateUserProfile = "/admin/update_user";
  static String updateUserDietOfWeek = "/admin/addDiet";
  static String addPlanImage = "/admin/addImage";
  static String addProgressImages = "/admin/addProgressImages";
  static String resendOtpPath = "/users/resend_otp";
  static String home = "/users/home";
  static String getDietitianUsers = "/users/dietition_get_all_users";
  static String getUserPlan = "/users/get_user_plans";
  /// Direct Pay (Payin PWA) - backend returns payment URL; client_secret stays on server
  static String directPayUrl = "/pay/directpay_payment";
  static String logout = "/users/logout";
  static String deleteUser = "/admin/delete_user";
  static String updateSlotTrainer = "/admin/update_slot_trainer";
  static String addFreeTrailUser = "/admin/createFreeTrialUser";

  /// 3-Day Trial MVP
  static String trialValidateToken = "/trial/validate-token";
  static String trialStart = "/trial/start";
  static String trialMe = "/trial/me";
  static String trialBookDay = "/trial/book-day";
  static String trialAttendance = "/trial/attendance";
  static String trialConvert = "/trial/convert";

  /// Motivation module
  static String getMotivationStats = "/attendance/motivation";
  static String markMotivationAttendance = "/attendance/mark";

  ///  Country ///
  static String country = "/country";
  static String add_slots = "/admin/update_slots";

  ///Duration
  static String timeDuration = "/duration/create";

  /// CYCLE DATA
  static const String getCycleData = "/users/cycle_data";
  static const String saveCycleData = "/users/cycle_data";

  /// CHECK-INS
  static const String saveDailyCheckin = "/users/daily_checkin";
  static const String getDailyCheckin = "/users/daily_checkin";
  static const String getDailyCheckinsWeek = "/users/daily_checkins/week";
  static const String getDailyCheckinsRecent = "/users/daily_checkins/recent";
  static const String saveWeeklyCheckin = "/users/weekly_checkin";
  static const String getWeeklyCheckinsRecent = "/users/weekly_checkins/recent";

  /// POSTS MODULE
  static const String getAllPosts = "/posts/";
  static const String createPost = "/posts";
  static const String deletePost = "/posts";
  static const String approvePost = "/posts/approve";
  static const String likePost = "/posts/like"; // new
  static const String sendReply = "/posts/reply"; // new
  static const String getReplies = "/posts/replies"; // new
    // POST approve/disapprove post


}

String get today => DateFormat('EEEE').format(DateTime.now());
String get tomorrow =>
    DateFormat('EEEE').format(DateTime.now().add(const Duration(days: 1)));
