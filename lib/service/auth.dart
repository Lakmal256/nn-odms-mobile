import 'dart:io';

import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:odms/router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;
import 'dart:convert';

import '../util/storage.dart';
import 'service.dart';

class TokenProvider {
  AuthService service;
  String? _refreshToken;
  String? _accessToken;
  String? _identityId;
  DateTime? _accessTokenExpirationDateTime;

  TokenProvider({required this.service,String? refreshToken, String? accessToken, String? identityId})
      : _refreshToken = refreshToken,
        _identityId = identityId,
        _accessToken = accessToken;

  LocalTokenHandler localTokenHandler = LocalTokenHandler();

  saveSession() async {
    await localTokenHandler.saveRefreshToken(_refreshToken!);
  }

  clearSession() async {
    await localTokenHandler.eraseTokens();
  }

  Future<TokenResponse?> login() async {
    final response = await service.authorize();
    _accessToken = response?.token;
    _identityId = response?.identityId;
    _refreshToken = response?.refreshToken;
    _accessTokenExpirationDateTime = JwtDecoder.getExpirationDate(_accessToken!);
    return response;
  }

  Future<TokenResponse?> adLogin() async {
    final response = await service.adAuthorize();
    _accessToken = response?.token;
    _identityId = response?.identityId;
    _refreshToken = response?.refreshToken;
    _accessTokenExpirationDateTime = JwtDecoder.getExpirationDate(_accessToken!);
    return response;
  }

  Future<String> getToken(String refreshToken) async {
    _refreshToken = refreshToken.isNotEmpty ? refreshToken : _refreshToken;
    tryRefresh() async {
      final response = await service.refresh(_refreshToken!);
      _accessToken = response?.token;
      _identityId = response?.identityId;
      _refreshToken = response?.refreshToken;
      _accessTokenExpirationDateTime = JwtDecoder.getExpirationDate(_accessToken!);
    }

    if (_accessToken == null || isExpired()) {
      if (_refreshToken != null) {
        await tryRefresh();
      } else {
        GoRouter.of(navigatorKey.currentContext!).go("/login/credentials");
      }
    }

    if (isExpired()) {
      await tryRefresh();
    }

    return _accessToken!;
  }

  Future endSession() async {
    _accessToken = null;
    _refreshToken = null;
  }

  bool isExpired() {
    return _accessTokenExpirationDateTime != null && _accessTokenExpirationDateTime!.isBefore(DateTime.now());
  }

  bool get hasSession => _accessToken != null && !isExpired();
  String? get identityId => _identityId;
}

class LocalTokenHandler {
  Storage storage = Storage();

  Future<String?> readRefreshToken() async {
    String? rawTokenData = await storage.readValue("tokens");
    if (rawTokenData != null) {
      Map<String, dynamic> jsonData = convert.jsonDecode(rawTokenData);
      return jsonData['refreshToken'];
    }
    return null;
  }

  Future eraseTokens() async {
    await storage.eraseValue("tokens");
  }

  Future saveRefreshToken(String token) async {
    await storage.saveValue("tokens", convert.jsonEncode({"refreshToken": token}));
  }
}

class TokenUser {
  bool changePasswordNextLogin;

  TokenUser({required this.changePasswordNextLogin});

  TokenUser.fromJson(Map<String, dynamic> value) : changePasswordNextLogin = value["changePasswordNextLogin"];
}

class TokenResponse {
  String token;
  String refreshToken;
  String? identityId;
  TokenUser? user;
  UserResponseDto? currentUser;
  String? message;

  TokenResponse({
    required this.token,
    required this.refreshToken,
    this.identityId,
    this.user,
    this.currentUser,
    this.message,
  });

  TokenResponse.fromJson(Map<String, dynamic> value)
      : identityId = value["loggedUser"] != null ? value["loggedUser"]["identityId"] : null,
        token = value["accessToken"],
        refreshToken = value["refreshToken"],
        user = value["loggedUser"] != null ? TokenUser.fromJson(value["loggedUser"]) : null,
        currentUser = value["loggedUser"] != null ? UserResponseDto.fromJson(value["loggedUser"]) : null,
        message = value["message"];
}

abstract class AuthService {
  Future<TokenResponse?> authorize();
  Future<TokenResponse?> adAuthorize();
  Future<TokenResponse?> refresh(String refreshToken);
  Future endSession();
}

