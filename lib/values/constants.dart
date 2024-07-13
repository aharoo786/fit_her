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
  static String user = "User";
  static String accessToken = "accessToken";
  static String login = "login";
  static String weeklyReports = "weeklyReports";

  ///base url
//   static String baseUrl = "http://192.168.1.26:8000";
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
  static String getAllDietAndTrain = "/admin/getAllDeititions";
  static String getAllUsers = "/admin/get_all_users";
  static String getTrainerHome = "/admin/trainerHome";
  static String getReports = "/admin/userReports";
  static String getDietHome = "/admin/dietitionHome";
  static String getGuestUsers = "/admin/getGuest";
  static String getAllUsersPlanImages = "/admin/getAllPlanImages";
  static String getUserHome = "/admin/userHome";
  static String getAllPlans = "/admin/get_plans";
  static String postAddPlan = "/admin/add_plan";
  static String postUpdatePlan = "/admin/add_plan";
  static String addNewUser = "/admin/addUser";
  static String payment = "/admin/payment";
  static String addAnnouncement = "/admin/addAnnouncement";
  static String freezeMyAccount = "/admin/freeze";
  static String synchronization = "/admin/syncrhonize";
  static String addReport = "/admin/addReport";
  static String updateLink = "/admin/updateLink";
  static String updateDietLink = "/admin/updateDietitionLink";
  static String addTeamMember = "/admin/addTeamMember";
  static String updateUser = "/admin/updateUser";
  static String approveUser = "/admin/approvedImage";
  static String addTestimonials = "/admin/add_testimonial";
  static String addPlanImage = "/admin/addImage";
  static String resendOtpPath = "/users/login";
  static String home = "/users/home";
  static String getDietitianUsers = "/users/dietition_get_all_users";
  static String getUserPlan = "/users/get_user_plans";
  static String stripePayment = "/users/stripe_payment";
  static String logout = "/users/logout";
}
