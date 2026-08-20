import 'package:flutter/material.dart';

class ReportDialog extends StatefulWidget {
  final String targetType; // 'post' | 'comment'
  final int targetId;
  final Function(String reason) onReportSubmitted;

  const ReportDialog({
    super.key,
    required this.targetType,
    required this.targetId,
    required this.onReportSubmitted,
  });

  static void show({
    required BuildContext context,
    required String targetType,
    required int targetId,
    required Function(String reason) onReportSubmitted,
  }) {
    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        targetType: targetType,
        targetId: targetId,
        onReportSubmitted: onReportSubmitted,
      ),
    );
  }

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final List<String> _reasons = [
    'Konten mengandung kata kasar / ujaran kebencian',
    'Spam atau iklan berlebihan',
    'Informasi medis / fisioterapi yang menyesatkan',
    'Pelecehan atau intimidasi',
    'Alasan lainnya',
  ];

  String? _selectedReason;
  final TextEditingController _customReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedReason = _reasons.first;
  }

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCustom = _selectedReason == 'Alasan lainnya';

    return AlertDialog(
      title: Text('Laporkan ${widget.targetType == 'post' ? 'Postingan' : 'Komentar'}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih alasan pelaporan agar tim tim moderasi GERAKIN dapat meninjau:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            ..._reasons.map((reason) {
              final isSelected = reason == _selectedReason;
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                title: Text(reason, style: const TextStyle(fontSize: 13)),
                onTap: () {
                  setState(() {
                    _selectedReason = reason;
                  });
                },
              );
            }),
            if (isCustom) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _customReasonController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Tuliskan alasan spesifik...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            final reason = isCustom
                ? _customReasonController.text.trim()
                : (_selectedReason ?? 'Laporan pengguna');

            if (reason.isNotEmpty) {
              Navigator.pop(context);
              widget.onReportSubmitted(reason);
            }
          },
          child: const Text('Kirim Laporan'),
        ),
      ],
    );
  }
}
