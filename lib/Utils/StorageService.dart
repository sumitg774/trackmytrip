import 'package:shared_preferences/shared_preferences.dart';

import 'StorageKeys.dart';

class StorageService {
  // Private constructor
  StorageService._privateConstructor();
  static final StorageService _instance = StorageService._privateConstructor();

  // Singleton instance accessor
  static StorageService get instance => _instance;

  // SharedPreferences instance
  SharedPreferences? _prefs;

  // Initialize SharedPreferences (called once in main or app initialization)
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save a String value
  Future<void> saveString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  // Retrieve a String value
  String? getString(String key) {
    return _prefs?.getString(key);
  }

  // Remove a value
  Future<void> removeValue(String key) async {
    await _prefs?.remove(key);
  }

  Future<void> saveCollectionName(String collectionName) async {
    await _prefs?.setString(StorageKeys.dynamicCollection, collectionName);
  }

  Future<void> saveTeamsCollectionName(String teamsCollectionName) async {
    await _prefs?.setString(StorageKeys.dynamicTeamsCollection, teamsCollectionName);
  }

  Future<void> saveLeaveCollectionName(String leaveCollectionName) async {
    await _prefs?.setString(StorageKeys.dynamicLeaveCollection, leaveCollectionName);
  }

  Future<String?> getCollectionName() async {
    return _prefs?.getString(StorageKeys.dynamicCollection);
  }

  Future<String?> getTeamsCollectionName() async {
    return _prefs?.getString(StorageKeys.dynamicTeamsCollection);
  }

  Future<String?> getLeaveCollectionName() async {
    return _prefs?.getString(StorageKeys.dynamicLeaveCollection);
  }


  // 🧹 Clear all stored data (for logout)
  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}