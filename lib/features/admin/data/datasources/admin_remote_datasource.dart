import 'package:event_planner/core/api/api_client.dart';
import 'package:event_planner/core/api/api_endpoints.dart';
import 'package:event_planner/features/admin/data/models/admin_chat_message_api_model.dart';
import 'package:event_planner/features/admin/data/models/admin_chat_user_api_model.dart';
import 'package:event_planner/features/admin/data/models/admin_event_api_model.dart';
import 'package:event_planner/features/admin/data/models/admin_user_api_model.dart';
import 'package:event_planner/features/admin/data/models/admin_venue_api_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class IAdminRemoteDataSource {
  Future<List<AdminUserApiModel>> getUsers({int page = 1, int limit = 10});
  Future<AdminUserApiModel> createUser({
    required AdminUserApiModel user,
    required String password,
  });
  Future<AdminUserApiModel> updateUser(AdminUserApiModel user);
  Future<void> deleteUser(String userId);

  Future<List<AdminEventApiModel>> getEvents();
  Future<void> approveEvent(String eventId, {String? adminNotes});
  Future<void> declineEvent(String eventId, {String? adminNotes});
  Future<void> deleteEvent(String eventId);

  Future<List<AdminVenueApiModel>> getVenues();
  Future<AdminVenueApiModel> createVenue(AdminVenueApiModel venue);

  Future<List<AdminChatUserApiModel>> getChatUsers();
  Future<List<AdminChatMessageApiModel>> getUserChat(String userId);
  Future<AdminChatMessageApiModel> sendAdminMessage({
    required String userId,
    required String text,
    String? adminName,
  });
}

class AdminRemoteDataSource implements IAdminRemoteDataSource {
  final ApiClient _apiClient;

  AdminRemoteDataSource(this._apiClient);

  @override
  Future<List<AdminUserApiModel>> getUsers({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.adminUsers,
      queryParameters: {'page': page, 'limit': limit},
    );

    final data = response.data;
    final list = _extractList(data);
    return list
        .map(
          (e) =>
              AdminUserApiModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  @override
  Future<AdminUserApiModel> createUser({
    required AdminUserApiModel user,
    required String password,
  }) async {
    final payload = {
      'firstName': user.firstName,
      'lastName': user.lastName,
      'username': user.username,
      'email': user.email,
      'phoneNumber': user.phoneNumber,
      'role': user.role,
      'password': password,
      'confirmPassword': password,
    };

    final response = await _apiClient.post(
      ApiEndpoints.adminUsers,
      data: payload,
    );
    final mapped = _extractMap(response.data);
    return AdminUserApiModel.fromJson(mapped);
  }

  @override
  Future<AdminUserApiModel> updateUser(AdminUserApiModel user) async {
    final payload = {
      'firstName': user.firstName,
      'lastName': user.lastName,
      'username': user.username,
      'email': user.email,
      'phoneNumber': user.phoneNumber,
      'role': user.role,
    };

    final response = await _apiClient.put(
      ApiEndpoints.adminUserById(user.id),
      data: payload,
    );
    final mapped = _extractMap(response.data);
    return AdminUserApiModel.fromJson(mapped);
  }

  @override
  Future<void> deleteUser(String userId) async {
    await _apiClient.delete(ApiEndpoints.adminUserById(userId));
  }

  @override
  Future<List<AdminEventApiModel>> getEvents() async {
    final response = await _apiClient.get(ApiEndpoints.adminEvents);
    final list = _extractList(response.data);
    return list
        .map(
          (e) =>
              AdminEventApiModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  @override
  Future<void> approveEvent(String eventId, {String? adminNotes}) async {
    await _apiClient.put(
      ApiEndpoints.adminApproveEvent(eventId),
      data: {'adminNotes': adminNotes ?? ''},
    );
  }

  @override
  Future<void> declineEvent(String eventId, {String? adminNotes}) async {
    await _apiClient.put(
      ApiEndpoints.adminDeclineEvent(eventId),
      data: {'adminNotes': adminNotes ?? ''},
    );
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await _apiClient.delete(ApiEndpoints.adminEventById(eventId));
  }

  @override
  Future<List<AdminVenueApiModel>> getVenues() async {
    final response = await _apiClient.get(ApiEndpoints.venues);
    final list = _extractList(response.data);
    return list
        .map(
          (e) =>
              AdminVenueApiModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  @override
  Future<AdminVenueApiModel> createVenue(AdminVenueApiModel venue) async {
    final response = await _apiClient.post(
      ApiEndpoints.venues,
      data: venue.toCreateJson(),
    );
    final mapped = _extractMap(response.data);
    return AdminVenueApiModel.fromJson(mapped);
  }

  @override
  Future<List<AdminChatUserApiModel>> getChatUsers() async {
    final response = await _apiClient.get(ApiEndpoints.adminChatUsers);
    final list = _extractList(response.data);
    return list
        .map(
          (e) => AdminChatUserApiModel.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  @override
  Future<List<AdminChatMessageApiModel>> getUserChat(String userId) async {
    final response = await _apiClient.get(ApiEndpoints.adminChatUser(userId));
    final map = _extractMap(response.data);
    final messages = map['messages'];
    if (messages is! List) return const [];

    return messages
        .map(
          (e) => AdminChatMessageApiModel.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  @override
  Future<AdminChatMessageApiModel> sendAdminMessage({
    required String userId,
    required String text,
    String? adminName,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.adminChatSend(userId),
      data: {'text': text, 'adminName': adminName ?? 'Admin'},
    );

    final mapped = _extractMap(response.data);
    return AdminChatMessageApiModel.fromJson(mapped);
  }

  List<dynamic> _extractList(dynamic responseData) {
    if (responseData is List) return responseData;
    if (responseData is Map<String, dynamic>) {
      final data = responseData['data'];
      if (data is List) return data;
    }
    return const [];
  }

  Map<String, dynamic> _extractMap(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final data = responseData['data'];
      if (data is Map<String, dynamic>) return data;
      return responseData;
    }
    return <String, dynamic>{};
  }
}

final adminRemoteDataSourceProvider = Provider<IAdminRemoteDataSource>((ref) {
  return AdminRemoteDataSource(ref.read(apiClientProvider));
});
