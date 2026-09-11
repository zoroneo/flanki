import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Hook that generates [count] FocusNodes and chains them for:
/// - Tab: jump to next field (or [submitFocusNode] / nextFocus at the end)
/// - Shift+Tab: jump to previous field (or previousFocus at the start)
/// - Enter on last field: triggers [onSubmit]
List<FocusNode> useTabFocusChain(
  int count, {
  VoidCallback? onSubmit,
  FocusNode? submitFocusNode,
}) {
  final nodes = List.generate(count, (_) => useFocusNode());
  useAttachTabFocusChain(
    nodes,
    onSubmit: onSubmit,
    submitFocusNode: submitFocusNode,
  );
  return nodes;
}

/// Attaches Tab/Shift+Tab focus traversal and Enter submit to an existing list of FocusNodes.
void useAttachTabFocusChain(
  List<FocusNode> nodes, {
  VoidCallback? onSubmit,
  FocusNode? submitFocusNode,
}) {
  useEffect(() {
    for (int i = 0; i < nodes.length; i++) {
      final currentIndex = i;
      final node = nodes[currentIndex];

      node.onKeyEvent = (fNode, event) {
        if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
          return KeyEventResult.ignored;
        }

        // Tab / Shift+Tab handling
        if (event.logicalKey == LogicalKeyboardKey.tab) {
          final isShift = HardwareKeyboard.instance.isShiftPressed ||
              HardwareKeyboard.instance.logicalKeysPressed
                  .contains(LogicalKeyboardKey.shiftLeft) ||
              HardwareKeyboard.instance.logicalKeysPressed
                  .contains(LogicalKeyboardKey.shiftRight);

          if (isShift) {
            if (currentIndex > 0) {
              nodes[currentIndex - 1].requestFocus();
            } else {
              fNode.previousFocus();
            }
          } else {
            if (currentIndex < nodes.length - 1) {
              nodes[currentIndex + 1].requestFocus();
            } else if (submitFocusNode != null) {
              submitFocusNode.requestFocus();
            } else {
              fNode.nextFocus();
            }
          }
          return KeyEventResult.handled;
        }

        // Enter on last field triggers submission if multiline isn't strictly capturing it
        if (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.numpadEnter) {
          final isShift = HardwareKeyboard.instance.isShiftPressed;
          if (currentIndex == nodes.length - 1 &&
              onSubmit != null &&
              !isShift) {
            onSubmit();
            return KeyEventResult.handled;
          }
        }

        return KeyEventResult.ignored;
      };
    }

    return () {
      for (final n in nodes) {
        n.onKeyEvent = null;
      }
    };
  }, [...nodes, submitFocusNode]);
}
