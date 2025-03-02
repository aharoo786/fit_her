import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CheckConnectionService {
  bool hasConnection = false;

  // StreamController to notify about connection changes
  StreamController<bool> connectionChangeController =
      StreamController<bool>.broadcast();

  // Instance of Connectivity class
  final Connectivity _connectivity = Connectivity();

  // Initializes the service and listens for connectivity changes
  void initialize() {
    // Listen for connectivity changes and call _connectionChange
    _connectivity.onConnectivityChanged.listen((event) {
      _connectionChange(event.first);
    });
    checkConnection(); // Initial check when the app starts
  }

  // Expose the connection change stream to other parts of the app
  Stream<bool> get connectionChange => connectionChangeController.stream;

  // Clean up the StreamController when not needed anymore
  void dispose() {
    connectionChangeController.close();
  }

  // Handles connectivity changes
  Future<void> _connectionChange(ConnectivityResult result) async {
    await checkConnection();
  }

  // Check if there is an actual internet connection
  Future<bool> checkConnection() async {
    bool previousConnection = hasConnection;

    try {
      // For non-web platforms, perform an InternetAddress.lookup
      if (kIsWeb) {
        final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'))
            .timeout(Duration(seconds: 5));        hasConnection = response.statusCode == 200;

      } else {
        // For web or platforms where InternetAddress.lookup doesn't work
        final result = await InternetAddress.lookup('google.com');
        hasConnection = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      }
    }on SocketException catch (_) {
      hasConnection = false;
    }

    // If connection status changes, notify listeners
    if (previousConnection != hasConnection) {
      connectionChangeController.add(hasConnection);
    }

    return hasConnection;
  }
}
