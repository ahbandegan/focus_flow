import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  final Connectivity _connectivity;
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _lastStatus = false;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity() {
    _init();
  }

  void _init() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) async {
      final hasInterface = results.any(
        (r) => r != ConnectivityResult.none,
      );
      final connected = hasInterface && await checkInternetConnection();
      if (_lastStatus != connected) {
        _lastStatus = connected;
        _connectivityController.add(connected);
      }
    });
  }

  /// Stream of true (connected to internet) or false (disconnected).
  Stream<bool> get onConnectivityChanged => _connectivityController.stream;

  /// Check current connection state.
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    final hasInterface = results.any(
      (r) => r != ConnectivityResult.none,
    );
    if (!hasInterface) return false;
    return await checkInternetConnection();
  }

  /// Verify actual reachability via DNS lookup or socket check.
  Future<bool> checkInternetConnection() async {
    if (kIsWeb) return true;
    try {
      final lookup = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty;
    } catch (_) {
      try {
        final lookupBackup = await InternetAddress.lookup('one.one.one.one')
            .timeout(const Duration(seconds: 3));
        return lookupBackup.isNotEmpty && lookupBackup[0].rawAddress.isNotEmpty;
      } catch (_) {
        return false;
      }
    }
  }

  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
  }
}
