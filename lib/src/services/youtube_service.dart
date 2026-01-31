import 'package:http/http.dart' as http;

class AuctionVideo {
  final String videoId;
  final bool isLive;
  final String channelName;

  AuctionVideo({
    required this.videoId,
    required this.isLive,
    required this.channelName,
  });
}
class VideoDetails {
  final String videoId;
  final String title;
  final String publishedTimeText;
  final DateTime publishedAt;

  VideoDetails({
    required this.videoId, 
    required this.title, 
    required this.publishedTimeText,
    required this.publishedAt,
  });
}

class YouTubeService {
  static const String spicesBoardChannel = 'spicesboardindia-marketing4818';
  static const String sbeAuctionChannel = 'sbeauctionputtady';

  /// Fetches the current live video ID from a channel's handle.
  /// Returns null if no live stream is found.
  Future<String?> getLiveVideoId(String channelHandle) async {
    try {
      final url = 'https://www.youtube.com/@$channelHandle/live';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final body = response.body;
        // The live video ID is often embedded in the watch URL in the page source
        // We look for "videoDetails":{"videoId":"..."
        final regExp = RegExp(r'"videoId":"([^"]+)"');
        final match = regExp.firstMatch(body);
        
        if (match != null) {
          final videoId = match.group(1);
          // Verify if it's actually live by checking for "isLive":true
          if (body.contains('"isLive":true')) {
            return videoId;
          }
        }
      }
    } catch (e) {
      // Error fetching live stream
    }
    return null;
  }

  /// Fetches details of the latest videos from a channel.
  Future<List<VideoDetails>> getRecentVideos(String channelHandle) async {
    try {
      final url = 'https://www.youtube.com/@$channelHandle/streams';
      final response = await http.get(Uri.parse(url));

      final List<VideoDetails> results = [];

      if (response.statusCode == 200) {
        final body = response.body;
        
        const marker = 'ytInitialData = ';
        final startIndex = body.indexOf(marker);
        if (startIndex != -1) {
          final jsonStart = startIndex + marker.length;
          final endScriptIndex = body.indexOf('</script>', jsonStart);
          if (endScriptIndex != -1) {
            final jsonString = body.substring(jsonStart, endScriptIndex).trim();
            final cleanedJson = jsonString.endsWith(';') 
                ? jsonString.substring(0, jsonString.length - 1) 
                : jsonString;

            // Resilient Atomic Parsing: Find the start of each videoRenderer block
            const blockStart = '"videoRenderer":{';
            int currentPos = cleanedJson.indexOf(blockStart);
            
            while (currentPos != -1 && results.length < 5) {
              // Take a large enough chunk to capture ID, Title, and publishedTimeText
              // Typically these fields appear within the first 1500-2000 characters of the renderer
              final int searchEnd = (currentPos + 2000 < cleanedJson.length) 
                  ? currentPos + 2000 
                  : cleanedJson.length;
              final String block = cleanedJson.substring(currentPos, searchEnd);
              
              final idMatch = RegExp(r'"videoId":"([^"]+)"').firstMatch(block);
              final titleMatch = RegExp(r'"title":\{"runs":\[\{"text":"([^"]+)"\}\]').firstMatch(block);
              final timeMatch = RegExp(r'"publishedTimeText":\{"simpleText":"([^"]+)"\}').firstMatch(block);
              
              if (idMatch != null) {
                results.add(VideoDetails(
                  videoId: idMatch.group(1)!,
                  title: titleMatch?.group(1) ?? 'Auction',
                  publishedTimeText: timeMatch?.group(1) ?? '',
                  publishedAt: DateTime.now(),
                ));
              }

              // Move to the next block
              currentPos = cleanedJson.indexOf(blockStart, currentPos + 1);
            }
          }
        }
      }
      return results;
    } catch (e) {
      // Error fetching recent videos
    }
    return [];
  }

  /// Checks streams for live content or recent uploads from today.
  /// Returns a live video if available, otherwise the latest video if uploaded today.
  Future<AuctionVideo?> findActiveOrRecentAuction() async {
    // 1. Check all channels for LIVE stream first
    final liveId1 = await getLiveVideoId(spicesBoardChannel);
    if (liveId1 != null) {
      return AuctionVideo(videoId: liveId1, isLive: true, channelName: 'Spices Board');
    }

    final liveId2 = await getLiveVideoId(sbeAuctionChannel);
    if (liveId2 != null) {
      return AuctionVideo(videoId: liveId2, isLive: true, channelName: 'Spices Board E-Auction');
    }

    // 2. If no live stream, check for recent uploads from TODAY across BOTH channels
    final List<Map<String, dynamic>> combinedTodayVideos = [];
        
    for (var channel in [spicesBoardChannel, sbeAuctionChannel]) {
      final videos = await getRecentVideos(channel);
      for (var v in videos) {
        final t = v.publishedTimeText.toLowerCase();
        final isToday = t.contains('minute') || t.contains('hour') || t.contains('second') || t.contains('just now');
        
        if (isToday) {
          combinedTodayVideos.add({
            'video': v,
            'channel': channel,
          });
        }
      }
    }

    if (combinedTodayVideos.isNotEmpty) {
      // Helper to convert relative time strings (e.g., "55 minutes ago") to minutes
      int parseRelativeToMinutes(String text) {
        final t = text.toLowerCase();
        final numMatch = RegExp(r'\d+').firstMatch(t);
        final num = int.tryParse(numMatch?.group(0) ?? '') ?? 999;

        if (t.contains('minute')) return num;
        if (t.contains('hour')) return num * 60;
        if (t.contains('day')) return num * 1440;
        return 999;
      }

      // Sort by the freshest session first
      combinedTodayVideos.sort((a, b) {
        final vA = a['video'] as VideoDetails;
        final vB = b['video'] as VideoDetails;
        return parseRelativeToMinutes(vA.publishedTimeText).compareTo(parseRelativeToMinutes(vB.publishedTimeText));
      });

      // The user wants the absolute freshest one among all today's sessions
      final freshest = combinedTodayVideos.first;
      final fV = freshest['video'] as VideoDetails;
      final fChannel = freshest['channel'] as String;

      return AuctionVideo(
        videoId: fV.videoId, 
        isLive: false, 
        channelName: fChannel.contains('spice') ? 'Spices Board' : 'Spices Board E-Auction'
      );
    }

    return null;
  }


  /// Extracts video ID from common YouTube URL formats.
  static String? extractVideoId(String url) {
    if (url.contains('youtu.be/')) {
      return url.split('youtu.be/').last.split('?').first;
    } else if (url.contains('v=')) {
      return url.split('v=').last.split('&').first;
    } else if (url.contains('embed/')) {
      return url.split('embed/').last.split('?').first;
    }
    return null;
  }

  /// Checks both known auction channels for live streams or recent videos.
  /// Returns a list of video IDs to try.
  Future<List<String>> discoverPotentialAuctions() async {
    final List<String> potentialIds = [];

    // 1. Try Live streams first
    final liveId1 = await getLiveVideoId(spicesBoardChannel);
    if (liveId1 != null) potentialIds.add(liveId1);

    final liveId2 = await getLiveVideoId(sbeAuctionChannel);
    if (liveId2 != null) potentialIds.add(liveId2);

    // 2. Add latest videos if no live stream found (for playback of recent auctions)
    if (potentialIds.isEmpty) {
      final v1 = await getRecentVideos(spicesBoardChannel);
      if (v1.isNotEmpty) potentialIds.add(v1.first.videoId);

      final v2 = await getRecentVideos(sbeAuctionChannel);
      if (v2.isNotEmpty) potentialIds.add(v2.first.videoId);
    }

    return potentialIds.toSet().toList(); // Remove duplicates
  }

  /// Checks if the current time is within auction hours (9:30 AM - 6:15 PM).
  static bool isAuctionActive() {
    final now = DateTime.now();
    // No auctions on Sundays
    if (now.weekday == DateTime.sunday) return false;
    
    // Auctions run strictly between 9:30 AM and 6:15 PM
    final start = DateTime(now.year, now.month, now.day, 9, 30);
    final end = DateTime(now.year, now.month, now.day, 18, 15);
    
    if (now.isBefore(start) || now.isAfter(end)) return false;

    // Check for major regional holidays
    final holidays = [
      DateTime(now.year, 1, 26), // Republic Day
      DateTime(now.year, 8, 15), // Independence Day
      DateTime(now.year, 10, 2), // Gandhi Jayanti
    ];

    for (var holiday in holidays) {
      if (now.year == holiday.year && now.month == holiday.month && now.day == holiday.day) {
        return false; // If it's a holiday, auction is not active
      }
    }

    return true;
  }
}
