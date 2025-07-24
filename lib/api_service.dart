import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://taxfilinguk.profitpicks.in/api';

  Future<http.Response> sendOtp({
    required String otp,
    required String email,
  }) async {
    var uri = Uri.parse('$baseUrl/send-otp');
    var request =
        http.MultipartRequest('POST', uri)
          ..fields['otp'] = otp
          ..fields['email'] = email;
    request.headers['Accept'] = 'application/ecmascript';
    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> register({
    required String name,
    required String email,
    required String password,
  }) async {
    var uri = Uri.parse('$baseUrl/register');
    var request =
        http.MultipartRequest('POST', uri)
          ..fields['name'] = name
          ..fields['email'] = email
          ..fields['password'] = password;
    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> login({
    required String email,
    required String password,
  }) async {
    var uri = Uri.parse('$baseUrl/login');
    var request =
        http.MultipartRequest('POST', uri)
          ..fields['email'] = email
          ..fields['password'] = password;
    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
}
