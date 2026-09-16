import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/models/card.dart';

Map<ShortcutActivator, VoidCallback> buildStudyShortcuts({
  required bool isFlipped,
  required bool canUndo,
  required VoidCallback onFlip,
  required ValueChanged<ReviewRating> onRate,
  required VoidCallback onUndo,
  required VoidCallback onEscape,
}) {
  return <ShortcutActivator, VoidCallback>{
    const SingleActivator(LogicalKeyboardKey.space): () {
      isFlipped ? onRate(ReviewRating.good) : onFlip();
    },
    const SingleActivator(LogicalKeyboardKey.enter): () {
      isFlipped ? onRate(ReviewRating.good) : onFlip();
    },
    const SingleActivator(LogicalKeyboardKey.digit1): () {
      if (isFlipped) onRate(ReviewRating.again);
    },
    const SingleActivator(LogicalKeyboardKey.numpad1): () {
      if (isFlipped) onRate(ReviewRating.again);
    },
    const SingleActivator(LogicalKeyboardKey.digit2): () {
      if (isFlipped) onRate(ReviewRating.hard);
    },
    const SingleActivator(LogicalKeyboardKey.numpad2): () {
      if (isFlipped) onRate(ReviewRating.hard);
    },
    const SingleActivator(LogicalKeyboardKey.digit3): () {
      if (isFlipped) onRate(ReviewRating.good);
    },
    const SingleActivator(LogicalKeyboardKey.numpad3): () {
      if (isFlipped) onRate(ReviewRating.good);
    },
    const SingleActivator(LogicalKeyboardKey.digit4): () {
      if (isFlipped) onRate(ReviewRating.easy);
    },
    const SingleActivator(LogicalKeyboardKey.numpad4): () {
      if (isFlipped) onRate(ReviewRating.easy);
    },
    const SingleActivator(LogicalKeyboardKey.keyZ, control: true): () {
      if (canUndo) onUndo();
    },
    const SingleActivator(LogicalKeyboardKey.keyZ): () {
      if (canUndo) onUndo();
    },
    const SingleActivator(LogicalKeyboardKey.escape): onEscape,
  };
}
