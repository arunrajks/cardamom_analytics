import 'package:shared_preferences/shared_preferences.dart';

/// Utility class to manage app preferences and settings
class AppPreferences {
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _lastAuctionDateKey = 'last_notified_auction_date';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _notificationFrequencyKey = 'notification_frequency_hours';
  static const String _userNameKey = 'user_name';
  static const String _farmNameKey = 'farm_name';
  static const String _locationKey = 'location';
  static const String _userEmailKey = 'user_email';
  static const String _userPhoneKey = 'user_phone';
  static const String _lastFetchAttemptKey = 'last_fetch_attempt_timestamp';


  /// Get profile data
  static Future<Map<String, String>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userName': prefs.getString(_userNameKey) ?? '',
      'farmName': prefs.getString(_farmNameKey) ?? '',
      'location': prefs.getString(_locationKey) ?? '',
      'userEmail': prefs.getString(_userEmailKey) ?? '',
      'userPhone': prefs.getString(_userPhoneKey) ?? '',
    };
  }

  /// Set profile data
  static Future<void> setProfile({
    required String userName, 
    required String farmName, 
    required String location,
    String? email,
    String? phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, userName);
    await prefs.setString(_farmNameKey, farmName);
    await prefs.setString(_locationKey, location);
    if (email != null) await prefs.setString(_userEmailKey, email);
    if (phone != null) await prefs.setString(_userPhoneKey, phone);
  }

  /// Get the last sync timestamp
  static Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_lastSyncKey);
    if (str != null) {
      return DateTime.parse(str);
    }
    return null;
  }

  /// Set the last sync timestamp
  static Future<void> setLastSyncTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, time.toIso8601String());
  }

  /// Get the last known auction date
  static Future<DateTime?> getLastAuctionDate() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_lastAuctionDateKey);
    if (str != null) {
      return DateTime.parse(str);
    }
    return null;
  }

  /// Set the last known auction date
  static Future<void> setLastAuctionDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastAuctionDateKey, date.toIso8601String());
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true; // Default: enabled
  }

  /// Set notifications enabled/disabled
  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }

  /// Get notification check frequency in hours
  static Future<int> getNotificationFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_notificationFrequencyKey) ?? 12; // Default: 12 hours
  }

  /// Set notification check frequency in hours
  static Future<void> setNotificationFrequency(int hours) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_notificationFrequencyKey, hours);
  }

  /// Get the last fetch attempt timestamp

  static Future<DateTime?> getLastFetchAttemptTime() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_lastFetchAttemptKey);
    if (str != null) {
      return DateTime.parse(str);
    }
    return null;
  }

  /// Set the last fetch attempt timestamp
  static Future<void> setLastFetchAttemptTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastFetchAttemptKey, time.toIso8601String());
  }
}

