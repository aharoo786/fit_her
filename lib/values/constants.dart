class Constants {
  static const String robotoFamily = "Roboto";
  static const String RobotoFamily = "Roboto";
  static const String isGuest = "isGuest";
  static const appID = '4babf557757745deb4176da00b193310';
  static const appCertificate = '94b22af90adb429e8a88e32f7e475e78';
  static const chatAppKey = '411039298#1214303';
  static const String chatRoom = "chatRoom";
  static const String allMessages = "allMessages";

  static const String subscriptionDuration = "subscriptionDuration";
  static String countryCode = "92";
  static String countryName = "PK";
  static String screenShot = "screenShot";
  static String type = "type";
  static String recording = "recording";
  static String fullName = "fullName";
  static String packageState = "packageState";
  static String userId = "userId";

  static String email = "email";
  static String password = "password";
  static String userMobileNumber = "userMobileNumber";
  static String userUid = "userUid";
  static String userCountryCode = "userCountryCode";
  static String trainer = "Trainer";
  static String dietitian = "Dietition";
  static String admin = "Admin";
  static String GYNECOLOGIST = "Gynecologist";
  static String PSYCHIATRIST = "Psychiatrist";

  static String user = "User";
  static String accessToken = "accessToken";
  static String login = "login";
  static String weeklyReports = "weeklyReports";

  ///base url
  // static String baseUrl = "http://192.168.1.2:8001";
  static String baseUrl = "https://backend.thefither.com";
  static const chatBaseUrl =
      "https://fcm.googleapis.com/v1/projects/fither-e7a36/messages:send";

  /// Firebase collections and document collection
  static String customers = "customers";
  static String fcmToken = "fcmToken";
  static String members = "members";
  static String deviceToken = "deviceToken";
  static const serverKey =
      "AAAAY1XRUEo:APA91bHjQM7SlZ0Yj9rSCJzJoLfatUhOJkye1HfBQsJkw8c8p92-L44E5t7jAc0FJy-sFzcYprNQWmutMifd2DVUhZQF08qRl1IePncuPLWoh-0V1aTEbQgEm74BHlHCkucRDHsWGNJu";

  /// Apis end points

  static String signupPath = "/users/registration";
  static String loginPath = "/admin/login";
  static String guestLogin = "/admin/guestlogin";
  static String dietitianLogin = "/users/dietition_login";
  static String trainerLogin = "/users/trainer_login";
  static String getAllCategories = "/admin/all_categories";
  static String getSubCat = "/admin/get_subcategories";
  static String getUserDietPlans = "/admin/userDietPlans";
  static String getUserWorkoutPlans = "/admin/user_workout_plans";
  static String getUserImagesProgress = "/admin/getProgressImages";
  static String getUserDietPlanDetails = "/admin/dietPlanDetails";
  static String getUserWorkoutPlanDetails = "/admin/workout_plan_details";
  static String getSubCatBasedOnUserType = "/admin/get_subcategories_based_on_user_types";
  static String getUsersOnUserType = "/admin/get_users_based_on_types";
  static String getPlansBasedOnSubCat = "/admin/get_plans_based_on_sub_categories";
  static String getWorkoutAndTrainersPlan = "/admin/workout_plans";
  static String getAllDietAndTrain = "/admin/getAllDeititions";
  static String getAllUsers = "/admin/get_all_users";
  static String getTrainerHome = "/admin/trainerHome";
  static String getReports = "/admin/userReports";
  static String getDietHome = "/admin/dietitionHome";
  static String getFreePlan = "/admin/getFreePlan";
  static String getGuestUsers = "/admin/getGuest";
  static String getAllUsersPlanImages = "/admin/getAllPlanImages";
  static String getTeamMembers = "/admin/getTeamMember";
  static String getUserHome = "/admin/userHome";
  static String getAllPlans = "/admin/get_plans";
  static String getAllHealthTips = "/admin/getAllHealthTips";
  static String postAddPlan = "/admin/add_plan";
  static String postUpdatePlan = "/admin/add_plan";
  static String addNewUser = "/admin/addUser";
  static String payment = "/admin/payment";
  static String changeFreeTrialStatus = "/admin/changeFreeTrialStatus";
  static String assignWorkoutAndTrainerPlan = "/admin/assign_workout_diet_plan";
  static String addDietionPlan = "/admin/dietition_add_plan";
  static String addAnnouncement = "/admin/addAnnouncement";
  static String freezeMyAccount = "/admin/freeze";
  static String synchronization = "/admin/syncrhonize";
  static String addReport = "/admin/addReport";
  static String updateLink = "/admin/updateLink";
  static String updateDietLink = "/admin/updateDietitionLink";
  static String addTeamMember = "/admin/addTeamMember";
  static String updateUser = "/admin/updateUser";
  static String paymentSuccess = "/admin/payment_success";
  static String approveUser = "/admin/approvedImage";
  static String addTestimonials = "/admin/add_testimonial";
  static String updateUserProfile = "/admin/update_user";
  static String updateUserDietOfWeek = "/admin/addDiet";
  static String addPlanImage = "/admin/addImage";
  static String addProgressImages = "/admin/addProgressImages";
  static String resendOtpPath = "/users/login";
  static String home = "/users/home";
  static String getDietitianUsers = "/users/dietition_get_all_users";
  static String getUserPlan = "/users/get_user_plans";
  static String stripePayment = "/users/stripe_payment";
  static String logout = "/users/logout";
  static String deleteUser = "/users/delete_user";
}
