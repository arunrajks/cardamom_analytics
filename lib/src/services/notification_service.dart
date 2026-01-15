import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

/// Service to handle local push notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
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

    _initialized = true;
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - could navigate to specific screen
    // For now, just log it
    print('Notification tapped: ${response.payload}');
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (await Permission.notification.isGranted) {
      return true;
    }

    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Show a notification for new auction data
  Future<void> showNewAuctionNotification({
    required String auctioneer,
    required double avgPrice,
    required double maxPrice,
    required DateTime date,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      'auction_updates',
      'Auction Updates',
      channelDescription: 'Notifications for new cardamom auction prices',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(''), // Enable multi-line support
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Generate a unique notification ID based on date and auctioneer 
    // strictly positive to avoid Android issues.
    final dayOfYear = date.day + (date.month * 31);
    final notificationId = (dayOfYear * 100) + (auctioneer.hashCode.abs() % 100);

    final dateLabel = DateFormat('dd MMM').format(date);
    
    await _notifications.show(
      notificationId,
      '$dateLabel: ₹${avgPrice.toStringAsFixed(0)} - $auctioneer',
      'Avg Price: ₹${avgPrice.toStringAsFixed(2)}\nMax Price: ₹${maxPrice.toStringAsFixed(2)}',
      details,
      payload: 'auction_${date.toIso8601String()}',
    );
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
