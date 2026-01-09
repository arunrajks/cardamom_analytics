import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cardamom_analytics/src/providers/price_provider.dart';
import 'package:cardamom_analytics/src/models/auction_data.dart';
import 'package:cardamom_analytics/src/utils/app_dates.dart';
import 'package:cardamom_analytics/src/localization/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cardamom_analytics/src/ui/theme/theme_constants.dart';
import 'package:cardamom_analytics/src/services/price_analytics_service.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class HistoricalDataScreen extends ConsumerStatefulWidget {
  const HistoricalDataScreen({super.key});

  @override
  ConsumerState<HistoricalDataScreen> createState() => _HistoricalDataScreenState();
}

class _HistoricalDataScreenState extends ConsumerState<HistoricalDataScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _isImporting = false;
  final double _importProgress = 0.0;
  String? _statusMessage;

  @override
  Widget build(BuildContext context) {
    final historicalDataAsync = ref.watch(historicalPricesProvider(fromDate: _fromDate, toDate: _toDate));
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(l10n.historicalData, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () {
              final data = ref.read(historicalPricesProvider(fromDate: _fromDate, toDate: _toDate)).value ?? [];
              _exportToExcel(data);
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync_outlined),
            onPressed: () => _syncData(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'clear') _clearAllData();
              if (value == 'reseed') _reseedData();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'reseed',
                child: Row(children: [const Icon(Icons.restore, size: 20), const SizedBox(width: 8), Text(l10n.forceReseedLocal)]),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'clear',
                child: Text(l10n.clearAllData, style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
      body: historicalDataAsync.when(
        data: (data) {
          if (data.isEmpty) {
            return _buildEmptyState(l10n);
          }
          return _buildMainContent(data, l10n);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_toggle_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(l10n.noHistoricalData, style: GoogleFonts.outfit(fontSize: 16)),
          const SizedBox(height: 8),
          Text(l10n.clickSyncHint, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _syncData(),
            icon: const Icon(Icons.sync),
            label: Text(l10n.syncNow),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(List<AuctionData> data, AppLocalizations l10n) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              if (_statusMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.green.shade50,
                  child: Text(_statusMessage!, style: const TextStyle(color: Colors.green, fontSize: 13), textAlign: TextAlign.center),
                ),
              _buildDateRangeSelector(l10n),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildChartWithBadge(data, l10n),
              ),
              const SizedBox(height: 12),
              _buildRangeStatsSummary(data, l10n),
              const SizedBox(height: 12),
              _buildTrendInsight(data, l10n),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    data.isEmpty ? "" : 
                    (() {
                      final first = data.first.date;
                      final now = DateTime.now();
                      final yesterday = now.subtract(const Duration(days: 1));
                      final fmt = DateFormat('yyyy-MM-dd');
                      if (fmt.format(first) == fmt.format(now)) return l10n.today;
                      if (fmt.format(first) == fmt.format(yesterday)) return l10n.yesterday;
                      return DateFormat('MMMM d', l10n.locale.languageCode).format(first);
                    })(),
                    style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final current = data[index];
                // Accessing previous session for percentage change calculation
                // List is descending, so previous session is at index + 1
                AuctionData? previous;
                if (index + 1 < data.length) {
                  previous = data[index + 1];
                }
                return _buildAuctionCard(current, l10n, previous: previous);
              },
              childCount: data.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeSelector(AppLocalizations l10n) {
    final rangeText = _fromDate == null ? "All Time" : 
      (() {
        final startLine = DateFormat('MMM yyyy', l10n.locale.languageCode).format(_fromDate!);
        final endLine = DateFormat('MMM yyyy', l10n.locale.languageCode).format(_toDate ?? DateTime.now());
        return startLine == endLine ? startLine : "$startLine \u2192 $endLine";
      })();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _pickDateRange(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        rangeText,
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Icon(Icons.tune, color: Color(0xFF1B4332), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildChartWithBadge(List<AuctionData> data, AppLocalizations l10n) {
    if (data.length < 2) return const SizedBox.shrink();

    final days = _toDate != null && _fromDate != null ? _toDate!.difference(_fromDate!).inDays : 
                 data.first.date.difference(data.last.date).inDays.abs();
    
    String rangeLabel = l10n.rangeShown("${(days/365).toStringAsFixed(1)} years");
    if (days < 365) rangeLabel = l10n.rangeShown("${(days/30).toStringAsFixed(1)} months");
    if (days < 30) rangeLabel = l10n.rangeShown("$days days");

    return Stack(
      children: [
        Container(
          height: 220,
          padding: const EdgeInsets.fromLTRB(8, 30, 8, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: _buildChart(data),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(rangeLabel, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ),
        ),
      ],
    );
  }

  Widget _buildRangeStatsSummary(List<AuctionData> data, AppLocalizations l10n) {
    if (data.isEmpty) return const SizedBox.shrink();

    final maxPrice = data.fold<double>(0, (prev, e) => e.avgPrice > prev ? e.avgPrice : prev);
    final minPrice = data.fold<double>(data.first.avgPrice, (prev, e) => e.avgPrice < prev ? e.avgPrice : prev);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFDF7F2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(child: Text(l10n.highestInRange, style: GoogleFonts.outfit(fontSize: 13, color: Colors.black87))),
                      Text("₹${NumberFormat("#,##0").format(maxPrice)}", style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              VerticalDivider(color: Colors.grey.shade300, width: 1, indent: 12, endIndent: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(child: Text(l10n.lowestInRange, style: GoogleFonts.outfit(fontSize: 13, color: Colors.black87))),
                      Text("₹${NumberFormat("#,##0").format(minPrice)}", style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendInsight(List<AuctionData> data, AppLocalizations l10n) {
    final avg = data.isEmpty ? 0 : data.fold<double>(0, (sum, e) => sum + e.avgPrice) / data.length;
    // Assume 10-year historical average is around 1800 for context if not enough data
    const historicalNorm = 1800.0;
    final isAbove = avg > historicalNorm;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Icon(isAbove ? Icons.north_east : Icons.south_east, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isAbove ? l10n.aboveAverage : l10n.belowAverage,
              style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuctionCard(AuctionData auction, AppLocalizations l10n, {AuctionData? previous}) {
    double percentageChange = 0.0;
    bool isIncrease = true;
    
    if (previous != null && previous.avgPrice > 0) {
      percentageChange = ((auction.avgPrice - previous.avgPrice) / previous.avgPrice) * 100;
      isIncrease = percentageChange >= 0;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "₹${NumberFormat("#,##0").format(auction.avgPrice)}/kg",
                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          if (previous != null) ...[
                            const SizedBox(width: 8),
                            Icon(isIncrease ? Icons.arrow_upward : Icons.arrow_downward, size: 14, color: isIncrease ? Colors.green : Colors.red),
                            Text(
                              "${isIncrease ? "+" : ""}${percentageChange.toStringAsFixed(1)}%", 
                              style: TextStyle(color: isIncrease ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.w600)
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        auction.auctioneer.toUpperCase(),
                        style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade800, height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Text("${NumberFormat("#,##0").format(auction.quantity)} kg", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<AuctionData> data) {
    // Sort chronological for calculations
    final chronData = List<AuctionData>.from(data)..sort((a,b) => a.date.compareTo(b.date));
    
    // Get performance points (SMA + Bands) using 14-day period
    final performance = PriceAnalyticsService().getPricePerformance(chronData, period: 7); // Use 7-day for faster responsiveness on filtered ranges
    
    List<FlSpot> actualSpots = [];
    List<FlSpot> smaSpots = [];
    List<FlSpot> upperSpots = [];
    List<FlSpot> lowerSpots = [];
    
    // If we have performance points, use them. Otherwise fallback to basic spots.
    if (performance.isNotEmpty) {
      for (int i = 0; i < performance.length; i++) {
        final p = performance[i];
        actualSpots.add(FlSpot(i.toDouble(), p.actual));
        smaSpots.add(FlSpot(i.toDouble(), p.sma));
        upperSpots.add(FlSpot(i.toDouble(), p.upperBand));
        lowerSpots.add(FlSpot(i.toDouble(), p.lowerBand));
      }
    } else {
      for (int i = 0; i < chronData.length; i++) {
        actualSpots.add(FlSpot(i.toDouble(), chronData[i].avgPrice));
      }
    }

    final avgPrice = data.fold<double>(0, (sum, e) => sum + e.avgPrice) / data.length;

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => Colors.white.withValues(alpha: 0.9),
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              // Calculate total bars to find the Actual Price (which is the last one in our list)
              int totalBars = 1; // Actual Price is always there
              if (performance.isNotEmpty) {
                if (upperSpots.isNotEmpty) totalBars++;
                if (lowerSpots.isNotEmpty) totalBars++;
                if (smaSpots.isNotEmpty) totalBars++;
              }
              
              return touchedSpots.map((spot) {
                // Return tooltip only for the main "Actual Price" bar
                if (spot.barIndex != totalBars - 1) return null; 
                
                final date = chronData[spot.x.toInt()].date;
                return LineTooltipItem(
                  "${DateFormat('dd MMM yyyy').format(date)}\n₹${NumberFormat("#,###").format(spot.y)}",
                  GoogleFonts.outfit(
                    color: const Color(0xFF1B4332),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 500,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true, 
                reservedSize: 45,
                getTitlesWidget: (value, meta) => Text(NumberFormat("#,###").format(value), style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ),
            ),
            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          // Volatility Bands (Upper)
          if (upperSpots.isNotEmpty)
            LineChartBarData(
              spots: upperSpots,
              isCurved: true,
              color: Colors.grey.withOpacity(0.1),
              barWidth: 1,
              dotData: const FlDotData(show: false),
            ),
          // Volatility Bands (Lower)
          if (lowerSpots.isNotEmpty)
            LineChartBarData(
              spots: lowerSpots,
              isCurved: true,
              color: Colors.grey.withOpacity(0.1),
              barWidth: 1,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.grey.withOpacity(0.03),
                cutOffY: 0,
                applyCutOffY: false,
              ),
            ),
          // Moving Average (SMA)
          if (smaSpots.isNotEmpty)
            LineChartBarData(
              spots: smaSpots,
              isCurved: true,
              color: Colors.orange.withOpacity(0.3),
              barWidth: 1.5,
              dotData: const FlDotData(show: false),
            ),
          // Actual Price
          LineChartBarData(
            spots: actualSpots,
            isCurved: true,
            color: const Color(0xFF1B4332),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [const Color(0xFF1B4332).withOpacity(0.1), const Color(0xFF1B4332).withOpacity(0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: avgPrice,
              color: const Color(0xFF1B4332).withOpacity(0.3),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
      initialDateRange: _fromDate != null && _toDate != null ? DateTimeRange(start: _fromDate!, end: _toDate!) : null,
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
    }
  }

  Future<void> _syncData({int pages = 20}) async {
    final l10n = AppLocalizations.of(context);
    try {
      setState(() {
         _isImporting = true; // Use importing state for progress bar
         _statusMessage = l10n.syncingServer;
      });
      
      final syncService = ref.read(syncServiceProvider);
      int count = await syncService.syncNewData(maxPages: pages);
      
      setState(() {
         _isImporting = false;
         _statusMessage = l10n.syncComplete(count);
      });
      
      ref.invalidate(historicalPricesProvider);
      
    } catch (e) {
      setState(() {
         _isImporting = false;
         _statusMessage = "${l10n.syncFailed} $e";
      });
    }
  }

  Future<void> _clearAllData() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearDataConfirm),
        content: Text(l10n.clearDataDesc),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.clear, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(databaseHelperProvider).deleteAll();
      ref.invalidate(historicalPricesProvider);
      setState(() {
        _statusMessage = l10n.clearAllData;
      });
    }
  }

  Future<void> _reseedData() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isImporting = true;
      _statusMessage = l10n.reseedAttempt;
    });
    
    try {
      int count = await ref.read(dataSeederServiceProvider).seedData(force: true);
      ref.invalidate(historicalPricesProvider);
      setState(() {
        _isImporting = false;
        _statusMessage = l10n.reseedComplete(count);
      });
    } catch (e) {
      setState(() {
        _isImporting = false;
        _statusMessage = "${l10n.reseedFailed} $e";
      });
    }
  }

  Future<void> _exportToExcel(List<AuctionData> data) async {
    final l10n = AppLocalizations.of(context);
    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noHistoricalData)),
      );
      return;
    }

    try {
      final excel = Excel.createExcel();
      final Sheet sheet = excel['Historical Data'];
      excel.delete('Sheet1'); // Remove default sheet

      // Add Headers
      sheet.appendRow([
        TextCellValue('Date'),
        TextCellValue('Auctioneer'),
        TextCellValue('Lots'),
        TextCellValue('Total Qty Arrived (Kgs)'),
        TextCellValue('Qty Sold (Kgs)'),
        TextCellValue('Max Price (₹)'),
        TextCellValue('Avg Price (₹)'),
      ]);

      // Add Data
      for (final a in data) {
        sheet.appendRow([
          TextCellValue(DateFormat('yyyy-MM-dd').format(a.date)),
          TextCellValue(a.auctioneer),
          IntCellValue(a.lots ?? 0),
          DoubleCellValue(a.quantityArrived ?? 0.0),
          DoubleCellValue(a.quantity),
          DoubleCellValue(a.maxPrice),
          DoubleCellValue(a.avgPrice),
        ]);
      }

      // Save file
      final bytes = excel.save();
      if (bytes == null) return;

      final directory = await getTemporaryDirectory();
      final filePath = "${directory.path}/Cardamom_History_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx";
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // Share file
      await Share.shareXFiles([XFile(filePath)], text: l10n.exportData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Export failed: $e")),
        );
      }
    }
  }
}
