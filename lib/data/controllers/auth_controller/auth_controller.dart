import 'dart:convert';
import 'dart:io';
import 'package:fitness_zone_2/UI/auth_module/login/login.dart';
import 'package:fitness_zone_2/UI/auth_module/result_screen.dart';
import 'package:fitness_zone_2/UI/auth_module/sign_up_screen/signup_screen_user.dart';
import 'package:fitness_zone_2/UI/auth_module/walt_through/walk_through_screenn.dart';
import 'package:fitness_zone_2/UI/auth_module/time_preference_screen.dart';
import 'package:fitness_zone_2/UI/dashboard_module/bottom_bar_screen/bottom_bar_screen.dart';
import 'package:fitness_zone_2/UI/free_trail/trial_journey_screen.dart';
import 'package:fitness_zone_2/data/api_provider/chat_api_provider.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/data/models/get_all_dietitian_users/get_all_dietitian_users.dart';
import 'package:fitness_zone_2/data/models/login_response_model/login_response_model.dart';
import 'package:get/get.dart';

import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../helper/get_di.dart';
import '../../../helper/notification_services.dart';
import '../../../values/constants.dart';
import '../../../widgets/toasts.dart';
import '../../GetServices/CheckConnectionService.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../Repos/auth_repo/auth_repo.dart';
import '../../services/timezone_sync_service.dart';
import '../../models/api_response/api_response_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fAuth;
import 'package:google_sign_in/google_sign_in.dart';

import '../../models/get_all_users/get_all_users_based_on_type.dart';

class AuthController extends GetxController implements GetxService {
  SharedPreferences sharedPreferences;
  AuthRepo authRepo;
  NotificationServices notificationServices;
  ChatApiProvider chatApiProvider;
  CheckConnectionService connectionService = CheckConnectionService();
  AuthController(
      {required this.sharedPreferences,
      required this.authRepo,
      required this.notificationServices,
      required this.chatApiProvider});

  ///Generating unique id
  var uuid = const Uuid();
  var showDot = false.obs;
  var isLoggingIn = false.obs;

  ///TextEditing Controller for Adding User
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  ///payment controller
  TextEditingController cardHolderName = TextEditingController();
  TextEditingController cardNumber = TextEditingController();
  TextEditingController expiryDate = TextEditingController();
  TextEditingController cvc = TextEditingController();

  ///Edit controller
  TextEditingController editFirstName = TextEditingController();
  TextEditingController editLastName = TextEditingController();
  TextEditingController editEmail = TextEditingController();
  TextEditingController editAge = TextEditingController();
  TextEditingController editWeight = TextEditingController();
  TextEditingController editHeight = TextEditingController();
  TextEditingController editBmi = TextEditingController();
  var mainGoal = ''.obs;
  var healthConditions = ''.obs;

  ///countryCode
  var countryCode = Constants.countryCode;
  List<String> addTeamMember = [
    "Dietition",
    "Trainer",
    "Gynecologist",
    "Psychiatrist",
    "Customer_Support_Representative",
    "Admin"
  ];

  ///Sign in User
  TextEditingController loginUserPhone = TextEditingController();
  TextEditingController loginUserPassword = TextEditingController();

  ///Update user
  TextEditingController dateExtendController = TextEditingController();

  String daysDurationValue = "";
  String monthDurationValue = "";
  var selectCustomerSupport = 0.obs;

  bool daysSelected = false;
  bool monthSelected = false;
  var getUsersBasedOnUserTypeLoad = false.obs;

  ///User Model
  LoginModel? logInUser;

  var loginAsA = Constants.user.obs;

  /// Local-only "trial activated" flag, flipped by tapping Start 3-day free
  /// trial on the unpaid home. Drives the activated variants of LIVE row,
  /// locked tiles, insight card, and CTA banner. Persisted in prefs so a
  /// cold start keeps the activated state; cleared on logout.
  /// See [Constants.trialActivatedKey].
  late final RxBool trialActivated = RxBool(
      sharedPreferences.getBool(Constants.trialActivatedKey) ?? false);

  /// Flip the local trial flag on. Called by `TrialCtaCard` after the
  /// "Trial activated" dialog is acknowledged.
  void activateTrial() {
    trialActivated.value = true;
    sharedPreferences.setBool(Constants.trialActivatedKey, true);
  }

