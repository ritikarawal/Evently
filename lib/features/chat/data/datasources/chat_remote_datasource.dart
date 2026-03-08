import 'package:dio/dio.dart';
import 'package:event_planner/core/api/api_endpoints.dart';
import 'package:event_planner/features/chat/data/models/chat_message_api_model.dart';

abstract class IChatRemoteDataSource {
  Future<List<ChatMessageApiModel>> getChatHistory();
  Future<int> getUnreadCount();
  Future<ChatMessageApiModel> sendUserMessage(String text);
}

class ChatRemoteDataSource implements IChatRemoteDataSource {
  final Dio _dio;

  ChatRemoteDataSource(this._dio);

  @override
  Future<List<ChatMessageApiModel>> getChatHistory() async {
    final response = await _dio.get(ApiEndpoints.chatHistory);
    final data = response.data;
    final payload = data is Map<String, dynamic> ? data['data'] : data;

    if (payload is! List) return const [];

    return payload
        .map(
          (e) =>
              ChatMessageApiModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _dio.get(ApiEndpoints.chatUnreadCount);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final payload = data['data'];
      if (payload is Map<String, dynamic>) {
        final raw = payload['unreadCount'];
        if (raw is int) return raw;
        if (raw is num) return raw.toInt();
        return int.tryParse('$raw') ?? 0;
      }
    }
    return 0;
  }

  @override
  Future<ChatMessageApiModel> sendUserMessage(String text) async {
    final response = await _dio.post(
      ApiEndpoints.chatSendUser,
      data: {'text': text},
    );
    final data = response.data;
    final payload = data is Map<String, dynamic> ? data['data'] : data;
    return ChatMessageApiModel.fromJson(
      Map<String, dynamic>.from(payload as Map),
    );
  }
}
