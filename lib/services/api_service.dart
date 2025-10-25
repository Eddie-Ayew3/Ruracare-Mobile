import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod/riverpod.dart';
import 'models.dart';

part 'api_service.g.dart';

class ApiService {
  static const String baseUrl = 'https://api.onemillionsteps.ruracaregh.org/api/v1';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _tokenKey = 'authToken';
  static const String _userKey = 'user';

  // =======================
  // Secure Storage Methods
  // =======================
  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<void> saveUser(User user) async {
    await _secureStorage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  Future<User?> getStoredUser() async {
    final userJson = await _secureStorage.read(key: _userKey);
    if (userJson != null) {
      final map = jsonDecode(userJson);
      return User.fromJson(map);
    }
    return null;
  }

  Future<void> clearAuthData() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userKey);
  }

  // =======================
  // Helper Methods
  // =======================
  Map<String, String> getAuthHeaders([String? contentType]) {
    final headers = {
      'Accept': 'application/json',
      if (contentType != null) 'Content-Type': contentType,
    };
    return headers;
  }

  Future<Map<String, String>> getAuthHeadersWithToken([String? contentType]) async {
    final token = await getAuthToken();
    final headers = {
      'Accept': 'application/json',
      if (contentType != null) 'Content-Type': contentType,
      if (token != null) 'Authorization': 'Bearer $token',
    };
    return headers;
  }

  String? getUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      final payload = parts[1];
      final normalized = payload.length % 4 == 0 
          ? payload 
          : payload + '=' * (4 - payload.length % 4);
      
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = jsonDecode(decoded);
      
      return payloadMap['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ?? 
             payloadMap['id'];
    } catch (e) {
      debugPrint('Error decoding JWT: $e');
      return null;
    }
  }

  Future<bool> isAuthenticated() {
    return getAuthToken().then((token) => token != null).catchError((_) => false);
  }

  // =======================
  // API Request Helper
  // =======================
  Future<T> apiRequest<T>(
    String endpoint, {
    String method = 'GET',
    dynamic body,
    String? contentType,
    bool requiresAuth = true,
  }) async {
    try {
      final url = '$baseUrl$endpoint';
      final headers = requiresAuth 
          ? await getAuthHeadersWithToken(contentType)
          : getAuthHeaders(contentType);

      // Don't set Content-Type for FormData
      if (body is http.MultipartRequest) {
        body.headers.addAll(headers);
        final streamedResponse = await body.send();
        final response = await http.Response.fromStream(streamedResponse);
        final responseText = response.body;
        dynamic data;
        
        try {
          data = responseText.isNotEmpty ? jsonDecode(responseText) : {};
        } catch (e) {
          throw Exception('Invalid JSON response from server');
        }

        if (!response.statusCode.toString().startsWith('2')) {
          final errorMessage = data['message'] ?? 'HTTP error! status: ${response.statusCode}';
          throw Exception(errorMessage);
        }

        if (data['status'] >= 400) {
          final errorMessage = data['message'] ?? 'API request failed';
          throw Exception(errorMessage);
        }

        return data;
      } else {
        final uri = Uri.parse(url);
        final bodyContent = body is String ? body : (body != null ? jsonEncode(body) : null);
        
        http.Response response;
        switch (method.toUpperCase()) {
          case 'GET':
            response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 30));
            break;
          case 'POST':
            response = await http.post(
              uri,
              headers: headers,
              body: bodyContent,
            ).timeout(const Duration(seconds: 30));
            break;
          case 'PUT':
            response = await http.put(
              uri,
              headers: headers,
              body: bodyContent,
            ).timeout(const Duration(seconds: 30));
            break;
          case 'DELETE':
            response = await http.delete(
              uri,
              headers: headers,
              body: bodyContent,
            ).timeout(const Duration(seconds: 30));
            break;
          case 'PATCH':
            response = await http.patch(
              uri,
              headers: headers,
              body: bodyContent,
            ).timeout(const Duration(seconds: 30));
            break;
          default:
            throw Exception('Unsupported HTTP method: $method');
        }

        final responseText = response.body;
        dynamic data;
        
        try {
          data = responseText.isNotEmpty ? jsonDecode(responseText) : {};
        } catch (e) {
          throw Exception('Invalid JSON response from server');
        }

        if (!response.statusCode.toString().startsWith('2')) {
          final errorMessage = data['message'] ?? 'HTTP error! status: ${response.statusCode}';
          throw Exception(errorMessage);
        }

        if (data['status'] >= 400) {
          final errorMessage = data['message'] ?? 'API request failed';
          throw Exception(errorMessage);
        }

        return data;
      }
    } on TimeoutException {
      throw Exception('Request timeout. Please try again.');
    } on http.ClientException {
      throw Exception('Network error. Please check your connection.');
    } catch (e) {
      rethrow;
    }
  }

  // =======================
  // Authentication
  // =======================
  Future<LoginResponse> signIn(SignInCredentials credentials) async {
    final response = await apiRequest<Map<String, dynamic>>(
      '/Account/Login',
      method: 'POST',
      body: credentials.toJson(),
      contentType: 'application/json-patch+json',
      requiresAuth: false,
    );

    final loginResponse = LoginResponse.fromJson(response);
    
    if (loginResponse.data.accesstoken.token.isNotEmpty) {
      await saveAuthToken(loginResponse.data.accesstoken.token);
      await saveUser(loginResponse.data.user);
    }

    return loginResponse;
  }

  Future<User> signUp(SignUpCredentials credentials) async {
    await apiRequest<dynamic>(
      '/Account/CreateAccount',
      method: 'POST',
      body: {
        'fullName': credentials.name,
        'email': credentials.email,
        'phoneNumber': credentials.mobile,
        'password': credentials.password,
      },
      contentType: 'application/json-patch+json',
      requiresAuth: false,
    );

    return signIn(SignInCredentials(
      email: credentials.email,
      password: credentials.password,
    )).then((response) => response.data.user);
  }

  Future<void> signOut() async {
    await clearAuthData();
  }

  // =======================
  // User Management
  // =======================
  Future<User> updateUserProfile(UpdateUserRequest userData) async {
    final body = {
      ...userData.toJson(),
      'password': userData.password ?? '',
    };
    
    return await apiRequest<Map<String, dynamic>>(
      '/Account/UpdateUser',
      method: 'POST',
      body: body,
    ).then((data) => User.fromJson(data['data'] ?? data));
  }

  Future<AppResult> updateProfilePhoto(FileResponse fileResponse) async {
    return await apiRequest<Map<String, dynamic>>(
      '/Account/UpdateProfilePhoto',
      method: 'PUT',
      body: fileResponse.toJson(),
    ).then((data) => AppResult.fromJson(data));
  }

  Future<FileUploadResponse> uploadFile(List<int> fileBytes, String fileName) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/File/UploadFile'),
    );
    
    final token = await getAuthToken();
    request.headers['Authorization'] = 'Bearer $token';
    
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: fileName,
    ));

    return apiRequest<Map<String, dynamic>>(
      '/File/UploadFile',
      method: 'POST',
      body: request,
    ).then((data) => FileUploadResponse.fromJson(data));
  }

  // =======================
  // Targets
  // =======================
  Future<dynamic> getUserTargets({int pageNumber = 1, int pageSize = 10}) async {
    final token = await getAuthToken();
    if (token == null) throw Exception('Not authenticated');
    
    final userId = getUserIdFromToken(token);
    if (userId == null) throw Exception('User ID not found');

    final response = await apiRequest<Map<String, dynamic>>(
      '/UserTarget/GetAll?PageNumber=$pageNumber&PageSize=$pageSize&UserId=${Uri.encodeComponent(userId)}',
      method: 'GET',
    );

    if (response.isEmpty || (response['stepTarget'] == 0 && response['donationTarget'] == 0)) {
      return null;
    }

    return response;
  }

  Future<Map<String, dynamic>> setUserTargets(UserTargetsRequest targets) async {
    final response = await http.post(
      Uri.parse('$baseUrl/UserTarget'),
      headers: await getAuthHeadersWithToken('application/json'),
      body: jsonEncode(targets.toJson()),
    );

    final data = jsonDecode(response.body);
    return {
      'status': response.statusCode,
      'data': data,
      'message': data['message'] ?? '',
    };
  }

  Future<User> updateUserTargets(UpdateUserTargetsRequest targets) async {
    return await apiRequest<Map<String, dynamic>>(
      '/user/targets',
      method: 'PATCH',
      body: targets.toJson(),
    ).then((data) => User.fromJson(data['data'] ?? data));
  }

  // =======================
  // Team Management
  // =======================
  Future<TeamDetailed> createTeam(CreateTeamRequest teamData) async {
    final response = await apiRequest<Map<String, dynamic>>(
      '/Team',
      method: 'POST',
      body: teamData.toJson(),
      contentType: 'application/json',
    );
    
    // First, create the team
    final team = Team.fromJson(response);
    
    // Then, fetch the detailed team information
    final detailedTeam = await getTeam(team.id);
    return detailedTeam;
  }

  Future<TeamDetailed> getTeam(String teamId) async {
    final response = await apiRequest<Map<String, dynamic>>(
      '/Team/$teamId',
      method: 'GET',
    );
    return TeamDetailed.fromJson(response);
  }

  Future<List<Team>> getTeams() async {
    return await apiRequest<Map<String, dynamic>>(
      '/Team',
      method: 'GET',
    ).then((data) => (data['data'] as List?)?.map((e) => Team.fromJson(e)).toList() ?? []);
  }

  Future<UserTeamsDetailed> getUserTeamsDetailed() async {
    final response = await apiRequest<Map<String, dynamic>>(
      '/Team/GetMyTeams',
      method: 'GET',
    );

    final createdTeams = (response['data']?['myTeams'] as List? ?? [])
        .map((e) => TeamDetailed.fromJson(e)).toList();
    final joinedTeams = (response['data']?['joinedTeams'] as List? ?? [])
        .map((e) => TeamDetailed.fromJson(e)).toList();

    final allTeamsMap = <String, TeamDetailed>{};
    for (final team in [...createdTeams, ...joinedTeams]) {
      allTeamsMap[team.id] = team;
    }

    return UserTeamsDetailed(
      createdTeams: createdTeams,
      joinedTeams: joinedTeams,
      allTeams: allTeamsMap.values.toList(),
    );
  }

  Future<List<Team>> getJoinedTeams(String teamId) async {
    final response = await apiRequest<Map<String, dynamic>>(
      '/Team/GetTeam/${Uri.encodeComponent(teamId)}',
      method: 'GET',
    );
    
    return (response['data'] as List?)?.map((e) => Team.fromJson(e)).toList() ?? [];
  }

  Future<List<Team>> getMembers(String teamId) async {
    try {
      final response = await apiRequest<Map<String, dynamic>>(
        '/Team/GetTeamMembers?PageNumber=1&PageSize=10&TeamId=${Uri.encodeComponent(teamId)}',
        method: 'GET',
      );
      
      return (response['data'] as List?)?.map((e) => Team.fromJson(e)).toList() ?? [];
    } catch (e) {
      debugPrint('Error fetching team members: $e');
      return [];
    }
  }

  Future<void> deleteTeam(String teamId) async {
    await apiRequest<dynamic>(
      '/Team/$teamId',
      method: 'DELETE',
    );
  }

  Future<Map<String, dynamic>> addToTeam(String teamId, [String? userId]) async {
    try {
      final token = await getAuthToken();
      if (token == null) throw Exception('User authentication required');
      
      final finalUserId = userId ?? getUserIdFromToken(token);
      if (finalUserId == null) throw Exception('User authentication required');

      final response = await apiRequest<Map<String, dynamic>>(
        '/Team/AddToTeam',
        method: 'POST',
        body: {
          'teamId': teamId,
          'userId': finalUserId,
        },
      );

      return {
        'success': true,
        'message': response['message'] ?? 'Successfully joined the team',
      };
    } catch (e) {
      rethrow;
    }
  }

  // =======================
  // Donations
  // =======================
  Future<DonationResponse> teamDonation(TeamDonationRequest donationData) async {
    return await apiRequest<Map<String, dynamic>>(
      '/Donations/TeamDonation',
      method: 'POST',
      body: donationData.toJson(),
    ).then((data) => DonationResponse.fromJson(data));
  }

  Future<DonationResponse> individualDonation(IndividualDonationRequest donationData) async {
    return await apiRequest<Map<String, dynamic>>(
      '/Donations/IndividualDonation',
      method: 'POST',
      body: donationData.toJson(),
    ).then((data) => DonationResponse.fromJson(data));
  }

  Future<DonationVerificationResponse> verifyDonation(String transactionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Donations/VerifyIndividualDonation/${Uri.encodeComponent(transactionId)}'),
        headers: await getAuthHeadersWithToken(),
      );

      final data = jsonDecode(response.body);
      
      if (!response.statusCode.toString().startsWith('2')) {
        throw Exception(data['message'] ?? 'Verification failed: ${response.statusCode}');
      }

      if (data['status'] != 200) {
        throw Exception('Invalid verification response from server');
      }

      return DonationVerificationResponse.fromJson(data);
    } catch (e) {
      return DonationVerificationResponse(
        message: e.toString(),
        status: 500,
        data: null,
      );
    }
  }

  Future<DonationVerificationResponse> verifyTeamDonation(String transactionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Donations/VerifyTeamDonation/${Uri.encodeComponent(transactionId)}'),
        headers: await getAuthHeadersWithToken(),
      );

      final data = jsonDecode(response.body);
      
      if (!response.statusCode.toString().startsWith('2')) {
        throw Exception(data['message'] ?? 'Verification failed: ${response.statusCode}');
      }

      if (data['status'] != 200) {
        throw Exception(data['message'] ?? 'Invalid verification response from server');
      }

      return DonationVerificationResponse.fromJson(data);
    } catch (e) {
      return DonationVerificationResponse(
        message: e.toString(),
        status: 500,
        data: null,
      );
    }
  }

  Future<DonationsResponse> getDonations({int pageNumber = 1, int pageSize = 5}) async {
    try {
      final token = await getAuthToken();
      if (token == null) throw Exception('Not authenticated');
      
      final userId = getUserIdFromToken(token);
      if (userId == null) throw Exception('User ID not found');

      final response = await http.get(
        Uri.parse('$baseUrl/Donations/GetMyDonations?PageNumber=$pageNumber&PageSize=$pageSize&UserId=${Uri.encodeComponent(userId)}'),
        headers: await getAuthHeadersWithToken(),
      );

      if (response.statusCode == 204) {
        return DonationsResponse(
          pageNumber: pageNumber,
          pageSize: pageSize,
          totalPages: 0,
          totalRecords: 0,
          message: 'No donations found',
          status: 204,
          data: [],
        );
      }

      final data = jsonDecode(response.body);
      
      return DonationsResponse.fromJson(data);
    } catch (e) {
      return DonationsResponse(
        pageNumber: 1,
        pageSize: 5,
        totalPages: 0,
        totalRecords: 0,
        message: e.toString(),
        status: 500,
        data: [],
      );
    }
  }

  Future<DonationsResponse> getTeamDonations({
    int pageNumber = 1,
    int pageSize = 5,
    required String userId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Donations/GetTeamDonations?PageNumber=$pageNumber&PageSize=$pageSize&UserId=${Uri.encodeComponent(userId)}'),
        headers: await getAuthHeadersWithToken(),
      );

      if (response.statusCode == 204) {
        return DonationsResponse(
          pageNumber: pageNumber,
          pageSize: pageSize,
          totalPages: 0,
          totalRecords: 0,
          message: 'No donations found',
          status: 204,
          data: [],
        );
      }

      final data = jsonDecode(response.body);
      return DonationsResponse.fromJson(data);
    } catch (e) {
      return DonationsResponse(
        pageNumber: pageNumber,
        pageSize: pageSize,
        totalPages: 0,
        totalRecords: 0,
        message: e.toString(),
        status: 500,
        data: [],
      );
    }
  }
}

// =======================
// Riverpod Providers
// =======================
@riverpod
ApiService apiService(Ref ref) => ApiService();

@riverpod
Future<User?> currentUser(Ref ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getStoredUser();
}

@riverpod
Future<bool> isAuthenticated(Ref ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.isAuthenticated();
}

@riverpod
Future<List<Team>> userTeams(Ref ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getTeams();
}

@riverpod
Future<UserTeamsDetailed> userTeamsDetailed(Ref ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getUserTeamsDetailed();
}

@riverpod
Future<DonationsResponse> userDonations(
  Ref ref, {
  int pageNumber = 1,
  int pageSize = 5,
}) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getDonations(pageNumber: pageNumber, pageSize: pageSize);
}

@riverpod
Future<dynamic> userTargets(
  Ref ref, {
  int pageNumber = 1,
  int pageSize = 5,
}) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getUserTargets(pageNumber: pageNumber, pageSize: pageSize);
}