class StdLoginCredentials {
  String userName;
  String password;

  StdLoginCredentials({
    required this.userName,
    required this.password,
  });
}

class ADStdLoginDetails {
  String adToken;
  String adTenantId;
  String email;

  ADStdLoginDetails({
    required this.adToken,
    required this.adTenantId,
    required this.email,
  });
}
/// Retrieve tokens by providing user name & password
class StandardAuthService implements AuthService {
  String authority;
  String apimDomain;
  String swaggerDomain;
  late TokenProvider tokenProvider;
  late StdLoginCredentials credentials;
  late ADStdLoginDetails adDetails;

  StandardAuthService({required this.authority, required this.apimDomain, required this.swaggerDomain}) {
    tokenProvider = TokenProvider(service: this);
  }

  Future<String> getCSRFToken() async {
    final uri = Uri.parse('https://prep-systemcore.inseepro.lk/csrf');
    final response = await http.post(
      uri,
      headers: {
        'accept': 'application/json',
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      return response.body;
    } else {
      throw Exception('Failed to get CSRF token');
    }
  }

  @override
  Future<TokenResponse?> authorize() async {
    final String csrfToken = await getCSRFToken();
    final response = await http.post(
      Uri.https('prep-systemcore.inseepro.lk', "/identity/user/login"),
      headers: {'Content-Type': 'application/json',
        'X-Csrf-Token':csrfToken},
      body: convert.jsonEncode({
        "username": credentials.userName.toLowerCase(),
        "password": credentials.password,
      }),
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = convert.jsonDecode(response.body);
      TokenResponse tokenResponse = TokenResponse.fromJson(decodedJson);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', tokenResponse.token);
      await prefs.setString('refreshToken', tokenResponse.refreshToken);
      return TokenResponse.fromJson(decodedJson);
    } else if (response.statusCode == HttpStatus.unauthorized) {
      final decodedJson = json.decode(response.body);
      final errorMessage = decodedJson['message'] ?? 'Unauthorized';
      throw UnauthorizedException(errorMessage);
    } else if (response.statusCode == HttpStatus.locked) {
      throw BlockedUserException();
    } else if (response.statusCode == HttpStatus.notFound) {
      throw UserNotFoundException();
    }

    throw Exception();
  }

  @override
  Future<TokenResponse?> adAuthorize() async {
    String email0 = adDetails.email.toLowerCase();
    String encodedEmail = Uri.encodeComponent(email0);
    String path = "/${apimDomain}systemcore/v1.0.0/identity/user/$encodedEmail/ad/login";
    final response = await http.post(
      Uri.parse("https://$authority$path?mobile=yes"),
      headers: {
        'adTenantid': adDetails.adTenantId,
        'adToken': adDetails.adToken,
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return TokenResponse.fromJson(decodedJson);
    } else if (response.statusCode == HttpStatus.unauthorized) {
      final decodedJson = json.decode(response.body);
      final errorMessage = decodedJson['message'] ?? 'Unauthorized';
      throw UnauthorizedException(errorMessage);
    } else if (response.statusCode == HttpStatus.locked) {
      throw BlockedUserException();
    } else if (response.statusCode == HttpStatus.notFound) {
      throw UserNotFoundException();
    }

    throw Exception();
  }

  @override
  Future endSession() {
    throw UnimplementedError();
  }

  @override
  Future<TokenResponse?> refresh(String refreshToken) async {
    Storage storage = Storage();
    String? email = await storage.readValue("email");
    String? internalValue = await storage.readValue("internal");
    bool? internal = internalValue == "true" ? true : false;
    final response = await http.post(
      Uri.https(authority,"/${apimDomain}systemcore/v1.0.0/identity/user/login/refresh"),
      headers: {
        'Content-Type': 'application/json',
      },
      body: convert.jsonEncode({
        "username": email,
        "refreshToken": refreshToken,
        "internal": internal,
      }),
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = convert.jsonDecode(response.body);
      TokenResponse tokenResponse = TokenResponse.fromJson(decodedJson);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', tokenResponse.token);
      await prefs.setString('refreshToken', tokenResponse.refreshToken);
      return TokenResponse.fromJson(decodedJson);
    } else {
      GoRouter.of(navigatorKey.currentContext!).go("/login/credentials");
    }
    return null;
  }
}
