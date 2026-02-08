import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cardamom_analytics/src/localization/app_localizations.dart';
import 'package:cardamom_analytics/src/services/youtube_service.dart';
import 'package:cardamom_analytics/src/providers/navigation_provider.dart';

class LivePulseScreen extends ConsumerStatefulWidget {
  const LivePulseScreen({super.key});

  @override
  ConsumerState<LivePulseScreen> createState() => _LivePulseScreenState();
}

class _LivePulseScreenState extends ConsumerState<LivePulseScreen> with WidgetsBindingObserver {
  YoutubePlayerController? _controller;
  final YouTubeService _youtubeService = YouTubeService();
  
  bool _isLoading = true;
  bool _hasSeekedToEnd = false;
  AuctionVideo? _activeAuction;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _discoverAuction();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _controller?.pause();
    }
  }

  Future<void> _discoverAuction() async {
    setState(() => _isLoading = true);
    _hasSeekedToEnd = false;
    
    // Changed to find active OR recent auction
    final activeOrRecent = await _youtubeService.findActiveOrRecentAuction();
    
    if (mounted) {
      setState(() {
        _activeAuction = activeOrRecent;
        _isLoading = false;
        
        if (_activeAuction != null) {
          _controller = YoutubePlayerController(
            initialVideoId: _activeAuction!.videoId,
            flags: YoutubePlayerFlags(
              autoPlay: true,
              isLive: _activeAuction!.isLive,
            ),
          )..addListener(_playerListener);
        }
      });
    }
  }

  void _playerListener() {
    if (_controller != null && 
        _activeAuction != null && 
        !_activeAuction!.isLive && 
        !_hasSeekedToEnd && 
        _controller!.value.isReady &&
        _controller!.value.playerState == PlayerState.playing) {
      
      final duration = _controller!.metadata.duration;
      // Ensure duration is actually loaded (sometimes it's 0 even if ready)
      if (duration.inSeconds > 0) {
        if (duration.inSeconds > 60) {
          _hasSeekedToEnd = true;
          _controller!.seekTo(duration - const Duration(seconds: 60));
        } else {
          // If video is too short, just mark as seeked (nothing to seek)
          _hasSeekedToEnd = true;
        }
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Auto-pause if we switch away from the Live tab (index 2)
    ref.listen<int>(navigationProvider, (previous, next) {
      if (next != 2) {
        _controller?.pause();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.live),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _discoverAuction,
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState(l10n)
          : _activeAuction == null
              ? _buildNoAuctionState(l10n, theme)
              : _buildLiveAuctionUI(l10n, theme),
    );
  }

  Widget _buildLoadingState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.green),
          const SizedBox(height: 20),
          Text(l10n.searchingAuctions),
        ],
      ),
    );
  }

  Widget _buildNoAuctionState(AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off_outlined, size: 80, color: theme.colorScheme.outline),
            const SizedBox(height: 24),
            Text(
              l10n.noAuctionActive,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.liveAuctionScheduleHint,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _discoverAuction,
              icon: const Icon(Icons.search),
              label: Text(l10n.tryDiscoveryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveAuctionUI(AppLocalizations l10n, ThemeData theme) {
    final bool isLive = _activeAuction?.isLive ?? false;
    final color = isLive ? Colors.red.shade900 : Colors.orange.shade700;
    String channelDisplay = _activeAuction?.channelName ?? '';
    if (channelDisplay.contains('Spice')) {
      channelDisplay = l10n.spicesBoardAuction;
    } else if (channelDisplay.contains('SBE') || channelDisplay.contains('E-Auction')) {
      channelDisplay = l10n.sbeAuction;
    }

    final label = isLive 
        ? l10n.liveAuctionFrom(channelDisplay)
        : l10n.recentSessionFrom(channelDisplay);

    return Column(
      children: [
        if (_controller != null)
          YoutubePlayer(
            controller: _controller!,
            showVideoProgressIndicator: true,
          ),

        Container(
          padding: const EdgeInsets.all(12),
          color: color,
          child: Row(
            children: [
              Icon(isLive ? Icons.circle : Icons.history, color: Colors.white, size: 12),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
      ],
    );
  }
}


