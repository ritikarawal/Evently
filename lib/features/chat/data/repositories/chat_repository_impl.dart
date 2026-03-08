import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:event_planner/core/api/api_client.dart';
import 'package:event_planner/core/error/failures.dart';
import 'package:event_planner/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:event_planner/features/chat/domain/entities/chat_message_entity.dart';
import 'package:event_planner/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatRemoteDataSourceProvider = Provider<IChatRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  return ChatRemoteDataSource(dio);
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final remote = ref.read(chatRemoteDataSourceProvider);
  return ChatRepositoryImpl(remote);
});

class ChatRepositoryImpl implements ChatRepository {
  final IChatRemoteDataSource _remote;

  ChatRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<ChatMessageEntity>>> getChatHistory() async {
    try {
      final result = await _remote.getChatHistory();
      return Right(result.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        ServerFailure(message: e.message ?? 'Failed to fetch chat history'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final count = await _remote.getUnreadCount();
      return Right(count);
    } on DioException catch (e) {
      return Left(
        ServerFailure(message: e.message ?? 'Failed to fetch unread count'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatMessageEntity>> sendUserMessage(
    String text,
  ) async {
    try {
      final result = await _remote.sendUserMessage(text);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(
        ServerFailure(message: e.message ?? 'Failed to send message'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