  /// Reactive mirror of `logInUser?.status`. Plain `LoginModel.status` is a
  /// non-observable bool, so home_screen.dart's `Obx` can't rebuild off it
  /// when payment auto-approval flips the user from unpaid → paid. Read
  /// this inside the home routing Obx so the screen swaps to
  /// `PaidHomeScreenV2` the instant `markPaid()` fires.
  var isPaid = false.obs;

  /// Promote the in-memory user to a paid state after the backend confirms
  /// auto-approval (`userPlanActivated == true` in the slip-upload
  /// response). Also persists `useNewPaidHome=true` so a cold start lands
  /// on the new V2 paid home rather than the legacy `UserHomeScreen`.
  void markPaid() {
    final u = logInUser;
    if (u == null) return;
    u.status = true;
    u.useNewPaidHome = true;
    sharedPreferences.setBool(Constants.useNewPaidHomeKey, true);
    isPaid.value = true;
  }

  List<String> packageState = [
    "Start",
    "Pause",
  ];
  List<String> screenShot = [
    "Yes",
    "No",
  ];
  List<String> recording = [
    "Yes",
    "No",
  ];
  List<String> memberDesignation = [
    "Trainer",
    "Dietitian",
  ];

  ///get All users
  GetDietitianUsers getDietitianUsers = GetDietitianUsers(result: []);
  GetUsersBasedOnUserType? getUsersBasedOnUserTypeModel;

  var memerDesig = "Trainer";

  List<XFile> mealImages = [];
  int i = 0;

  /// getting days function
  int gettingDays() {
    if (daysSelected) {
      return int.parse(daysDurationValue.split(" ").first);
    } else {
      return int.parse(monthDurationValue.split(" ").first) * 30;
    }
  }

  ///Listerner
  ///
  ValueNotifier<List<dynamic>?> sharedPrefNotifier =
      ValueNotifier<List<dynamic>?>(null);

