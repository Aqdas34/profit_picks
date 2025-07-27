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

  Future<http.Response> uploadDocument({
    required int userId,
    required String taxYear,
    required String accountingPeriod,
    required String name,
    List<http.MultipartFile>? identityDocuments,
    List<http.MultipartFile>? bankStatements,
    List<http.MultipartFile>? incomeRecords,
    List<http.MultipartFile>? expenseReceipts,
    List<http.MultipartFile>? additionalDocuments,
  }) async {
    var uri = Uri.parse('$baseUrl/upload-document');
    var request =
        http.MultipartRequest('POST', uri)
          ..fields['user_id'] = userId.toString()
          ..fields['tax_year'] = taxYear
          ..fields['accountingPeriod'] = accountingPeriod
          ..fields['name'] = name;
    if (identityDocuments != null) {
      request.files.addAll(identityDocuments);
    }
    if (bankStatements != null) {
      request.files.addAll(bankStatements);
    }
    if (incomeRecords != null) {
      request.files.addAll(incomeRecords);
    }
    if (expenseReceipts != null) {
      request.files.addAll(expenseReceipts);
    }
    if (additionalDocuments != null) {
      request.files.addAll(additionalDocuments);
    }
    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
}
