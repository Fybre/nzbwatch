import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../services/download_service.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final String downloadId;
  final String filePath;
  final String title;

  const PlayerScreen({
    super.key,
    required this.downloadId,
    required this.filePath,
    required this.title,
  });

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  Player? _player;
  VideoController? _controller;
  late final DownloadService _downloadService;
  bool _isLoading = true;
  String? _error;
  Timer? _positionTimer;

  // Track dimensions to avoid nested StreamBuilders
  double _aspectRatio = 16 / 9;
  StreamSubscription? _widthSubscription;
  StreamSubscription? _heightSubscription;
  StreamSubscription? _progressSubscription;
  List<(double, double)> _downloadedRanges = [];

  @override
  void initState() {
    super.initState();
    _downloadService = ref.read(downloadServiceProvider);
    _initializePlayer();
    _subscribeToProgress();
  }

  void _subscribeToProgress() {
    _progressSubscription = _downloadService.getProgressStream(widget.downloadId).listen((progress) {
      if (mounted) {
        setState(() {
          _downloadedRanges = progress.downloadedRanges;
        });
      }
    });
  }

  Future<void> _initializePlayer() async {
    try {
      final isStream = widget.filePath.startsWith('http');
      
      if (!isStream) {
        final file = File(widget.filePath);
        if (!await file.exists()) {
          setState(() {
            _error = 'Video file not found. It may have been moved or deleted.';
            _isLoading = false;
          });
          return;
        }
      }

      final player = Player();
      final controller = VideoController(player);

      // Set initial volume to 100% to initialize audio engine
      player.setVolume(100.0);

      // Listen for dimension changes once to update aspect ratio
      _widthSubscription = player.stream.width.listen((width) {
        _updateAspectRatio(width, player.state.height);
      });
      _heightSubscription = player.stream.height.listen((height) {
        _updateAspectRatio(player.state.width, height);
      });

      final download = await _downloadService.getDownload(widget.downloadId);
      final lastPosition = Duration(milliseconds: download?.lastPosition ?? 0);

      if (isStream) {
        await player.open(Media(widget.filePath));
      } else {
        await player.open(Media('file://${widget.filePath}'));
      }
      
      if (lastPosition > Duration.zero && !isStream) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) player.seek(lastPosition);
        });
      }
      
      player.setSubtitleTrack(SubtitleTrack.no());

      if (!isStream) {
        _positionTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
          _savePosition();
        });
      }

      setState(() {
        _player = player;
        _controller = controller;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load video: $e';
        _isLoading = false;
      });
    }
  }

  void _updateAspectRatio(int? width, int? height) {
    if (width != null && height != null && height > 0) {
      final newRatio = width / height;
      if ((newRatio - _aspectRatio).abs() > 0.01) {
        setState(() {
          _aspectRatio = newRatio;
        });
      }
    }
  }

  Future<void> _savePosition() async {
    final player = _player;
    final isStream = widget.filePath.startsWith('http');
    if (player != null && !_isLoading && _error == null && !isStream) {
      try {
        final position = player.state.position;
        final duration = player.state.duration;
        
        final savePos = (duration.inSeconds > 0 && (duration.inSeconds - position.inSeconds) < 5)
            ? Duration.zero 
            : position;
            
        await _downloadService.updatePlaybackPosition(widget.downloadId, savePos);
      } catch (e) {
        // Silently fail
      }
    }
  }

  void _showSubtitleSelection() {
    final player = _player;
    if (player == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final tracks = player.state.tracks.subtitle;
        final current = player.state.track.subtitle;

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Select Subtitles',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const Divider(color: Colors.white10),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: tracks.length,
                  itemBuilder: (context, index) {
                    final track = tracks[index];
                    final isSelected = current == track;
                    final title = track.title ?? track.language ?? 'Track ${index + 1}';

                    return ListTile(
                      leading: Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected ? const Color(0xFF6366F1) : Colors.white30,
                      ),
                      title: Text(
                        title,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        player.setSubtitleTrack(track);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              ListTile(
                leading: Icon(
                  current == SubtitleTrack.no() ? Icons.check_circle : Icons.circle_outlined,
                  color: current == SubtitleTrack.no() ? const Color(0xFF6366F1) : Colors.white30,
                ),
                title: const Text('None', style: TextStyle(color: Colors.white70)),
                onTap: () {
                  player.setSubtitleTrack(SubtitleTrack.no());
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAudioSelection() {
    final player = _player;
    if (player == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final tracks = player.state.tracks.audio;
        final current = player.state.track.audio;

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Select Audio Track',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              const Divider(color: Colors.white10),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: tracks.length,
                  itemBuilder: (context, index) {
                    final track = tracks[index];
                    final isSelected = current == track;
                    final title =
                        track.title ?? track.language ?? 'Track ${index + 1}';

                    return ListTile(
                      leading: Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected
                            ? const Color(0xFF6366F1)
                            : Colors.white30,
                      ),
                      title: Text(
                        title,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        player.setAudioTrack(track);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _widthSubscription?.cancel();
    _heightSubscription?.cancel();
    _progressSubscription?.cancel();
    _positionTimer?.cancel();
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          await _savePosition();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _error != null
            ? _buildErrorState()
            : _isLoading
                ? _buildLoadingState()
                : _buildPlayer(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading video...', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayer() {
    final controller = _controller;
    if (controller == null) return _buildErrorState();

    final List<Widget> topButtonBar = [
      MaterialCustomButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      MaterialCustomButton(
        onPressed: _showAudioSelection,
        icon: const Icon(Icons.audiotrack, color: Colors.white),
      ),
      MaterialCustomButton(
        onPressed: _showSubtitleSelection,
        icon: const Icon(Icons.subtitles, color: Colors.white),
      ),
    ];

    final List<Widget> bottomButtonBar = [
      const MaterialPlayOrPauseButton(),
      MaterialCustomButton(
        onPressed: () {
          final position = _player?.state.position ?? Duration.zero;
          _player?.seek(position - const Duration(seconds: 10));
        },
        icon: const Icon(Icons.replay_10, color: Colors.white),
      ),
      MaterialCustomButton(
        onPressed: () {
          final position = _player?.state.position ?? Duration.zero;
          _player?.seek(position + const Duration(seconds: 10));
        },
        icon: const Icon(Icons.forward_10, color: Colors.white),
      ),
      const MaterialDesktopVolumeButton(),
      const MaterialPositionIndicator(),
      const Spacer(),
      const MaterialFullscreenButton(),
    ];

    return MaterialVideoControlsTheme(
      normal: MaterialVideoControlsThemeData(
        bottomButtonBar: bottomButtonBar,
        bottomButtonBarMargin: const EdgeInsets.only(bottom: 40, left: 16, right: 16),
        seekBarMargin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
        topButtonBar: topButtonBar,
      ),
      fullscreen: MaterialVideoControlsThemeData(
        bottomButtonBar: bottomButtonBar,
        bottomButtonBarMargin: const EdgeInsets.only(bottom: 40, left: 16, right: 16),
        seekBarMargin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
        topButtonBar: topButtonBar,
      ),
      child: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _aspectRatio,
              child: GestureDetector(
                onTap: () {
                  // Ensure player area takes focus when clicked
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Video(
                  controller: controller,
                  fit: BoxFit.contain,
                  controls: MaterialVideoControls,
                ),
              ),
            ),
          ),
          
          // Custom Buffer Bar Overlay
          if (_downloadedRanges.isNotEmpty && _downloadedRanges.length < 2) // Only show if not fully done
            Positioned(
              bottom: 78,
              left: 32,
              right: 32,
              child: IgnorePointer(
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(1),
                  ),
                  child: Stack(
                    children: _downloadedRanges.map((range) {
                      return Positioned(
                        left: MediaQuery.of(context).size.width * (range.$1 / 100.0),
                        width: MediaQuery.of(context).size.width * ((range.$2 - range.$1) / 100.0),
                        top: 0,
                        bottom: 0,
                        child: Container(color: Colors.white30),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
