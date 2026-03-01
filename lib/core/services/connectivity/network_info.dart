import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class INetworkInfo {
  Future<bool> get isConnected;
  Future<bool> canReachApi(String apiBaseUrl);
}

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo(Connectivity());
});

class NetworkInfo implements INetworkInfo {
  final Connectivity _connectivity;

  NetworkInfo(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    if (result.contains(ConnectivityResult.none)) {
      return false;
    }

    return _hasInternetAccess();
  }

  Future<bool> _hasInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('one.one.one.one');
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> canReachApi(String apiBaseUrl) async {
    if (!await isConnected) {
      return false;
    }

    final root = apiBaseUrl.replaceFirst('/api/', '/');
    final uri = Uri.parse(root);
    final httpClient = HttpClient();
    httpClient.connectionTimeout = const Duration(seconds: 4);

    try {
      final request = await httpClient.getUrl(uri);
      final response = await request.close().timeout(const Duration(seconds: 4));
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (_) {
      return false;
    } finally {
      httpClient.close(force: true);
    }
  }
}
