import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cardamom_analytics/src/providers/price_provider.dart';
import 'package:cardamom_analytics/src/ui/theme/theme_constants.dart';
import 'package:cardamom_analytics/src/services/price_analytics_service.dart';
import 'package:cardamom_analytics/src/localization/app_localizations.dart';
import 'package:cardamom_analytics/src/utils/app_dates.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

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
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: ThemeConstants.textDark),
        ),
        backgroundColor: ThemeConstants.creamApp,
        elevation: 0,
        iconTheme: const IconThemeData(color: ThemeConstants.primaryGreen),
      ),
      body: asyncData.when(
        data: (data) {
          if (data.isEmpty) return Center(child: Text(l10n.noDataInsights));
          
          final analytics = ref.read(priceAnalyticsServiceProvider);
          final insights = analytics.getMarketInsights(data);
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSmartAdvisoryCard(context, insights, l10n),
                const SizedBox(height: 16),
                _buildMarketVerdictSection(context, insights, l10n),
                const SizedBox(height: 24),
                _buildFarmerProTips(context, insights, l10n),
                const SizedBox(height: 24),
                _buildKeyStatisticsSection(context, insights, l10n),
                const SizedBox(height: 24),
                _buildMarketRiskDetailsCollapsible(context, insights, l10n),
                const SizedBox(height: 32),
                _buildDisclaimer(l10n, insights),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('${l10n.translate('error_loading_analytics')}: $err')),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThemeConstants.primaryGreen,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ThemeConstants.primaryGreen.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l10n.smartAdvisory,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              _buildStatusPill(context, insights, l10n),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            l10n.translate(insights.advice),
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 10,
            children: [
              _buildMetaInfo(Icons.calendar_month, "${l10n.currentSeason}: ${l10n.translate(insights.season)}"),
              _buildMetaInfo(Icons.trending_up, "${l10n.marketStatusLabel}: ${l10n.translate(insights.status).toUpperCase()}"),
            ],
          ),
          const SizedBox(height: 12),
          _buildMetaInfo(
            Icons.info_outline, 
            "${insights.confidenceLevel == 'high' ? l10n.confidenceHigh : (insights.confidenceLevel == 'medium' ? l10n.confidenceMedium : l10n.confidenceLow)}"
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(BuildContext context, MarketInsights insights, AppLocalizations l10n) {
    Color pillColor;
    switch (insights.verdictAction) {
      case 'good_time_to_sell': pillColor = Colors.greenAccent; break;
      case 'be_cautious': pillColor = ThemeConstants.actionOrange; break;
      default: pillColor = Colors.white70;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        l10n.translate(insights.verdictAction),
        style: TextStyle(color: pillColor, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildMetaInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white54, size: 16),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildMarketVerdictSection(BuildContext context, MarketInsights insights, AppLocalizations l10n) {
    Color actionColor;
    IconData actionIcon;
    switch (insights.verdictAction) {
      case 'good_time_to_sell': actionColor = Colors.green; actionIcon = Icons.check_circle_outline; break;
      case 'be_cautious': actionColor = ThemeConstants.actionOrange; actionIcon = Icons.warning_amber_rounded; break;
      default: actionColor = Colors.blue; actionIcon = Icons.hourglass_empty;
    }

    Color riskColor;
    IconData riskIcon;
    switch (insights.verdictRisk) {
      case 'risk_high': riskColor = Colors.red; riskIcon = Icons.error_outline; break;
      case 'risk_moderate': riskColor = ThemeConstants.actionOrange; riskIcon = Icons.warning_outlined; break;
      default: riskColor = Colors.green; riskIcon = Icons.shield_outlined;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.marketVerdict,
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: ThemeConstants.sectionOrange),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildVerdictChip(
              context,
              l10n.actionLabel, 
              l10n.translate(insights.verdictAction), 
              actionIcon, 
              actionColor
            ),
            _buildVerdictChip(
              context,
              "${l10n.riskLabel}:", 
              l10n.translate(insights.verdictRisk), 
              riskIcon, 
              riskColor
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVerdictChip(BuildContext context, String label, String value, IconData icon, Color color) {
    final width = (MediaQuery.of(context).size.width - 44) / 2; // 16*2 padding + 12 spacing
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.7), fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  value, 
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: color, height: 1.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildInsightRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ),
      ],
    );
  }


  Widget _buildMarketRiskDetailsCollapsible(BuildContext context, MarketInsights insights, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            l10n.marketRiskDetailsTitle,
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: ThemeConstants.textDark),
          ),
          trailing: const Icon(Icons.keyboard_arrow_down, color: ThemeConstants.neutralGrey),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildStatLabelValue(
                    context, 
                    l10n.volatility30Day, 
                    "${insights.thirtyDayChange >= 0 ? '+' : ''}${insights.thirtyDayChange.toStringAsFixed(1)}%", 
                    l10n.volatilityHelpTitle, 
                    l10n.volatilityHelpDesc, 
                    l10n,
                    valueColor: insights.thirtyDayChange > 0 ? ThemeConstants.secondaryGreen : (insights.thirtyDayChange < 0 ? ThemeConstants.alertRed : ThemeConstants.textDark),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatLabelValue(
                    context, 
                    l10n.stabilityLevelLabel, 
                    "± ₹${insights.thirtyDayStdDev.toStringAsFixed(0)}", 
                    l10n.stabilityHelpTitle, 
                    l10n.stabilityHelpDesc, 
                    l10n
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatLabelValue(BuildContext context, String label, String value, String? helpTitle, String? helpDesc, AppLocalizations l10n, {Color? valueColor}) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11), softWrap: true),
            ),
            if (helpTitle != null) ...[
              const SizedBox(width: 4),
              const Icon(Icons.info_outline, size: 12, color: Colors.grey),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: valueColor ?? ThemeConstants.textDark)),
      ],
    );

    if (helpTitle != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _showHelpDialog(context, helpTitle, helpDesc!, l10n),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: content,
        ),
      );
    }
    return content;
  }


  Widget _buildFarmerProTips(BuildContext context, MarketInsights insights, AppLocalizations l10n) {
    // Collect all possible tip strings
    final List<String> availableTips = [];

    // 1. Combined Price Comparison (Hybrid: YoY + Hist)
    availableTips.add(
      l10n.translate('combined_comparison_desc')
        .replaceAll('{yoy_pct}', insights.vsLastYear.abs().toStringAsFixed(1))
        .replaceAll('{yoy_level}', l10n.translate(insights.vsLastYear >= 0 ? 'level_higher' : 'level_lower'))
        .replaceAll('{hist_pct}', insights.pctVsNormal.abs().toStringAsFixed(1))
        .replaceAll('{hist_level}', l10n.translate(insights.pctVsNormal >= 0 ? 'level_higher' : 'level_lower'))
        .replaceAll('{month}', l10n.translate('month_${insights.lastDataDate?.month ?? DateTime.now().month}'))
    );

    // 2. This Week Performance (High Priority)
    availableTips.add(
      l10n.translate('this_week_desc')
        .replaceAll('{direction}', l10n.translate(insights.weeklyMomentum >= 0.5 ? 'direction_up' : (insights.weeklyMomentum <= -0.5 ? 'direction_down' : 'direction_sideways')))
        .replaceAll('{pct}', insights.weeklySummary)
    );

    // 3. Seasonal Insight (High Priority)
    if (insights.seasonalPeakMonths.isNotEmpty) {
      String pattern;
      if (insights.seasonalPeakMonths.length == 1) {
        pattern = l10n.translate('month_${insights.seasonalPeakMonths[0]}');
      } else if (insights.seasonalPeakMonths.length == 2) {
        pattern = "${l10n.translate('month_${insights.seasonalPeakMonths[0]}')} & ${l10n.translate('month_${insights.seasonalPeakMonths[1]}')}";
      } else {
        final lastMonth = insights.seasonalPeakMonths.last;
        final otherMonths = insights.seasonalPeakMonths.sublist(0, insights.seasonalPeakMonths.length - 1);
        pattern = "${otherMonths.map((m) => l10n.translate('month_$m')).join(', ')} & ${l10n.translate('month_$lastMonth')}";
      }
      
      availableTips.add(
        l10n.translate('seasonal_insight_desc').replaceAll('{pattern}', pattern)
      );
    }

    // 4. Market Stability (Fallback / Secondary)
    if (availableTips.length < 3) {
      availableTips.add("${l10n.translate(insights.stabilityMessage)} ${l10n.translate('stability_advice_${insights.stabilityMessage.split('_')[0]}')}");
    }

    // 5. Traditional Advisories (Fallback)
    for (var key in insights.farmerAdvisories) {
      if (availableTips.length >= 3) break;
      String tipText = l10n.translate(key);
      if (key.contains('seasonal') && insights.lastDataDate != null) {
        final monthDate = key.contains('next')
            ? DateTime(insights.lastDataDate!.year, insights.lastDataDate!.month + 1)
            : insights.lastDataDate!;
        final monthName = DateFormat('MMMM', l10n.locale.languageCode).format(monthDate);
        tipText = tipText.replaceAll('{month}', monthName);
      }
      availableTips.add(tipText);
    }

    // Final selection: Maximum 3 tips
    final finalTips = availableTips.take(3).toList();
    if (finalTips.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: ThemeConstants.sectionOrange, size: 22),
            const SizedBox(width: 8),
            Text(
              l10n.proTips,
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: ThemeConstants.sectionOrange),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildRefinedInsightCard(
          color: const Color(0xFFFFF9E6),
          borderColor: const Color(0xFFFFECB3),
          children: finalTips.map((tipText) => _buildBulletPoint(tipText)).toList(),
        ),
      ],
    );
  }

  Widget _buildRefinedSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: ThemeConstants.textDark.withValues(alpha: 0.7), size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: ThemeConstants.textDark),
        ),
      ],
    );
  }

  Widget _buildRefinedInsightCard({required Color color, required Color borderColor, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildBulletPoint(String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color ?? const Color(0xFF4A4135))),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color ?? const Color(0xFF4A4135),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
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
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: ThemeConstants.sectionOrange),
            ),
          ],
        ),
        const SizedBox(height: 16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildMultiRowStatCard(
                  l10n.priceLevelTitle,
                  l10n.lastThreeSeasons,
                  Icons.bar_chart,
                  Colors.green,
                  [
                    _buildPriceLevelChart(context, insights, l10n),
                  ],
                  helpTitle: l10n.priceLevelHelpTitle,
                  helpDesc: l10n.priceLevelHelpDesc,
                  l10n: l10n,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMultiRowStatCard(
                  l10n.highestLowestTitle,
                  l10n.translate('full_history_label').replaceAll('{count}', insights.totalDataYearCount.toString()),
                  Icons.unfold_more,
                  ThemeConstants.actionOrange,
                  [
                    _buildCardRow(
                      context, 
                      l10n.highestSeenLabel, 
                      "₹${insights.fullStats['max']?.toStringAsFixed(0)}", 
                      l10n, 
                      icon: Icons.trending_up,
                      iconColor: Colors.green,
                      suffix: insights.highestPriceYear > 0 ? "(${insights.highestPriceYear})" : null,
                      badge: l10n.rareLabel, 
                      badgeColor: ThemeConstants.actionOrange, 
                      helpTitle: l10n.highestSeenHelpTitle, 
                      helpDesc: l10n.highestSeenHelpDesc
                    ),
                    const Divider(height: 24, color: Color(0xFFF3F0EC)),
                    _buildCardRow(
                      context, 
                      l10n.lowestSeenLabel, 
                      "₹${insights.fullStats['min']?.toStringAsFixed(0)}", 
                      l10n, 
                      icon: Icons.trending_down,
                      iconColor: Colors.red,
                      suffix: insights.lowestPriceYear > 0 ? "(${insights.lowestPriceYear})" : null,
                      badge: l10n.rareLabel, 
                      badgeColor: Colors.blue, 
                      helpTitle: l10n.lowestSeenHelpTitle, 
                      helpDesc: l10n.lowestSeenHelpDesc
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            l10n.translate('average_disclaimer'),
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiRowStatCard(String title, String subtitle, IconData icon, Color color, List<Widget> children, {bool noHorizontalPadding = false, String? helpTitle, String? helpDesc, AppLocalizations? l10n}) {
    final header = Padding(
      padding: EdgeInsets.symmetric(horizontal: noHorizontalPadding ? 20 : 0),
      child: Row(
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
                Row(
                  children: [
                    Expanded(
                      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: ThemeConstants.textDark)),
                    ),
                    if (helpTitle != null) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.info_outline, size: 12, color: ThemeConstants.neutralGrey),
                    ],
                  ],
                ),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: noHorizontalPadding ? 0 : 20,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (helpTitle != null && l10n != null)
            Builder(
              builder: (context) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _showHelpDialog(context, helpTitle, helpDesc!, l10n),
                child: header,
              ),
            )
          else
            header,
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPriceLevelChart(BuildContext context, MarketInsights insights, AppLocalizations l10n) {
    if (insights.seasonalAverages.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(child: Text(l10n.translate('no_seasonal_data'))),
      );
    }

    final data = insights.seasonalAverages;
    
    // Calculate "Nice" Y-Axis Range
    final values = data.map((e) => e.value).toList();
    double rawMin = values.reduce(min);
    double rawMax = values.reduce(max);
    
    // Add tight margin
    rawMin = rawMin * 0.99;
    rawMax = rawMax * 1.02; // Reduced from 1.15 to prevent large white space
    
    double range = rawMax - rawMin;
    double interval;
    if (range <= 200) interval = 50;
    else if (range <= 500) interval = 100;
    else interval = 200;

    double minY = (rawMin / interval).floorToDouble() * interval;
    double maxY = (rawMax / interval).ceilToDouble() * interval;

    return Column(
      children: [
        SizedBox(
          height: 180, // Increased height for better visibility
          child: Padding(
            padding: const EdgeInsets.only(top: 30, right: 10, left: 0),
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (data.length - 1).toDouble(),
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withValues(alpha: 0.05),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: interval,
                      getTitlesWidget: (val, meta) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          '₹${NumberFormat("#,###").format(val.toInt())}',
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                      reservedSize: 45,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < 0 || index >= data.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            data[index].key,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                      interval: 1,
                      reservedSize: 28,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1), width: 1),
                  ),
                ),
                showingTooltipIndicators: data.asMap().entries.map((e) {
                  return ShowingTooltipIndicators([
                    LineBarSpot(
                      LineChartBarData(spots: []), 0, FlSpot(e.key.toDouble(), e.value.value),
                    ),
                  ]);
                }).toList(),
                lineBarsData: [
                  LineChartBarData(
                    spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: ThemeConstants.primaryGreen,
                    barWidth: 3.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 5,
                        color: Colors.white,
                        strokeWidth: 3,
                        strokeColor: ThemeConstants.primaryGreen,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          ThemeConstants.primaryGreen.withValues(alpha: 0.15),
                          ThemeConstants.primaryGreen.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: false,
                  handleBuiltInTouches: false,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (spot) => Colors.transparent,
                    tooltipPadding: EdgeInsets.zero,
                    tooltipMargin: 10,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        return LineTooltipItem(
                          "₹${NumberFormat("#,###").format(barSpot.y)}",
                          GoogleFonts.outfit(
                            color: ThemeConstants.textDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: ThemeConstants.secondaryGreen.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.avgPrice,
              style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardRow(BuildContext context, String label, String value, AppLocalizations l10n, {IconData? icon, String? suffix, Color? iconColor, String? badge, Color? badgeColor, String? helpTitle, String? helpDesc}) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Icon(icon, color: iconColor ?? Colors.grey, size: 20),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  if (helpTitle != null) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.info_outline, size: 12, color: ThemeConstants.neutralGrey),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: value,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: ThemeConstants.textDark,
                          ),
                        ),
                        if (suffix != null)
                          TextSpan(
                            text: " $suffix",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: badgeColor?.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(badge, style: TextStyle(color: badgeColor, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    if (helpTitle != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _showHelpDialog(context, helpTitle, helpDesc!, l10n),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: content,
        ),
      );
    }
    return content;
  }



  Widget _buildDisclaimer(AppLocalizations l10n, MarketInsights insights) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: ThemeConstants.softGreen,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 20, color: ThemeConstants.neutralGrey),
                  const SizedBox(width: 12),
                  Text(
                    l10n.confidenceNote,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14, color: ThemeConstants.neutralGrey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                l10n.disclaimerText,
                style: const TextStyle(fontSize: 13, color: ThemeConstants.textDark, height: 1.5),
              ),
              if (insights.firstDataDate != null && insights.lastDataDate != null) ...[
                const SizedBox(height: 12),
                Text(
                  "${l10n.translate('data_range')}: ${AppDates.ui.format(insights.firstDataDate!)} - ${AppDates.ui.format(insights.lastDataDate!)}",
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
