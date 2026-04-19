import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class NetworkEvent {}

class _NetworkNotify extends NetworkEvent {
  final List<ConnectivityResult> results;
  _NetworkNotify(this.results);
}

class NetworkEventCheck extends NetworkEvent {
  NetworkEventCheck();
}

// States
enum NetworkStatus { connected, disconnected }

class NetworkState {
  final NetworkStatus status;
  NetworkState(this.status);
}

// Bloc
class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;

  NetworkBloc() : super(NetworkState(NetworkStatus.connected)) {
    // 1. Initial Check
    _checkInitialConnection();

    // 2. Listen to changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      add(_NetworkNotify(results));
    });

    on<_NetworkNotify>((event, emit) {
      if (event.results.contains(ConnectivityResult.none)) {
        emit(NetworkState(NetworkStatus.disconnected));
      } else {
        emit(NetworkState(NetworkStatus.connected));
      }
    });

    on<NetworkEventCheck>((event, emit) async {
      final results = await _connectivity.checkConnectivity();
      add(_NetworkNotify(results));
    });
  }

  Future<void> _checkInitialConnection() async {
    final results = await _connectivity.checkConnectivity();
    add(_NetworkNotify(results));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
