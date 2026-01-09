import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cardamom_analytics/src/providers/price_provider.dart';
import 'package:cardamom_analytics/src/ui/theme/theme_constants.dart';
import 'package:cardamom_analytics/src/services/price_analytics_service.dart';
import 'package:cardamom_analytics/src/localization/app_localizations.dart';
import 'package:cardamom_analytics/src/utils/app_dates.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(historicalFullPricesProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: ThemeConstants.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.analytics,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        backgroundColor: ThemeConstants.primaryGreen,
        elevation: 0,
      ),
      body: asyncData.when(
        data: (data) {
          if (data.isEmpty) return Center(child: Text(l10n.noDataInsights));
          
          final analytics = ref.read(priceAnalyticsServiceProvider);
          final insights = analytics.getMarketInsights(data);
          final risk = analytics.analyzeRisk(data);
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSmartAdvisoryCard(context, insights, l10n),
                const SizedBox(height: 12),
                _buildDecisionSummaryRow(context, insights, risk, l10n),
                const SizedBox(height: 24),
                _buildMarketRiskStabilitySection(context, risk, insights, l10n),
                const SizedBox(height: 24),
                _buildFarmerProTips(context, insights.farmerAdvisories, l10n),
                const SizedBox(height: 24),
                _buildKeyStatisticsSection(context, insights, l10n),
                const SizedBox(height: 32),
                _buildDisclaimer(l10n, insights, l10n.yearsOfData(insights.dataYearCount)),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading analytics: $err')),
      ),
    );
  }

  void _showHelpDialog(BuildContext context, String title, String description, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(description, style: const TextStyle(fontSize: 14, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.gotIt, style: const TextStyle(fontWeight: FontWeight.bold, color: ThemeConstants.primaryGreen)),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartAdvisoryCard(BuildContext context, MarketInsights insights, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeConstants.primaryGreen,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ThemeConstants.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    l10n.smartAdvisory,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.translate(insights.signal),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            l10n.translate(insights.advice),
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          _buildInsightRow(Icons.calendar_month, "${l10n.currentSeason}: ${l10n.translate(insights.season)}"),
          const SizedBox(height: 8),
          _buildInsightRow(Icons.trending_up, "${l10n.marketStatusLabel}: ${l10n.translate(insights.status)}"),
          const SizedBox(height: 20),
          Text(
            "${insights.confidenceLevel == 'high' ? l10n.confidenceHigh : (insights.confidenceLevel == 'medium' ? l10n.confidenceMedium : l10n.confidenceLow)} (${l10n.yearsOfData(insights.dataYearCount)})",
            style: GoogleFonts.outfit(color: Colors.white60, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildDecisionSummaryRow(BuildContext context, MarketInsights insights, Map<String, dynamic> risk, AppLocalizations l10n) {
    final riskKey = risk['level'];
    final riskColor = riskKey == 'high' ? Colors.red : (riskKey == 'moderate' ? Colors.orange : Colors.green);
    final riskIcon = riskKey == 'high' ? Icons.error_outline : (riskKey == 'moderate' ? Icons.warning_amber_rounded : Icons.check_circle_outline);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF7F0), // Light cream/peach background
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFF3E5D5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.comment_bank, color: Color(0xFF4A4135), size: 20),
          const SizedBox(width: 8),
          Text(
            l10n.decisionSummary,
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13, color: const Color(0xFF4A4135)),
          ),
          const Spacer(),
          _buildDecisionBadge(l10n.sell, insights.signal.contains('sell') ? l10n.yes : l10n.no, insights.signal.contains('sell') ? Colors.green : Colors.red),
          const SizedBox(width: 12),
          _buildDecisionBadge(l10n.hold, insights.signal.contains('hold') ? l10n.yes : l10n.no, insights.signal.contains('hold') ? Colors.green : Colors.red),
          const SizedBox(width: 12),
          Row(
            children: [
              Icon(riskIcon, color: riskColor, size: 14),
              const SizedBox(width: 4),
              Text(
                "${l10n.riskLabel}: ${l10n.translate(riskKey)}",
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF4A4135)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDecisionBadge(String label, String value, Color color) {
    return Row(
      children: [
        Text("$label: ", style: const TextStyle(fontSize: 12, color: Color(0xFF4A4135))),
        Text(
          value,
          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildInsightRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: ThemeConstants.accentGold, size: 18),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }


  Widget _buildMarketRiskStabilitySection(BuildContext context, Map<String, dynamic> risk, MarketInsights insights, AppLocalizations l10n) {
    final riskKey = risk['level'];
    final riskColor = riskKey == 'high' ? Colors.red : (riskKey == 'moderate' ? Colors.orange : Colors.green);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.marketRiskStability,
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: riskColor.withValues(alpha: 0.1),
                    child: Icon(Icons.security, color: riskColor, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${l10n.currentRisk}: ${l10n.translate(riskKey)}",
                          style: TextStyle(color: riskColor, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.translate(risk['message']),
                          style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(color: Color(0xFFF3F0EC)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatLabelValue(context, l10n.volatility30Day, "${risk['volatility'].toStringAsFixed(1)}%", l10n.volatilityHelpTitle, l10n.volatilityHelpDesc, l10n),
                  _buildStatLabelValue(context, l10n.stabilityLevelLabel, "± ₹${insights.stats['stdDev']?.toStringAsFixed(0)}", l10n.stabilityHelpTitle, l10n.stabilityHelpDesc, l10n),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatLabelValue(BuildContext context, String label, String value, String? helpTitle, String? helpDesc, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            if (helpTitle != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _showHelpDialog(context, helpTitle, helpDesc!, l10n),
                child: const Icon(Icons.info_outline, size: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: ThemeConstants.textDark)),
      ],
    );
  }


  Widget _buildFarmerProTips(BuildContext context, List<String> advisories, AppLocalizations l10n) {
    if (advisories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.proTips,
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9E6), // Light yellow background
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFFFECB3)),
          ),
          child: Column(
            children: advisories.map((key) {
              IconData icon = Icons.lightbulb_outline;
              Color iconColor = Colors.amber.shade800;
              
              if (key.contains('high') || key.contains('jump')) {
                icon = Icons.trending_up;
                iconColor = Colors.green;
              } else if (key.contains('low')) {
                icon = Icons.trending_down;
                iconColor = Colors.orange;
              } else if (key.contains('stable') || key.contains('ready')) {
                icon = Icons.check_circle_outline;
                iconColor = Colors.blue;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: iconColor, size: 20),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        l10n.translate(key),
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4A4135),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).take(2).toList(),
          ),
        ),
      ],
    );
  }



  Widget _buildKeyStatisticsSection(BuildContext context, MarketInsights insights, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.keyStatistics,
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              l10n.yearsOfData(insights.dataYearCount),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMultiRowStatCard(
                l10n.priceLevelTitle,
                l10n.lastThreeSeasons,
                Icons.bar_chart,
                Colors.green,
                [
                  _buildCardRow(context, l10n.typicalPriceLabel, "₹${insights.recentMedian.toStringAsFixed(0)}", l10n, helpTitle: l10n.typicalPriceHelpTitle, helpDesc: l10n.typicalPriceHelpDesc),
                  const Divider(height: 24, color: Color(0xFFF3F0EC)),
                  _buildCardRow(context, l10n.normalRangeSeasonal, "₹${insights.recentNormalRangeMin.toStringAsFixed(0)} - ${insights.recentNormalRangeMax.toStringAsFixed(0)}", l10n, helpTitle: l10n.normalRangeHelpTitle, helpDesc: l10n.normalRangeHelpDesc),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMultiRowStatCard(
                l10n.highestLowestTitle,
                l10n.exceptionalYears,
                Icons.unfold_more,
                Colors.orange,
                [
                  _buildCardRow(context, l10n.highestSeenLabel, "₹${insights.stats['max']?.toStringAsFixed(0)}", l10n, badge: l10n.rareLabel, badgeColor: Colors.orange, helpTitle: l10n.highestSeenHelpTitle, helpDesc: l10n.highestSeenHelpDesc),
                  const Divider(height: 24, color: Color(0xFFF3F0EC)),
                  _buildCardRow(context, l10n.lowestSeenLabel, "₹${insights.stats['min']?.toStringAsFixed(0)}", l10n, badge: l10n.rareLabel, badgeColor: Colors.blue, helpTitle: l10n.lowestSeenHelpTitle, helpDesc: l10n.lowestSeenHelpDesc),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMultiRowStatCard(String title, String subtitle, IconData icon, Color color, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: ThemeConstants.textDark)),
                    Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCardRow(BuildContext context, String label, String value, AppLocalizations l10n, {String? badge, Color? badgeColor, String? helpTitle, String? helpDesc}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            if (helpTitle != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _showHelpDialog(context, helpTitle, helpDesc!, l10n),
                child: const Icon(Icons.info_outline, size: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: ThemeConstants.textDark)),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: badgeColor?.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(badge, style: TextStyle(color: badgeColor, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ],
    );
  }



  Widget _buildDisclaimer(AppLocalizations l10n, MarketInsights insights, String countLabel) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F6F0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 20, color: Colors.grey),
                  const SizedBox(width: 12),
                  Text(
                    l10n.confidenceNote,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                l10n.disclaimerText,
                style: const TextStyle(fontSize: 13, color: Colors.blueGrey, height: 1.5),
              ),
              if (insights.firstDataDate != null && insights.lastDataDate != null) ...[
                const SizedBox(height: 12),
                Text(
                  "Data Range: ${AppDates.ui.format(insights.firstDataDate!)} - ${AppDates.ui.format(insights.lastDataDate!)}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
