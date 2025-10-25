
// =======================
// Base Models
// =======================
class FileResponse {
  final String id;
  final String? previewId;
  final String filePath;

  FileResponse({
    required this.id,
    this.previewId,
    required this.filePath,
  });

  factory FileResponse.fromJson(Map<String, dynamic> json) => FileResponse(
        id: json['id'],
        previewId: json['previewId'],
        filePath: json['filePath'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'previewId': previewId,
        'filePath': filePath,
      };
}

class AppResult {
  final int status;
  final String message;
  final dynamic data;

  AppResult({
    required this.status,
    required this.message,
    this.data,
  });

  factory AppResult.fromJson(Map<String, dynamic> json) => AppResult(
        status: json['status'],
        message: json['message'],
        data: json['data'],
      );

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': data,
      };
}

class FileUploadResponse {
  final String? message;
  final int status;
  final List<FileResponse> data;

  FileUploadResponse({
    this.message,
    required this.status,
    required this.data,
  });

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) => FileUploadResponse(
        message: json['message'],
        status: json['status'],
        data: (json['data'] as List).map((e) => FileResponse.fromJson(e)).toList(),
      );

  Map<String, dynamic> toJson() => {
        'message': message,
        'status': status,
        'data': data.map((e) => e.toJson()).toList(),
      };
}

// =======================
// User Models
// =======================
class User {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final bool phoneNumberConfirmed;
  final String? gender;
  final String? referralCode;
  final int? steps;
  final double? donationTotal;
  final String? device;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.phoneNumberConfirmed,
    this.gender,
    this.referralCode,
    this.steps,
    this.donationTotal,
    this.device,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] ?? '',
        fullName: json['fullName'] ?? '',
        email: json['email'] ?? '',
        phoneNumber: json['phoneNumber'] ?? '',
        phoneNumberConfirmed: json['phoneNumberConfirmed'] ?? false,
        gender: json['gender'],
        referralCode: json['referralCode'],
        steps: json['steps'],
        donationTotal: json['donationTotal']?.toDouble(),
        device: json['device'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'phoneNumberConfirmed': phoneNumberConfirmed,
        'gender': gender,
        'referralCode': referralCode,
        'steps': steps,
        'donationTotal': donationTotal,
        'device': device,
      };
}

class UpdateUserRequest {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? password;

  UpdateUserRequest({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.password,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password ?? '',
      };
}

class UpdateUserTargetsRequest {
  final int stepTarget;
  final int donationTarget;

  UpdateUserTargetsRequest({
    required this.stepTarget,
    required this.donationTarget,
  });

  Map<String, dynamic> toJson() => {
        'stepTarget': stepTarget,
        'donationTarget': donationTarget,
      };
}

// =======================
// Authentication Models
// =======================
class SignInCredentials {
  final String email;
  final String password;

