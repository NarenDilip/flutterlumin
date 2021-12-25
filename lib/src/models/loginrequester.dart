class LoginRequester {
  String username;
  String password;
  String token;
  String refreshtoken;
  int responseCode;
  String email;

  LoginRequester(
      {required this.username,
      required this.password,
      required this.token,
      required this.refreshtoken,
      required this.email,
      required this.responseCode});

  static LoginRequester fromJson(dynamic json) {
    return LoginRequester(
        username: json["username"],
        password: json["password"],
        token: json["token"],
        refreshtoken: json["refreshtoken"],
        email: json["user_email"],
        responseCode: json["responseCode"]);
  }
}
