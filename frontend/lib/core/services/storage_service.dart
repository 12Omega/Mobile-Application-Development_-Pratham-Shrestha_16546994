import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parkease/core/models/user_model.dart';
import 'package:parkease/core/models/parking_model.dart';
import 'package:parkease/core/models/booking_model.dart';

class StorageService {
  static const String _authTokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _themeKey = 'app_theme';
  static const String _recentSearchesKey = 'recent_searches';
  static const String _favoriteLocationsKey = 'favorite_locations';
  static const String _recentBookingsKey = 'recent_bookings';

  late Box _appBox;
  late SharedPreferences _prefs;

  // Initialize storage
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _appBox = await Hive.openBox('parkease_app_box');
  }

  // Auth token methods
  Future<void> setAuthToken(String token) async {
    await _prefs.setString(_authTokenKey, token);
  }

  Future<String?> getAuthToken() async {
    return _prefs.getString(_authTokenKey);
  }

  Future<void> clearAuthToken() async {
    await _prefs.remove(_authTokenKey);
  }

  // User data methods
  Future<void> setUser(User user) async {
    await _appBox.put(_userKey, jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    final userData = _appBox.get(_userKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  Future<void> clearUser() async {
    await _appBox.delete(_userKey);
  }

  // Theme preference
  Future<void> setThemeMode(String theme) async {
    await _prefs.setString(_themeKey, theme);
  }

  String getThemeMode() {
    return _prefs.getString(_themeKey) ?? 'system';
  }

  // Recent searches
  Future<void> addRecentSearch(String query) async {
    List<String> searches = _prefs.getStringList(_recentSearchesKey) ?? [];

    // Remove if already exists to avoid duplicates
    searches.remove(query);

    // Add to the beginning of the list
    searches.insert(0, query);

    // Keep only the last 10 searches
    if (searches.length > 10) {
      searches = searches.sublist(0, 10);
    }

    await _prefs.setStringList(_recentSearchesKey, searches);
  }

  List<String> getRecentSearches() {
    return _prefs.getStringList(_recentSearchesKey) ?? [];
  }

  Future<void> clearRecentSearches() async {
    await _prefs.remove(_recentSearchesKey);
  }

  // Favorite parking locations
  Future<void> addFavoriteLocation(ParkingLot parkingLot) async {
    List<String> favorites = _prefs.getStringList(_favoriteLocationsKey) ?? [];

    // Store as JSON string
    final parkingLotJson = jsonEncode(parkingLot.toJson());

    // Check if already exists
    bool exists = false;
    for (int i = 0; i < favorites.length; i++) {
      final item = jsonDecode(favorites[i]);
      if (item['_id'] == parkingLot.id) {
        // Update existing
        favorites[i] = parkingLotJson;
        exists = true;
        break;
      }
    }

    // Add if not exists
    if (!exists) {
      favorites.add(parkingLotJson);
    }

    await _prefs.setStringList(_favoriteLocationsKey, favorites);
  }

  Future<void> removeFavoriteLocation(String parkingLotId) async {
    List<String> favorites = _prefs.getStringList(_favoriteLocationsKey) ?? [];

    favorites.removeWhere((item) {
      final parkingLot = jsonDecode(item);
      return parkingLot['_id'] == parkingLotId;
    });

    await _prefs.setStringList(_favoriteLocationsKey, favorites);
  }

  List<ParkingLot> getFavoriteLocations() {
    List<String> favorites = _prefs.getStringList(_favoriteLocationsKey) ?? [];

    return favorites.map((item) {
      return ParkingLot.fromJson(jsonDecode(item));
    }).toList();
  }

  bool isFavoriteLocation(String parkingLotId) {
    List<String> favorites = _prefs.getStringList(_favoriteLocationsKey) ?? [];

    for (var item in favorites) {
      final parkingLot = jsonDecode(item);
      if (parkingLot['_id'] == parkingLotId) {
        return true;
      }
    }

    return false;
  }

  // Recent bookings cache
  Future<void> cacheRecentBookings(List<Booking> bookings) async {
    final bookingsJson =
        bookings.map((booking) => jsonEncode(booking.toJson())).toList();
    await _appBox.put(_recentBookingsKey, bookingsJson);
  }

  List<Booking> getCachedRecentBookings() {
    final bookingsJson = _appBox.get(_recentBookingsKey);

    if (bookingsJson != null && bookingsJson is List) {
      return bookingsJson
          .map((item) => Booking.fromJson(jsonDecode(item)))
          .toList();
    }

    return [];
  }

  // Alias methods for profile_viewmodel.dart
  Future<void> saveRecentBookings(List<Booking> bookings) async {
    await cacheRecentBookings(bookings);
  }

  Future<List<Booking>> getRecentBookings() async {
    return getCachedRecentBookings();
  }

  // Boolean preferences
  Future<bool?> getBool(String key) async {
    return _prefs.getBool(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs.clear();
    await _appBox.clear();
  }
}