  SignInCredentials({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class SignUpCredentials {
  final String name;
  final String email;
  final String password;
  final String mobile;

  SignUpCredentials({
    required this.name,
    required this.email,
    required this.password,
    required this.mobile,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'mobile': mobile,
      };
}

class AccessToken {
  final String token;

  AccessToken({required this.token});

  factory AccessToken.fromJson(Map<String, dynamic> json) => AccessToken(
        token: json['token'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'token': token,
      };
}

class LoginData {
  final AccessToken accesstoken;
  final User user;

  LoginData({
    required this.accesstoken,
    required this.user,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) => LoginData(
        accesstoken: AccessToken.fromJson(json['accesstoken'] ?? {}),
        user: User.fromJson(json['user'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'accesstoken': accesstoken.toJson(),
        'user': user.toJson(),
      };
}

class LoginResponse {
  final String message;
  final int status;
  final LoginData data;

  LoginResponse({
    required this.message,
    required this.status,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        message: json['message'] ?? '',
        status: json['status'] ?? 0,
        data: LoginData.fromJson(json['data'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'message': message,
        'status': status,
        'data': data.toJson(),
      };
}

// =======================
// Team Models
// =======================
class Team {
  final String id;
  final String createdById;
  final String name;
  final int stepsGoal;
  final int fundRaisingGoal;
  final String story;
  final String createTime;
  final String endTime;
  final bool isActive;
  final int? participants;
  final double? fundsRaised;

  Team({
    required this.id,
    required this.createdById,
    required this.name,
    required this.stepsGoal,
    required this.fundRaisingGoal,
    required this.story,
    required this.createTime,
    required this.endTime,
    required this.isActive,
    this.participants,
    this.fundsRaised,
  });

  factory Team.fromJson(Map<String, dynamic> json) => Team(
        id: json['id'] ?? '',
        createdById: json['createdById'] ?? '',
        name: json['name'] ?? '',
        stepsGoal: json['stepsGoal'] ?? 0,
        fundRaisingGoal: json['fundRaisingGoal'] ?? 0,
        story: json['story'] ?? '',
        createTime: json['createTime'] ?? '',
        endTime: json['endTime'] ?? '',
        isActive: json['isActive'] ?? false,
        participants: json['participants'],
        fundsRaised: json['fundsRaised']?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdById': createdById,
        'name': name,
        'stepsGoal': stepsGoal,
        'fundRaisingGoal': fundRaisingGoal,
        'story': story,
        'createTime': createTime,
        'endTime': endTime,
        'isActive': isActive,
        'participants': participants,
        'fundsRaised': fundsRaised,
      };
}

class CreateTeamRequest {
  final String name;
  final int stepsGoal;
  final int fundRaisingGoal;
  final String story;


  CreateTeamRequest({
    required this.name,
    required this.stepsGoal,
    required this.fundRaisingGoal,
    required this.story,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'stepsGoal': stepsGoal,
        'fundRaisingGoal': fundRaisingGoal,
        'story': story,
      };
}

class TeamDetailed {
  final String id;
  final String name;
  final String? story;
  final num stepsGoal;  // Changed from int to num to handle both int and double
  final num fundRaisingGoal;  // Changed from int to num to handle both int and double
  final String createTime;
  final bool isActive;
  final String createdById;
  final Map<String, dynamic> createdBy;
  final double? fundsRaised;
  final int? participants;

  TeamDetailed({
    required this.id,
    required this.name,
    this.story,
    required this.stepsGoal,
    required this.fundRaisingGoal,
    required this.createTime,
    required this.isActive,
    required this.createdById,
    required this.createdBy,
    this.fundsRaised,
    this.participants,
  });

  factory TeamDetailed.fromJson(Map<String, dynamic> json) => TeamDetailed(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        story: json['story'],
        stepsGoal: (json['stepsGoal'] ?? 0).toDouble(),
        fundRaisingGoal: (json['fundRaisingGoal'] ?? 0).toDouble(),
        createTime: json['createTime'] ?? '',
        isActive: json['isActive'] ?? false,
        createdById: json['createdById'] ?? '',
        createdBy: Map<String, dynamic>.from(json['createdBy'] ?? {}),
        fundsRaised: json['fundsRaised']?.toDouble(),
        participants: json['participants'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'story': story,
        'stepsGoal': stepsGoal,
        'fundRaisingGoal': fundRaisingGoal,
        'createTime': createTime,
        'isActive': isActive,
        'createdById': createdById,
        'createdBy': createdBy,
        'fundsRaised': fundsRaised,
        'participants': participants,
      };
}

class UserTeamsDetailed {
  final List<TeamDetailed> createdTeams;
  final List<TeamDetailed> joinedTeams;
  final List<TeamDetailed> allTeams;

  UserTeamsDetailed({
    required this.createdTeams,
    required this.joinedTeams,
    required this.allTeams,
  });
}

// =======================
// Donation Models
// =======================
class DonationResponse {
  final String message;
  final int status;
  final DonationData data;

  DonationResponse({
    required this.message,
    required this.status,
    required this.data,
  });

  factory DonationResponse.fromJson(Map<String, dynamic> json) => DonationResponse(
        message: json['message'] ?? '',
        status: json['status'] ?? 0,
        data: DonationData.fromJson(json['data'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'message': message,
        'status': status,
        'data': data.toJson(),
      };
}

class DonationData {
  final String transactionId;
  final String? paymentLink;

  DonationData({
    required this.transactionId,
    this.paymentLink,
  });

  factory DonationData.fromJson(Map<String, dynamic> json) => DonationData(
        transactionId: json['transactionId'] ?? '',
        paymentLink: json['paymentLink'] ?? json['payment_link'],
      );

  Map<String, dynamic> toJson() => {
        'transactionId': transactionId,
        'paymentLink': paymentLink,
      };
}

class IndividualDonationRequest {
  final String userId;
  final double amount;
  final String phoneNumber;
  final String network;
  final String? reference;

  IndividualDonationRequest({
    required this.userId,
    required this.amount,
    required this.phoneNumber,
    required this.network,
    this.reference,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'amount': amount,
        'phoneNumber': phoneNumber,
        'network': network,
        'reference': reference,
      };
}

class TeamDonationRequest {
  final String userId;
  final String teamId;
  final double amount;
  final String phoneNumber;
  final String network;
  final String? reference;

  TeamDonationRequest({
    required this.userId,
    required this.teamId,
    required this.amount,
    required this.phoneNumber,
    required this.network,
    this.reference,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'teamId': teamId,
        'amount': amount,
        'phoneNumber': phoneNumber,
        'network': network,
        'reference': reference,
      };
}

class DonationVerificationResponse {
  final String message;
  final int status;
  final DonationVerificationData? data;

  DonationVerificationResponse({
    required this.message,
    required this.status,
    required this.data,
  });

  factory DonationVerificationResponse.fromJson(Map<String, dynamic> json) => DonationVerificationResponse(
        message: json['message'] ?? '',
        status: json['status'] ?? 0,
        data: json['data'] != null ? DonationVerificationData.fromJson(json['data']) : null,
      );

  Map<String, dynamic> toJson() => {
        'message': message,
        'status': status,
        'data': data?.toJson(),
      };
}

class DonationVerificationData {
  final String id;
  final double amount;
  final String status;
  final String transactionId;
  final String phoneNumber;
  final String network;
  final String userId;
  final String createdAt;
  final String updatedAt;

  DonationVerificationData({
    required this.id,
    required this.amount,
    required this.status,
    required this.transactionId,
    required this.phoneNumber,
    required this.network,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DonationVerificationData.fromJson(Map<String, dynamic> json) => DonationVerificationData(
        id: json['id'] ?? '',
        amount: json['amount']?.toDouble() ?? 0.0,
        status: json['status'] ?? '',
        transactionId: json['transactionId'] ?? '',
        phoneNumber: json['phoneNumber'] ?? '',
        network: json['network'] ?? '',
        userId: json['userId'] ?? '',
        createdAt: json['createdAt'] ?? '',
        updatedAt: json['updatedAt'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'status': status,
        'transactionId': transactionId,
        'phoneNumber': phoneNumber,
        'network': network,
        'userId': userId,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

class DonationItem {
  final String id;
  final Map<String, dynamic> appUser;
  final String userId;
  final double amount;
  final String status;
  final String createDate;
  final String completedDate;
  final String transactionId;
  final String? phoneNumber;
  final String? network;
  final String? paymentLink;
  final Map<String, dynamic>? team;

  DonationItem({
    required this.id,
    required this.appUser,
    required this.userId,
    required this.amount,
    required this.status,
    required this.createDate,
    required this.completedDate,
    required this.transactionId,
    this.phoneNumber,
    this.network,
    this.paymentLink,
    this.team,
  });

  factory DonationItem.fromJson(Map<String, dynamic> json) => DonationItem(
        id: json['id'] ?? '',
        appUser: Map<String, dynamic>.from(json['appUser'] ?? {}),
        userId: json['userId'] ?? '',
        amount: json['amount']?.toDouble() ?? 0.0,
        status: json['status'] ?? '',
        createDate: json['createDate'] ?? '',
        completedDate: json['completedDate'] ?? '',
        transactionId: json['transactionId'] ?? '',
        phoneNumber: json['phoneNumber'],
        network: json['network'],
        paymentLink: json['paymentLink'],
        team: json['team'] != null ? Map<String, dynamic>.from(json['team']) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'appUser': appUser,
        'userId': userId,
        'amount': amount,
        'status': status,
        'createDate': createDate,
        'completedDate': completedDate,
        'transactionId': transactionId,
        'phoneNumber': phoneNumber,
        'network': network,
        'paymentLink': paymentLink,
        'team': team,
      };
}

class DonationsResponse {
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final int totalRecords;
  final String message;
  final int status;
  final List<DonationItem> data;

  DonationsResponse({
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
    required this.totalRecords,
    required this.message,
    required this.status,
    required this.data,
  });

  factory DonationsResponse.fromJson(Map<String, dynamic> json) => DonationsResponse(
        pageNumber: json['pageNumber'] ?? 1,
        pageSize: json['pageSize'] ?? 5,
        totalPages: json['totalPages'] ?? 0,
        totalRecords: json['totalRecords'] ?? 0,
        message: json['message'] ?? '',
        status: json['status'] ?? 0,
        data: (json['data'] as List?)?.map((e) => DonationItem.fromJson(e)).toList() ?? [],
      );

  Map<String, dynamic> toJson() => {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        'totalPages': totalPages,
        'totalRecords': totalRecords,
        'message': message,
        'status': status,
        'data': data.map((e) => e.toJson()).toList(),
      };
}

// =======================
// Target Models
// =======================
class UserTargetsRequest {
  final String userId;
  final int stepTarget;
  final int donationTarget;

  UserTargetsRequest({
    required this.userId,
    required this.stepTarget,
    required this.donationTarget,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'stepTarget': stepTarget,
        'donationTarget': donationTarget,
      };
}

// =======================
// FormData for Multipart Requests
// =======================
class FormData {
  final Map<String, String> fields;
  final Map<String, List<int>> files;

  FormData({
    this.fields = const {},
    this.files = const {},
  });
}