  final fAuth.FirebaseAuth _auth = fAuth.FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);

  ///Clear sign up Controllers
  clearSignUpController() {
    firstNameController.clear();
    lastNameController.clear();
    emailNameController.clear();
    phoneNumberController.clear();
    passwordController.clear();
  }

  @override
  onInit() {
    initNotifications();
    super.onInit();
  }

  addLocalStorage(LoginModel model, String password) {
    sharedPreferences.setString(Constants.accessToken, model.accessToken);
    sharedPreferences.setString(Constants.userId, model.id.toString());
    sharedPreferences.setString(Constants.email, model.email.toString());
    sharedPreferences.setString(Constants.password, password);
    sharedPreferences.setString(Constants.loginAsa, loginAsA.value);

    // Seed the reactive paid-state mirror from the freshly-loaded user.
    // Every login path funnels through here, so this single line keeps
    // [isPaid] in sync with `logInUser.status` on each sign-in.
    isPaid.value = model.status;

    sharedPreferences.setBool(Constants.isGuest, false);
    // Persist Option-C feature flags so the router can honor them on cold
    // start before a fresh login response is available.
    sharedPreferences.setBool(
        Constants.useNewPaidHomeKey, model.useNewPaidHome);
    sharedPreferences.setBool(
        Constants.useNewUnpaidHomeKey, model.useNewUnpaidHome);
    sharedPreferences.setBool(
        Constants.useNewProgressHubKey, model.useNewProgressHub);
    // Phase F.3 — persist the IANA zone so the very-first DietPlanUser
    // load on cold-start uses the right zone instead of falling back
    // to device-local. TimezoneSyncService keeps it fresh post-login.
    sharedPreferences.setString(Constants.userTimeZoneKey, model.timeZone);
    // Kick the sync service. Idempotent — safe to call after every
    // login (Email/Password, Google, Apple, etc.).
    try {
      Get.find<TimezoneSyncService>().start();
    } catch (_) {
      // DI not ready (cold-start race) — service will be wired up the
      // next time addLocalStorage runs.
    }
  }

  /// Phase F.3 — IANA zone the dietitian set on `User.timeZone`. In-memory
  /// `logInUser` is the authoritative source while logged in; the
  /// SharedPreferences fallback covers the cold-start window before
  /// `logInUser` rehydrates from a fresh login.
  String get userTimeZone {
    final inMem = logInUser?.timeZone;
    if (inMem != null && inMem.isNotEmpty) return inMem;
    final cached = sharedPreferences.getString(Constants.userTimeZoneKey);
    if (cached != null && cached.isNotEmpty) return cached;
    return 'Asia/Karachi';
  }

  /// Phase F.3 — called by TimezoneSyncService when the device drifts.
  /// Updates the in-memory model + the cached SharedPreferences value
  /// in lockstep so the rest of the app sees the new zone instantly.
  void setUserTimeZoneLocal(String tzName) {
    if (logInUser != null) logInUser!.timeZone = tzName;
    sharedPreferences.setString(Constants.userTimeZoneKey, tzName);
  }

  login({String? userType, String? email, String? password}) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        isLoggingIn.value = true;
        Get.dialog(const Center(child: CircularProgressIndicator()),
            barrierDismissible: false);
        if (userType != null) {
          loginAsA.value = userType;
        }
        await authRepo
            .loginUserRepo(
          email: email ?? loginUserPhone.text.removeAllWhitespace,
          password: password ?? loginUserPassword.text,
          deviceToken: sharedPreferences.getString(Constants.deviceToken) ?? "",
          userType: loginAsA.value,
        )
            .then((response) async {
          Get.back();
          isLoggingIn.value = false;
          print('AuthController.login ${response}}');
          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
              if (email != null) {
                Get.offAll(() => const WalkThroughScreen());
              }
            } else if (response.body["status"] != "0") {
              ApiResponse<LoginModel> model =
                  ApiResponse.fromJson(response.body, LoginModel.fromJson);
              debugPrint(model.data!.accessToken.toString());
              if (model.status == "1") {
                logInUser = model.data;

                addLocalStorage(logInUser!, password ?? loginUserPassword.text);
                final trialStarted =
                    await Get.find<HomeController>().startTrialFromSavedToken();

                if (loginAsA.value == Constants.trainer) {
                  //  Get.find<HomeController>().getTrainerHomeFunc();
                } else if (loginAsA.value == Constants.dietitian) {
                  //   Get.find<HomeController>().getDietHomeFunc();
                } else if (loginAsA.value == Constants.admin) {
                  // Get.find<HomeController>().getTrialPlanDetails();
                } else if (loginAsA.value == Constants.user) {
                  if (!logInUser!.status) {
                    Get.find<HomeController>().getPlansUser();
                  } else {
                    Get.find<HomeController>().getUserHomeFunc();
                  }
                }

                loginUserPhone.clear();
                loginUserPassword.clear();
                updateUserDetails();
                if (trialStarted && loginAsA.value == Constants.user) {
                  Get.to(() => const TrialJourneyScreen());
                }
              }
            }
          } else {
            isLoggingIn.value = false;
            CustomToast.failToast(msg: response.body["message"]);
          }
        });
      }
    });
  }

  signInUsingGoogle(String userEmail, String name, String signedFrom,
      {String? userType, bool fromLocal = false}) {
    Get.dialog(const Center(child: CircularProgressIndicator()),
        barrierDismissible: false);
    connectionService.checkConnection().then((value) async {
      if (!value) {
        Get.back();

        CustomToast.noInternetToast();
        // Get.back();
      } else {
        authRepo
            .googleSignIn(
          email: userEmail,
          deviceToken: sharedPreferences.getString(Constants.deviceToken) ?? "",
          userType: userType ?? loginAsA.value,
        )
            .then((response) async {
          Get.log("login api response :${response.body}");
          Get.back();
          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
            } else if (response.body["status"] != "0") {
              if (response.body["status"] == "1") {
                ApiResponse<LoginModel> model =
                    ApiResponse.fromJson(response.body, LoginModel.fromJson);
                debugPrint(model.data!.accessToken.toString());
                logInUser = model.data;

                addLocalStorage(logInUser!, signedFrom);
                final trialStarted =
                    await Get.find<HomeController>().startTrialFromSavedToken();

                if (loginAsA.value == Constants.user) {
                  if (!logInUser!.status) {
                    Get.find<HomeController>().getPlansUser();
                  } else {
                    Get.find<HomeController>().getUserHomeFunc();
                  }
                }

                loginUserPhone.clear();
                loginUserPassword.clear();
                updateUserDetails();
                if (trialStarted && loginAsA.value == Constants.user) {
                  Get.to(() => const TrialJourneyScreen());
                }
              } else if (response.body["status"] == "2") {
                print('AuthController.signInUsingGoogle}');
                emailNameController.text = userEmail;
                firstNameController.text = name.split(" ").first;
                lastNameController.text = name.split(" ").last;
                if (fromLocal) {
                  Get.find<AuthController>().loginUserPhone.text = userEmail;
                  Get.offAll(() => Login());
                } else {
                  Get.to(() => SignUpNewUser(
                        isSocial: true,
                      ));
                }
              }
            }
          } else {
            CustomToast.failToast(msg: response.body["message"]);
          }
        });
      }
    });
  }

  getUsersBasedOnUserType(String userType, {bool addNull = false}) {
    getUsersBasedOnUserTypeLoad.value = false;
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        authRepo
            .getSubUserBasedOnUserTypes(
          accessToken: sharedPreferences.getString(Constants.accessToken) ?? "",
          userType: userType,
        )
            .then((response) async {
          // Get.back();
          if (response.body["status"] == "0") {
            CustomToast.failToast(msg: response.body["message"]);
          } else if (response.body["status"] != "0") {
            ApiResponse<GetUsersBasedOnUserType> model = ApiResponse.fromJson(
                response.body, GetUsersBasedOnUserType.fromJson);
            if (model.status == "1") {
              getUsersBasedOnUserTypeModel = model.data!;
              if (addNull) {
                getUsersBasedOnUserTypeModel?.users.insert(
                    0,
                    UserTypeData(
                        id: 0,
                        firstName: "Select",
                        lastName: "..",
                        email: "",
                        phone: ""));
              } else {
                if (getUsersBasedOnUserTypeModel!.users.isNotEmpty) {
                  selectCustomerSupport.value =
                      getUsersBasedOnUserTypeModel!.users[0].id;
                }
              }
              getUsersBasedOnUserTypeLoad.value = true;
            }
          }
        });
      }
    });
  }

  Future<void> showEmailsDialog({bool isFromResortScreen = false}) async {
    // Get.dialog(Center(child: CircularProgressIndicator()),
    //     barrierDismissible: false);
    await connectionService.checkConnection().then((value) async {
      if (!value) {
        // Get.back();

        CustomToast.noInternetToast();
      } else {
        try {
          final GoogleSignInAccount? googleSignInAccount =
              await googleSignIn.signIn();
          if (googleSignInAccount != null) {
            final GoogleSignInAuthentication googleSignInAuthentication =
                await googleSignInAccount.authentication;
            final fAuth.AuthCredential credential =
                fAuth.GoogleAuthProvider.credential(
              accessToken: googleSignInAuthentication.accessToken,
              idToken: googleSignInAuthentication.idToken,
            );

            final fAuth.UserCredential authResult =
                await _auth.signInWithCredential(credential);
            final fAuth.User? user = authResult.user;
            if (user != null) {
              signInUsingGoogle(
                user.email ?? "",
                user.displayName ?? "",
                "google",
              );
            }
          }
        } catch (error) {
          //Get.back();
          print("Error during Google Sign-In: $error");
        }
      }
    });
  }

  void handleappleLogin() async {
    await connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
      } else {
        final appleAuthProvider = fAuth.AppleAuthProvider();
        appleAuthProvider.addScope("email");
        appleAuthProvider.addScope("name");

        var authCredentials = await _auth.signInWithProvider(appleAuthProvider);
        final fAuth.User? user = authCredentials.user;
        print("User :   $user");
        if (user != null) {
          if (Platform.isIOS) {
            if (user.email == null) {
              if (user.providerData.isNotEmpty) {
                signInUsingGoogle(user.providerData[0].email ?? "",
                    user.displayName ?? "", "apple");
              } else {
                signInUsingGoogle(
                    user.email ?? "", user.displayName ?? "", "apple");
              }
            } else {
              signInUsingGoogle(
                  user.email ?? "", user.displayName ?? "", "apple");
            }
          } else {
            signInUsingGoogle(
                user.email ?? "", user.displayName ?? "", "apple");
          }
        } else {
          CustomToast.failToast(msg: "Something went wrong");
        }
      }
    });
  }

  initNotifications() {
    var list = sharedPreferences.getString(Constants.notificationList);
    List<NotificationMessage> notificationMessages = [];

    if (list != null) {
      var list2 = jsonDecode(list);
      notificationMessages = List<NotificationMessage>.from(
        list2.map((item) => NotificationMessage.fromJson(item)),
      );
    }
    sharedPrefNotifier.value = notificationMessages;
    fetchNotifications();
  }

  Future<void> fetchNotifications({bool markRead = false}) async {
    final accessToken = sharedPreferences.getString(Constants.accessToken);
    if (accessToken == null || accessToken.isEmpty) return;

    try {
      final response =
          await authRepo.getNotifications(accessToken: accessToken);
      if (response.statusCode == 200 && response.body["status"] == "1") {
        final raw = response.body["data"]?["notifications"];
        if (raw is List) {
          final notificationMessages = raw
              .map((item) => NotificationMessage.fromServer(
                    Map<String, dynamic>.from(item),
                  ))
              .toList();
          sharedPrefNotifier.value = notificationMessages;
          sharedPreferences.setString(
            Constants.notificationList,
            jsonEncode(
                notificationMessages.map((msg) => msg.toJson()).toList()),
          );
        }
      }

      if (markRead) {
        await authRepo.markNotificationsRead(accessToken: accessToken);
        sharedPreferences.setBool("showDotHome", false);
        Get.find<HomeController>().showDotHome.value = false;
      }
    } catch (e) {
      debugPrint("fetchNotifications failed: $e");
    }
  }

  updateUserDetails({bool updateFields = true}) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(logInUser!.id.toString())
        .set({
      "id": logInUser!.id.toString(),
      "name": logInUser!.firstName,
      "time": Timestamp.now(),
      "remoteId": 0,
      "newMessageArrived": false,
      "days": "",
      "deviceToken": sharedPreferences.getString(Constants.deviceToken)
    });
    // var userMap1 = await FirebaseFirestore.instance
    //     .collection("users")
    //     .doc(logInUser!.adminId.toString())
    //     .get();§§§
    // userMap = userMap1.data()!;
    // String roomId = (logInUser!.id.toString().hashCode +
    //         logInUser!.adminId.toString().hashCode)
    //     .toString();
    editFirstName.text = logInUser?.firstName ?? "";
    editLastName.text = logInUser?.lastName ?? "";
    editEmail.text = logInUser?.email ?? "";

    if (updateFields) {
      editBmi.text = logInUser?.bmiResult ?? "";
      editAge.text = logInUser?.age ?? "";
      editWeight.text = logInUser?.weight ?? "";
      editHeight.text = logInUser?.height ?? "";
      mainGoal.value = logInUser?.mainGoal ?? "";
      healthConditions.value = logInUser?.healthConditions ?? "";
    }
    Get.find<HomeController>().getUserHomeFunc();
    // Show time preference screen once on first login.
    // If already set, go straight to home.
    final hasTimeBlock = sharedPreferences.containsKey(Constants.timeBlock);
    if (!hasTimeBlock) {
      Get.offAll(() => const TimePreferenceScreen());
    } else {
      Get.offAll(() => BottomBarScreen());
    }
  }

  guestLogin(String result) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()),
            barrierDismissible: false);
        await authRepo
            .loginGuestRepo(
          email: emailNameController.text,
          name: firstNameController.text,
          phone: phoneNumberController.text,
          result: result,
        )
            .then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
            } else if (response.body["status"] != "0") {
              if (response.body["status"] == "1") {
                emailNameController.clear();
                phoneNumberController.clear();
                firstNameController.clear();
                Get.offAll(() => ResultScreen(result: result));
              }
            }
          } else {
            CustomToast.failToast(msg: response.body["message"]);
          }
        });
      }
    });
  }

  Future<String?> forgotPassword(String email) async {
    String? otp;
    await connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        otp = null;
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()),
            barrierDismissible: false);
        await authRepo
            .forgotPasswordRepo(
          email: email,
        )
            .then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
              otp = null;
            } else if (response.body["status"] != "0") {
              if (response.body["status"] == "1") {
                otp = response.body["data"]["otp"];
              }
            }
          } else {
            CustomToast.failToast(msg: response.body["message"]);
            otp = null;
          }
        });
      }
    });
    return otp;
  }

  resetPassword(String email, String password) {
    connectionService.checkConnection().then((value) async {
      if (!value) {
        CustomToast.noInternetToast();
        // Get.back();
      } else {
        Get.dialog(const Center(child: CircularProgressIndicator()),
            barrierDismissible: false);
        await authRepo
            .resetPasswordRepo(
          email: email,
          password: password,
        )
            .then((response) async {
          Get.back();

          if (response.statusCode == 200) {
            if (response.body["status"] == "0") {
              CustomToast.failToast(msg: response.body["message"]);
            } else if (response.body["status"] != "0") {
              if (response.body["status"] == "1") {
                Get.offAll(() => Login());
                CustomToast.successToast(msg: response.body["message"]);
              }
            }
          } else {
            CustomToast.failToast(msg: response.body["message"]);
          }
        });
      }
    });
  }

  void removeItem(int index) {
    // Update the list by removing the item at the given index
    if (sharedPrefNotifier.value != null) {
      var list = sharedPreferences.getString(Constants.notificationList);

      // Create a new list if none exists
      List<NotificationMessage> notificationMessages = [];

      // If the list already exists in SharedPreferences
      if (list != null) {
        // Decode the existing list
        var list2 = jsonDecode(list);

        // Convert each item back to NotificationMessage and add to notificationMessages list
        notificationMessages = List<NotificationMessage>.from(
            list2.map((item) => NotificationMessage.fromJson(item)));
      }

      notificationMessages.removeAt(index);
      sharedPrefNotifier.value = notificationMessages;
      sharedPreferences.setString(
          Constants.notificationList, jsonEncode(notificationMessages));
    }
  }

  Future<void> markAllNotificationsRead() async {
    final accessToken = sharedPreferences.getString(Constants.accessToken);
    if (accessToken == null || accessToken.isEmpty) return;

    try {
      await authRepo.markNotificationsRead(accessToken: accessToken);
      sharedPreferences.setBool("showDotHome", false);
      Get.find<HomeController>().showDotHome.value = false;
    } catch (e) {
      debugPrint("markAllNotificationsRead failed: $e");
    }
  }

  logout() async {
    var token = sharedPreferences.getString(Constants.deviceToken);
    if (token != null) {
      connectionService.checkConnection().then((value) async {
        if (!value) {
          CustomToast.noInternetToast();
        } else {
          Get.dialog(const Center(child: CircularProgressIndicator()),
              barrierDismissible: false);
          await authRepo
              .logoutUserRepo(deviceToken: token)
              .then((response) async {
            Get.back();
            if (response.statusCode == 200) {
              if (response.body["status"] == "0") {
                CustomToast.failToast(msg: response.body["message"]);
              } else if (response.body["status"] != "0") {
                if (response.body["status"] == "1") {
                  CustomToast.successToast(msg: response.body["message"]);
                  sharedPreferences.clear();
                  trialActivated.value = false;
                  isPaid.value = false;
                  Get.offAll(() => Login());
                  NotificationServices().getDeviceToken();
                  await init();
                  if (await googleSignIn.isSignedIn()) {
                    googleSignIn.signOut();
                  }
                  loginAsA.value = Constants.user;
                }
              }
            } else {
              CustomToast.failToast(msg: response.body["message"]);
            }
          });
        }
      });
    } else {
      CustomToast.failToast(msg: "Successfully Logout");
      sharedPreferences.clear();
      trialActivated.value = false;
      isPaid.value = false;
      await init();
      loginAsA.value = Constants.user;
      Get.offAll(() => Login());
    }
  }

  deleteUser({String? id}) {
    var token = sharedPreferences.getString(Constants.accessToken);
    if (token != null) {
      connectionService.checkConnection().then((value) async {
        if (!value) {
          CustomToast.noInternetToast();
        } else {
          Get.dialog(const Center(child: CircularProgressIndicator()),
              barrierDismissible: false);
          await authRepo
              .deleteUser(
                  id: id ?? sharedPreferences.getString(Constants.userId) ?? "")
              .then((response) {
            Get.back();
            if (response.statusCode == 200) {
              if (response.body["status"] == "0") {
                CustomToast.failToast(msg: response.body["message"]);
              } else if (response.body["status"] != "0") {
                if (response.body["status"] == "1") {
                  sharedPreferences.clear();
                  trialActivated.value = false;
                  isPaid.value = false;
                  Get.offAll(() => const WalkThroughScreen());
                }
              }
            } else {
              CustomToast.failToast(msg: response.body["message"]);
            }
          });
        }
      });
    } else {
      CustomToast.failToast(msg: "You are not Logged in.");
    }
  }

  var homeDataLoad = false.obs;

  sendMessageNotifications(Map<String, dynamic> body) async {
    await chatApiProvider.postData(body: body);
  }
}
