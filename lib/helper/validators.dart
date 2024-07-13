

class Validators {
  /// password validation
  static String? passwordValidator(
    String value,
  ) {
    if (value.isEmpty) {
      return 'Enter Password';
    } else if (value.length < 6) {
      return 'Password must be 6 charters long';
    }
    return null;
  }

  ///email validation
  static String? emailValidator(
    String value,
  ) {
    if (value.isEmpty) {
      return 'Enter  Email';
    } else if (!value.contains("@")) {
      return 'Enter the Valid Email';
    } else {
      return null;
    }
  }

  ///phone validation

  static String? phoneNumber(
    String value,
  ) {
    if (value.isEmpty) {
      return 'Enter Phone Number';
    }
    // if (value.length < Get.find<AuthController>().maxPhoneLength.value + 2) {
    //   return 'Enter valid Number';
    // }
    return null;
  }

  ///first name validation

  static String? firstNameValidation(
    String value,
  ) {
    if (value.isEmpty) {
      return 'Enter the first Name';
    } else if (value.length < 3) {
      return 'Enter a valid Name';
    }
    return null;
  }

  /// last name validation
  static String? lastNameValidation(
    String value,
  ) {
    if (value.isEmpty) {
      return 'Enter the first Name';
    } else if (value.length < 3) {
      return 'Enter a valid Name';
    }
    return null;
  }

  /// salone name validation
  String? salonName(
    String value,
  ) {
    if (value.isEmpty) {
      return 'Enter the salon name';
    }
    return null;
  }

  ///bio salon validation
  ///

  String? salonBio(
    String value,
  ) {
    if (value.isEmpty) {
      return 'Enter the detail of bio';
    }
    return null;
  }

  /// bank validation  bank name
  String? bankName(
    String value,
  ) {
    if (value.isEmpty) {
      return 'Enter the Bank Name';
    }
    return null;
  }

  /// bank tittle
  String? bankTitle(
    String value,
  ) {
    if (value.isEmpty) {
      return 'Enter the Bank title';
    }
    return null;
  }

  /// iban number
  String? IbanNumber(
    String value,
  ) {
    if (value.isEmpty) {
      return 'Enter IBAN Number';
    }
    return null;
  }

  ///booking per slot

  String? bookingSlot(
    String value,
  ) {
    if (value.isEmpty) {
      return 'Enter booking per slot';
    }
    return null;
  }

  ///service price
  String? servicePrice(
    String value,
  ) {
    if (value.isEmpty) {
      return 'Enter service price';
    }
    return null;
  }

  ///otp
  String? otpValue(
    String value,
  ) {
    if (value.isEmpty) {
      return 'Enter otp';
    }
    return null;
  }

  ///otp
  String? expiry(
    String value,
  ) {
    if (value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }

  ///otp
  String? speciality(
    String value,
  ) {
    if (value.isEmpty) {
      return 'Enter speciality';
    }
    return null;
  }

  ///card number
  String? cardNo(
    String value,
  ) {
    if (value.isEmpty && value.length < 16) {
      return 'Please enter your correct card no';
    }
    return null;
  }

  ///cvv
  String? cvv(
    String value,
  ) {
    if (value.isEmpty && value.length < 3) {
      return 'Enter correct cvv';
    }
    return null;
  }

  static otpValidator(String value) {
    if (value.isEmpty) {
      return "Enter valid OTP";
    } else if (value.length < 4) {
      return "Enter Valid OTP";
    }
  }

  /// send parcel volume validation
}
