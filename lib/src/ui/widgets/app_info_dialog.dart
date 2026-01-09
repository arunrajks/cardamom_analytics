import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cardamom_analytics/src/ui/theme/theme_constants.dart';
import 'package:cardamom_analytics/src/utils/app_preferences.dart';
import 'package:cardamom_analytics/src/services/notification_service.dart';
import 'package:cardamom_analytics/src/localization/app_localizations.dart';
import 'package:cardamom_analytics/src/providers/locale_provider.dart';

class AppInfoDialog extends ConsumerStatefulWidget {
  const AppInfoDialog({super.key});

  @override
  ConsumerState<AppInfoDialog> createState() => _AppInfoDialogState();
}

class _AppInfoDialogState extends ConsumerState<AppInfoDialog> {
  bool _notificationsEnabled = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await AppPreferences.areNotificationsEnabled();
    if (mounted) {
      setState(() {
        _notificationsEnabled = enabled;
        _loading = false;
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      final granted = await NotificationService().requestPermissions();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notification permissions denied.')),
          );
        }
        return;
      }
    }

    await AppPreferences.setNotificationsEnabled(value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ThemeConstants.forestGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/logo.png',
                height: 64,
                width: 64,
              ),
            ),
            const SizedBox(height: 16),
            
            // App Name & Version
            Text(
              l10n.appTitle,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: ThemeConstants.forestGreen,
              ),
            ),
            Text(
              '${l10n.version} 1.2.0',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            const Divider(),
            const SizedBox(height: 16),
            
            // Language Selection
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.language,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildLanguageToggle(context, ref, currentLocale),
            
            const SizedBox(height: 24),
            
            // Notification Settings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _notificationsEnabled 
                        ? Icons.notifications_active_outlined 
                        : Icons.notifications_off_outlined,
                      color: ThemeConstants.forestGreen,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.notifications,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                _loading 
                  ? const SizedBox(
                      width: 24, 
                      height: 24, 
                      child: CircularProgressIndicator(strokeWidth: 2)
                    )
                  : Switch.adaptive(
                      value: _notificationsEnabled,
                      activeColor: ThemeConstants.forestGreen,
                      onChanged: _toggleNotifications,
                    ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConstants.forestGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'OK',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageToggle(BuildContext context, WidgetRef ref, Locale currentLocale) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildLangButton(ref, 'en', 'English', currentLocale.languageCode == 'en'),
          _buildLangButton(ref, 'ml', 'മലയാളം', currentLocale.languageCode == 'ml'),
          _buildLangButton(ref, 'ta', 'தமிழ்', currentLocale.languageCode == 'ta'),
        ],
      ),
    );
  }

  Widget _buildLangButton(WidgetRef ref, String code, String label, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(localeProvider.notifier).setLocale(Locale(code)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? ThemeConstants.forestGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }
}
