import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cardamom_analytics/src/providers/price_provider.dart';
import 'package:cardamom_analytics/src/ui/theme/theme_constants.dart';
import 'package:cardamom_analytics/src/services/price_analytics_service.dart';
import 'package:cardamom_analytics/src/localization/app_localizations.dart';

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
                const SizedBox(height: 24),
                _buildMarketPerformanceSection(context, insights, l10n),
                const SizedBox(height: 24),
                _buildFarmerProTips(context, insights.farmerAdvisories, l10n),
                const SizedBox(height: 24),
                _buildRiskSection(context, risk, l10n),
                const SizedBox(height: 24),
                _buildKeyStatisticsSection(context, insights, l10n),
                const SizedBox(height: 24),
                _buildWhatThisMeansPanel(context, insights, l10n),
                const SizedBox(height: 32),
                _buildDisclaimer(l10n),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading analytics: $err')),
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
              Text(
                l10n.smartAdvisory,
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.translate(insights.signal),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.translate(insights.advice),
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          _buildInsightRow(Icons.calendar_month, "${l10n.currentSeason}: ${l10n.translate(insights.season)}"),
          const SizedBox(height: 8),
          _buildInsightRow(Icons.trending_up, "${l10n.marketStatusLabel}: ${l10n.translate(insights.status)}"),
        ],
      ),
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

  Widget _buildRiskSection(BuildContext context, Map<String, dynamic> risk, AppLocalizations l10n) {
    String riskKey = risk['level'];
    Color riskColor = riskKey == 'high' ? Colors.red : (riskKey == 'moderate' ? Colors.orange : Colors.green);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.riskAnalysis,
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: riskColor.withValues(alpha: 0.3), width: 1),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: riskColor.withValues(alpha: 0.1),
                child: Icon(Icons.warning_amber_rounded, color: riskColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${l10n.currentRisk}: ${l10n.translate(riskKey)}",
                      style: TextStyle(color: riskColor, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.translate(risk['message']),
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${l10n.volatility30Day}: ${risk['volatility'].toStringAsFixed(1)}%",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMarketPerformanceSection(BuildContext context, MarketInsights insights, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.marketPerformance,
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              _buildPerformanceRow(l10n.vsLastYear.replaceAll(':', ''), insights.vsLastYear),
              const Divider(height: 24),
              _buildPerformanceRow(l10n.vsFiveYearAvg.replaceAll(':', ''), insights.vsFiveYearAvg),
              const Divider(height: 24),
              _buildPerformanceRow(l10n.vsLongTermAvg.replaceAll(':', ''), insights.vsLongTermAvg),
            ],
          ),
        ),
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
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: advisories.map((key) {
              IconData icon = Icons.lightbulb_outline;
              Color iconColor = Colors.amber.shade800;
              
              if (key.contains('high')) {
                icon = Icons.trending_up;
                iconColor = Colors.green;
              } else if (key.contains('low')) {
                icon = Icons.trending_down;
                iconColor = Colors.orange;
              } else if (key.contains('stable')) {
                icon = Icons.check_circle_outline;
                iconColor = Colors.blue;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: iconColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.translate(key),
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: ThemeConstants.textDark,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceRow(String label, double value) {
    final isPositive = value >= 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
        Row(
          children: [
            Icon(
              isPositive ? Icons.arrow_upward : Icons.arrow_downward,
              size: 14,
              color: isPositive ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 4),
            Text(
              '${value.abs().toStringAsFixed(1)}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isPositive ? Colors.green : Colors.red,
              ),
            ),
          ],
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
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              l10n.keyStatistics,
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              l10n.yearsOfData(insights.dataYearCount),
              style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
          children: [
            // PRICE LEVEL (SEASONAL)
            _buildStatCard(
              l10n.priceLevelTitle,
              l10n.lastThreeSeasons,
              Icons.bar_chart,
              Colors.green,
              [
                _buildStatSubRow(l10n.typicalPriceLabel, "₹${insights.recentMedian.toStringAsFixed(0)}"),
                const Divider(),
                _buildStatSubRow(l10n.normalRangeSeasonal, "₹${insights.recentNormalRangeMin.toStringAsFixed(0)} - ${insights.recentNormalRangeMax.toStringAsFixed(0)}"),
              ],
            ),
            // HIGHEST & LOWEST
            _buildStatCard(
              l10n.highestLowestTitle,
              l10n.tenYearsLabel,
              Icons.unfold_more,
              Colors.orange,
              [
                _buildStatSubRowWithBadge(l10n.highestSeenLabel, "₹${insights.stats['max']?.toStringAsFixed(0)}", l10n.rareLabel, Colors.orange),
                const Divider(),
                _buildStatSubRowWithBadge(l10n.lowestSeenLabel, "₹${insights.stats['min']?.toStringAsFixed(0)}", l10n.rareLabel, Colors.blue),
              ],
            ),
            // PRICE STABILITY
            _buildStatCard(
              l10n.priceStabilityTitle,
              "",
              Icons.warning_amber_rounded,
              Colors.amber,
              [
                _buildStatSubRow(l10n.stabilityLevelLabel, "₹${insights.stats['mean']?.toStringAsFixed(0)} ± ₹${insights.stats['stdDev']?.toStringAsFixed(0)}"),
              ],
            ),
            // PRICE SPREAD
            _buildStatCard(
              l10n.priceSpreadTitle,
              l10n.translate(insights.spreadLevel),
              Icons.trending_up,
              Colors.red,
              [
                _buildStatSubRow(l10n.distanceLabel, ""),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String subtitle, IconData icon, Color color, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: ThemeConstants.textDark)),
                    if (subtitle.isNotEmpty)
                      Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatSubRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        if (value.isNotEmpty)
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: ThemeConstants.textDark)),
      ],
    );
  }

  Widget _buildStatSubRowWithBadge(String label, String value, String badgeText, Color badgeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: ThemeConstants.textDark)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(badgeText, style: TextStyle(color: badgeColor, fontSize: 9, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWhatThisMeansPanel(BuildContext context, MarketInsights insights, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F6F0),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E1D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.comment_outlined, color: Color(0xFF8D7B5F), size: 20),
              const SizedBox(width: 8),
              Text(l10n.keyInsightTitle, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A4135))),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.whatThisMeansTitle,
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF2D4B3F)),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.translate(insights.spreadMessage),
            style: const TextStyle(color: Colors.blueGrey, height: 1.5, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(l10n.confidenceNote, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.disclaimerText,
            style: const TextStyle(fontSize: 11, color: Colors.blueGrey, height: 1.5),
          ),
        ],
      ),
    );
  }
}
