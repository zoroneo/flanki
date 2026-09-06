import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class CustomStudyModal extends HookWidget {
  final void Function(String name, String tag, int limit) onStartCram;

  const CustomStudyModal({
    super.key,
    required this.onStartCram,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mode = useState<int>(0); // 0: Tag, 1: Flagged, 2: Review ahead
    final tagController = useTextEditingController(text: 'toeic');
    final limit = useState<int>(20);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.mutedForeground.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(m.Icons.bolt_rounded, color: m.Colors.amber, size: 24),
                  const SizedBox(width: 8),
                  Text('Ôn Tập Đột Xuất (Cram Mode)', style: theme.typography.h4),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Tạo phiên học lọc theo nhu cầu cấp tốc trước kỳ thi. Không làm thay đổi lịch thuật toán FSRS gốc.',
                style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground),
              ),
              const SizedBox(height: 20),

              // Mode selector
              Text('CHẾ ĐỘ LỌC THẺ', style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _ModeButton(
                      label: 'Theo Tag',
                      isSelected: mode.value == 0,
                      onTap: () => mode.value = 0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ModeButton(
                      label: 'Có Cờ',
                      isSelected: mode.value == 1,
                      onTap: () => mode.value = 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ModeButton(
                      label: 'Ôn Trước',
                      isSelected: mode.value == 2,
                      onTap: () => mode.value = 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (mode.value == 0) ...[
                Text('TÊN TAG CẦN ÔN', style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
                const SizedBox(height: 6),
                Card(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: TextField(
                    controller: tagController,
                    placeholder: const Text('Nhập tag (ví dụ: toeic, grammar)...'),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Card limit
              Text('GIỚI HẠN SỐ THẺ', style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
              const SizedBox(height: 8),
              Row(
                children: [10, 20, 50, 100].map((l) {
                  final isSelected = limit.value == l;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: GestureDetector(
                        onTap: () => limit.value = l,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.muted,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$l thẻ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? theme.colorScheme.primaryForeground : theme.colorScheme.foreground,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              PrimaryButton(
                onPressed: () {
                  final tagName = mode.value == 0
                      ? tagController.text.trim()
                      : (mode.value == 1 ? 'flagged' : 'ahead');
                  onStartCram(
                    mode.value == 0 ? tagName : (mode.value == 1 ? 'Thẻ có cờ' : 'Ôn trước hạn'),
                    tagName,
                    limit.value,
                  );
                  Navigator.of(context).pop();
                },
                leading: const Icon(m.Icons.play_arrow_rounded),
                child: const Text('Bắt đầu ôn tập cấp tốc'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.muted,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? theme.colorScheme.primaryForeground : theme.colorScheme.foreground,
          ),
        ),
      ),
    );
  }
}
