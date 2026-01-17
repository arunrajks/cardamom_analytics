import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'dart:io';

/// Enhanced service for local push notifications, refactored from scratch.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Constants for Android channel
  static const String _channelId = 'cardamom_price_alerts';
  static const String _channelName = 'Price Alerts';
  static const String _channelDesc = 'Notifications for new cardamom auction prices';

  /// Initialize the notification service with platform-specific settings
  Future<void> initialize() async {
    if (_initialized) return;

    // Android: use the app icon for notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS: request permissions on initialization if not already handled
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create the Android notification channel (required for Android 8.0+)
    if (Platform.isAndroid) {
      await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
          ));
    }

    _initialized = true;
  }

  /// Triggered when a notification is tapped by the user
  void _onNotificationTapped(NotificationResponse response) {
    // Optional: Add navigation logic here based on response.payload
    // Example: navigate to the price history screen
  }

  /// Request permissions specifically for notifications
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      final iosImplementation = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      return await iosImplementation?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return true;
  }

  /// Show a high-priority notification with new auction price details
  Future<void> showPriceNotification({
    required String auctioneer,
    required double avgPrice,
    required double maxPrice,
    required double quantity,
    required DateTime date,
  }) async {
    if (!_initialized) await initialize();

    final dateStr = DateFormat('dd MMM').format(date);
    final notificationId = DateTime.now().millisecond + auctioneer.hashCode.abs();

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      styleInformation: BigTextStyleInformation(
        'Avg Price: ₹${avgPrice.toStringAsFixed(2)} | Max: ₹${maxPrice.toStringAsFixed(2)}\nQty Sold: ${NumberFormat("#,##0").format(quantity)} kg',
        contentTitle: 'New Auction: $auctioneer',
        summaryText: '$dateStr Price Update',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      notificationId % 100000, // Stay within safe ID range
      'New Price: ₹${avgPrice.toStringAsFixed(0)}',
      'Auction at $auctioneer: ${NumberFormat("#,##0").format(quantity)} kg sold',
      details,
      payload: 'auction_${date.toIso8601String()}',
    );
  }

  /// Clear all currently active notifications
  Future<void> clearAll() async {
    await _notifications.cancelAll();
  }
}
