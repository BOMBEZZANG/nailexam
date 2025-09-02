import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'core/utils/logger.dart';
import 'managers/game_manager.dart';
import 'managers/local_storage_manager.dart';
import 'managers/timer_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Force portrait orientation
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    
    Logger.i('App starting up...');
    
    // Initialize managers in order
    await LocalStorageManager.instance.initialize();
    Logger.i('LocalStorageManager initialized');
    
    GameManager.instance.initialize();
    Logger.i('GameManager initialized');
    
    Logger.i('App initialization complete');
    
    runApp(const NailExamApp());
  } catch (e, stackTrace) {
    Logger.e('Failed to initialize app', error: e, stackTrace: stackTrace);
    
    // Show error screen
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to start the app',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Error: ${e.toString()}',
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
