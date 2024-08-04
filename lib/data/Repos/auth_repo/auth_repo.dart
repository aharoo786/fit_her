import 'package:get/get.dart';

import '../../../values/constants.dart';
import '../../api_provider/api_provider.dart';

class AuthRepo extends GetxService {
  ApiProvider apiProvider;

  AuthRepo({
    required this.apiProvider,
  });

  Future<Response> signUpUserRepo({required Map<String, dynamic> body}) async {
    return await apiProvider.postData(Constants.signupPath, body: body);
  }

  Future<Response> loginUserRepo({
    required String email,
    required String password,
    required String deviceToken,
    required String userType,
  }) async {
    var body = {
      "email": email,
      "password": password,
      "userType": userType,
      "deviceToken": deviceToken,
    };

    return await apiProvider.postData(Constants.loginPath, body: body);
  }

  Future<Response> loginGuestRepo({
    required String email,
    required String name,
    required String phone,
    required String result,
  }) async {
    var body = {
      "email": email,
      "name": name,
      "phone": phone,
      "result": result,
    };

    return await apiProvider.postData(Constants.guestLogin, body: body);
  }

  Future<Response> dietitianLogin({
    required String email,
    required String password,
  }) async {
    var body = {
      "email": email,
      "password": password,
    };

    return await apiProvider.postData(Constants.dietitianLogin, body: body);
  }

  Future<Response> trainerLogin({
    required String email,
    required String password,
  }) async {
    var body = {
      "email": email,
      "password": password,
    };

    return await apiProvider.postData(Constants.trainerLogin, body: body);
  }

  // Future<Response> verifyEmailRepo(
  //     {required String otp,
  //     required String userId,
  //     required String deviceToken}) async {
  //   return await apiProvider.postData(Constants.verifyEmailPath,
  //       body: {"OTP": otp, "userId": userId, "deviceToken": deviceToken});
  // }

  // // TODO: implement This function
  // Future<Response> changePasswordRepo({
  //   required String email,
  //   required String password,
  //   required String otp,
  //   required String forgetRequestId,
  // }) async {
  //   return await apiProvider.postData(Constants.changePasswordPath, body: {
  //     "userId": email,
  //     "password": password,
  //     "OTP": otp,
  //     "forgetRequestId": forgetRequestId
  //   });
  // }

  // Future<Response> forgotPasswordRepo({required String email}) async {
  //   return await apiProvider.postData(Constants.forgotPasswordPath, body: {
  //     "email": email,
  //   });
  // }

  Future<Response> resendOtpRepo(
      {required String email, required String userId}) async {
    return await apiProvider.postData(Constants.resendOtpPath,
        body: {"email": email, "userId": userId});
  }

  Future logout({required String accessToken}) async {
    return await apiProvider
        .postData(Constants.logout, body: {"accessToken": accessToken});
  }
  Future deleteUser({required String id}) async {
    return await apiProvider
        .postData(Constants.deleteUser, body: {"userId": id});
  }

  // checkSessionRepo({required String accessToken, required bool isGuest}) async {
  //   return await apiProvider.postData(Constants.sessionPath,
  //       headers: {"accessToken": accessToken}, body: {"guestUser": isGuest});
  // }

  resendForgetOtpRepo({required String email}) async {
    return await apiProvider
        .postData(Constants.resendOtpPath, body: {"email": email});
  }

  buyDescription(
      {required Map<String, dynamic> body, required String accessToken}) async {
    return await apiProvider.postData(Constants.stripePayment,
        body: body, headers: {"accessToken": accessToken});
  }

  getHomeData({required String accessToken}) async {
    return await apiProvider
        .getData(Constants.home, headers: {"accessToken": accessToken});
  }

  getDietitianUsers({required String accessToken}) async {
    return await apiProvider.postData(Constants.getDietitianUsers,
        headers: {"accessToken": accessToken}, body: {});
  }

  getUserPlan({required String accessToken}) async {
    return await apiProvider.postData(Constants.getUserPlan,
        headers: {"accessToken": accessToken}, body: {});
  }
}
