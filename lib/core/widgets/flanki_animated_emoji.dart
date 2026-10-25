import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Standardized animated emoji component for Flanki.
///
/// Follows "Quiet by default, Expressive on Milestone" principles:
/// - One-shot animation by default ([repeat] = false) to prevent visual fatigue.
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
    this.repeat = false,
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
    if (widget.interactive && _controller == null) {
      _controller = AnimationController(vsync: this);
      if (_loadedDuration != null) {
        _controller!.duration = _loadedDuration;
        _controller!.forward(from: 0.0);
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
    if (_controller != null) {
      _controller!.forward(from: 0.0);
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

    if (!widget.interactive) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedEmoji(
          widget.emoji,
          size: widget.size,
          repeat: widget.repeat,
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
        repeat: widget.repeat,
        animate: true,
        onLoaded: (duration) {
          _loadedDuration = duration;
          if (_controller != null) {
            _controller!.duration = duration;
            _controller!.forward(from: 0.0);
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
