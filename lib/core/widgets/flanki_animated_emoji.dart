import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../config/app_config.dart';

/// Standardized animated emoji component for Flanki.
///
/// Follows standard Lottie looping conventions:
/// - Looping animation by default ([repeat] = true) for continuous, vibrant micro-interactions.
/// - Automatically respects system [MediaQuery.disableAnimations] (Reduce Motion).
/// - Supports [interactive] tap-to-replay with subtle haptic feedback (Telegram style).
class FlankiAnimatedEmoji extends StatefulWidget {
  final AnimatedEmojiData emoji;
  final double size;
  final bool repeat;
  final bool interactive;
  final VoidCallback? onTap;

  const FlankiAnimatedEmoji({
    super.key,
    required this.emoji,
    this.size = 32.0,
    this.repeat = true,
    this.interactive = false,
    this.onTap,
  });

  @override
  State<FlankiAnimatedEmoji> createState() => _FlankiAnimatedEmojiState();
}

class _FlankiAnimatedEmojiState extends State<FlankiAnimatedEmoji>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Duration? _loadedDuration;

  @override
  void initState() {
    super.initState();
    if (widget.interactive) {
      _controller = AnimationController(vsync: this);
    }
  }

  @override
  void didUpdateWidget(covariant FlankiAnimatedEmoji oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldRepeat = widget.repeat && !AppConfig.isFlutterTest;
    if (widget.interactive && _controller == null) {
      _controller = AnimationController(vsync: this);
      if (_loadedDuration != null) {
        _controller!.duration = _loadedDuration;
        if (shouldRepeat) {
          _controller!.repeat();
        } else {
          _controller!.forward(from: 0.0);
        }
      }
    } else if (!widget.interactive && _controller != null) {
      _controller!.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _replay() {
    if (!widget.interactive) return;
    HapticFeedback.lightImpact();
    final shouldRepeat = widget.repeat && !AppConfig.isFlutterTest;
    if (_controller != null) {
      if (shouldRepeat) {
        _controller!.forward(from: 0.0).then((_) {
          if (mounted && shouldRepeat) {
            _controller!.repeat();
          }
        });
      } else {
        _controller!.forward(from: 0.0);
      }
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    if (reduceMotion) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedEmoji(
          widget.emoji,
          size: widget.size,
          animate: false,
          repeat: false,
        ),
      );
    }

    final shouldRepeat = widget.repeat && !AppConfig.isFlutterTest;

    if (!widget.interactive) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedEmoji(
          widget.emoji,
          size: widget.size,
          repeat: shouldRepeat,
          animate: true,
        ),
      );
    }

    final emojiWidget = SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedEmoji(
        widget.emoji,
        size: widget.size,
        controller: _controller,
        repeat: shouldRepeat,
        animate: true,
        onLoaded: (duration) {
          _loadedDuration = duration;
          if (_controller != null) {
            _controller!.duration = duration;
            if (shouldRepeat) {
              _controller!.repeat();
            } else {
              _controller!.forward(from: 0.0);
            }
          }
        },
      ),
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _replay,
        behavior: HitTestBehavior.opaque,
        child: emojiWidget,
      ),
    );
  }
}
