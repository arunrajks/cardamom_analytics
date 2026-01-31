import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cardamom_analytics/src/localization/app_localizations.dart';
import 'package:cardamom_analytics/src/ui/theme/theme_constants.dart';
import 'package:cardamom_analytics/src/providers/auction_schedule_provider.dart';
import 'package:cardamom_analytics/src/models/auction_schedule.dart';

class UpcomingAuctionsWidget extends ConsumerWidget {
  const UpcomingAuctionsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final upcomingAsync = ref.watch(upcomingAuctionsProvider);

    return upcomingAsync.when(
      data: (schedules) {
        if (schedules.isEmpty) return const SizedBox.shrink();

        // Group by date to show headers or just show sorted list
        final topSchedules = schedules.take(6).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, color: ThemeConstants.forestGreen, size: 24),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.nextScheduledAuctions,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ThemeConstants.textDark,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, MMM d, yyyy', l10n.locale.languageCode).format(schedules.first.date),
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: topSchedules.length,
                itemBuilder: (context, index) {
                  final schedule = topSchedules[index];
                  return _buildModernAuctionCard(context, schedule, l10n);
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildModernAuctionCard(BuildContext context, AuctionSchedule schedule, AppLocalizations l10n) {
    final isMorning = schedule.session.toLowerCase().contains('morning');
    
    return Container(
      width: 220,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAuctionDetail(context, schedule, l10n, isMorning),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isMorning ? Colors.orange : Colors.deepOrangeAccent).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isMorning ? l10n.morningSession : l10n.afternoonSession,
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isMorning ? Colors.orange.shade800 : Colors.deepOrangeAccent.shade700,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('MMM d', l10n.locale.languageCode).format(schedule.date),
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  schedule.auctioneer,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ThemeConstants.textDark,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        schedule.centre,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAuctionDetail(BuildContext context, AuctionSchedule schedule, AppLocalizations l10n, bool isMorning) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Column(
          children: [
            Icon(
              isMorning ? Icons.wb_sunny : Icons.wb_twilight,
              color: isMorning ? Colors.orange : Colors.deepOrangeAccent,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              isMorning ? l10n.morningSession : l10n.afternoonSession,
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: ThemeConstants.forestGreen),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.translate('auctioneer_label'),
              style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              schedule.auctioneer,
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: ThemeConstants.textDark),
            ),
            const SizedBox(height: 20),
            _buildPopupInfoRow(Icons.calendar_today, l10n.dateLabel, DateFormat('EEEE, MMM d, yyyy', l10n.locale.languageCode).format(schedule.date)),
            const SizedBox(height: 12),
            _buildPopupInfoRow(Icons.access_time, l10n.translate('time_label'), isMorning ? l10n.morningSessionTime : l10n.afternoonSessionTime),
            const SizedBox(height: 12),
            _buildPopupInfoRow(Icons.location_on_outlined, l10n.translate('location_label'), schedule.centre),
            const SizedBox(height: 12),
            if (schedule.number != null)
               _buildPopupInfoRow(Icons.numbers, l10n.translate('auction_no_label'), schedule.number!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.gotIt, style: const TextStyle(color: ThemeConstants.primaryGreen, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text("$label: ", style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: ThemeConstants.textDark),
          ),
        ),
      ],
    );
  }
}
