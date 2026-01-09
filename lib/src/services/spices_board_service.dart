import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:cardamom_analytics/src/models/auction_data.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class SpicesBoardService {
  final String _latestUrl = 'https://indianspices.com/marketing/price/domestic/daily-price.html';
  final String _archiveUrl = 'https://indianspices.com/marketing/price/domestic/daily-price-small.html';
  
  /// Fetches the very latest auctions from the main daily price page
  Future<List<AuctionData>> fetchLatestAuctions() async {
    return _fetchFromUrl(_latestUrl, skipRows: 2);
  }

  /// Fetches historical auctions from the paginated "small" archive pages
  Future<List<AuctionData>> fetchAuctionsByPage(int pageNumber) async {
    final url = '$_archiveUrl?page=$pageNumber';
    return _fetchFromUrl(url, skipRows: 1);
  }

  Future<List<AuctionData>> _fetchFromUrl(String url, {int skipRows = 1}) async {
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        var document = parser.parse(response.body);
        
        // Try to find the specific table
        var table = document.querySelector('#table-conatainer table');
        
        if (table == null) {
          // Fallback: look for any table with sufficient rows
           var tables = document.getElementsByTagName('table');
           for (var t in tables) {
             if (t.querySelectorAll('tr').length > 5) {
               table = t;
               break;
             }
           }
        }

        if (table == null) return [];

        List<AuctionData> auctions = [];
        var rows = table.querySelectorAll('tr');
        
        // Skip specified header rows
        for (var i = skipRows; i < rows.length; i++) {
          var cells = rows[i].querySelectorAll('td');
          if (cells.length >= 8) {
             try {
               String dateStr = cells[1].text.trim();
               String auctioneer = cells[2].text.trim();
               String lotsStr = cells[3].text.trim();
               String arrivedStr = cells[4].text.trim();
               String quantityStr = cells[5].text.trim();
               String maxPriceStr = cells[6].text.trim();
               String avgPriceStr = cells[7].text.trim();

               // Clean and parse
               // Robust Manual Date Parsing for 05-Jan-2026
               DateTime? date;
               String cleanDate = dateStr.replaceAll(RegExp(r'[^a-zA-Z0-9-]'), '-').replaceAll('--', '-');
               
               final parts = cleanDate.split('-');
               if (parts.length == 3) {
                 int? d = int.tryParse(parts[0]);
                 int? y = int.tryParse(parts[2]);
                 String mStr = parts[1].toLowerCase();
                 int? m;
                 
                 // Manual Month Mapping to be 100% Locale-Safe
                 if (mStr.startsWith('jan')) {
                   m = 1;
                 } else if (mStr.startsWith('feb')) {
                   m = 2;
                 } else if (mStr.startsWith('mar')) {
                   m = 3;
                 } else if (mStr.startsWith('apr')) {
                   m = 4;
                 } else if (mStr.startsWith('may')) {
                   m = 5;
                 } else if (mStr.startsWith('jun')) {
                   m = 6;
                 } else if (mStr.startsWith('jul')) {
                   m = 7;
                 } else if (mStr.startsWith('aug')) {
                   m = 8;
                 } else if (mStr.startsWith('sep')) {
                   m = 9;
                 } else if (mStr.startsWith('oct')) {
                   m = 10;
                 } else if (mStr.startsWith('nov')) {
                   m = 11;
                 } else if (mStr.startsWith('dec')) {
                   m = 12;
                 }
                 
                 // If Month is numeric (05-01-2026)
                 m ??= int.tryParse(parts[1]);

                 if (d != null && m != null && y != null) {
                   if (y < 100) y += 2000;
                   if (m > 0 && m <= 12 && d > 0 && d <= 31) {
                     try { date = DateTime(y, m, d); } catch (_) {}
                   }
                 }
               }
               
               // Last resort: Intl
               if (date == null) {
                 try { date = DateFormat("dd-MMM-yyyy", "en_US").parseStrict(cleanDate); } catch (_) {}
               }
               if (date == null) {
                 try { date = DateFormat("dd-MM-yyyy").parseStrict(cleanDate); } catch (_) {}
               }

               if (date == null) {
                 debugPrint("[API] Failed to parse date: $dateStr");
                 continue; 
               }

               if (date.year < 2000) {
                 debugPrint("[API] Ignoring invalid year ${date.year} for $dateStr");
                 continue;
               }

               double maxP = double.tryParse(maxPriceStr.replaceAll(',', '')) ?? 0.0;
               double avgP = double.tryParse(avgPriceStr.replaceAll(',', '')) ?? 0.0;
               double qtyS = double.tryParse(quantityStr.replaceAll(',', '')) ?? 0.0;
               double qtyA = double.tryParse(arrivedStr.replaceAll(',', '')) ?? 0.0;
               double lotsD = double.tryParse(lotsStr.replaceAll(',', '')) ?? 0.0;

               auctions.add(AuctionData(
                 date: date,
                 auctioneer: auctioneer.toUpperCase().trim(),
                 maxPrice: (maxP * 100).round() / 100.0,
                 avgPrice: (avgP * 100).round() / 100.0,
                 quantity: (qtyS * 100).round() / 100.0,
                 quantityArrived: (qtyA * 100).round() / 100.0,
                 lots: lotsD.round(),
               ));
             } catch (e) {
                // Skip malformed rows
             }
          }
        }
        return auctions;
      } else {
        debugPrint("Failed to load auctions: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("Fetch error for $url: $e");
      return []; 
    }
  }
}
