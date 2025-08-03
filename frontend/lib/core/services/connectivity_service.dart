import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ConnectivityService {
  Stream<bool> get connectivityStream;
  Future<bool> get isConnected;
}

class ConnectivityServiceImpl implements ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();

  ConnectivityServiceImpl() {
    _init();
  }

  void _init() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _connectivityController.add(_isConnected(result));
    });
  }

  bool _isConnected(ConnectivityResult result) {
    return result != ConnectivityResult.none;
  }

  @override
  Stream<bool> get connectivityStream => _connectivityController.stream;

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return _isConnected(result);
  }

  void dispose() {
    _connectivityController.close();
  }
}