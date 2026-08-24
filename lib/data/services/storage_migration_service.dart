import 'package:scores/utils/my_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageMigrationService {

  // 1. Define your current app version constants
  static const String _versionKey = 'prefs_version';
  static const int _currentVersion = 2; // Incremented from 1

  Future<void> checkAndMigrate() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Read the existing version. If it's missing (brand new install), default to 0.
    final int storedVersion = prefs.getInt(_versionKey) ?? 0;

    debugMsg("StorageMigrationService checkAndMigrate storedVersion $storedVersion");

    if (storedVersion < _currentVersion) {
      await _runMigrationSteps(prefs, storedVersion);
      
      // Update the ledger so this migration never runs again
      await prefs.setInt(_versionKey, _currentVersion);
    } else {
      debugMsg("no migration needed");
    }
  }

  Future<void> _runMigrationSteps(SharedPreferences prefs, int oldVersion) async {
    // Migration from Version 0 (or 1) to Version 2
    if (oldVersion < 2) {
      await _migrateToV2(prefs);
    }
    
    // Future expansion slot:
    // if (oldVersion < 3) { await _migrateToV3(prefs); }
  }

  Future<void> _migrateToV2(SharedPreferences prefs) async {
    
    debugMsg("StorageMigrationService _migrateToV2");
    
    await prefs.clear();

    // Example Scenario: You used to store 'player_names' as a comma-separated string,
    // but now you want to store them as a proper List<String> under a new key.
    
    // final oldData = prefs.getString('current_match_players_legacy');
    // if (oldData != null) {
    //   // Perform the calculation/transformation
    //   final List<String> modernList = oldData.split(',');
      
    //   // Save to the new structure
    //   await prefs.setStringList('current_match_players', modernList);
      
    //   // Clean up the legacy keys (don't leave messy data in the engine room!)
    //   await prefs.remove('current_match_players_legacy');
    // }
  }
}