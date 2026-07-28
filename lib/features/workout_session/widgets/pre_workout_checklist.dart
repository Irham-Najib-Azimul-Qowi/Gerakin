import 'package:flutter/material.dart';

/// Checklist persiapan sebelum latihan (Pre-Workout Safety Checklist).
class PreWorkoutChecklistWidget extends StatefulWidget {
  const PreWorkoutChecklistWidget({
    super.key,
    required this.onAllChecked,
  });

  final ValueChanged<bool> onAllChecked;

  @override
  State<PreWorkoutChecklistWidget> createState() => _PreWorkoutChecklistWidgetState();
}

class _PreWorkoutChecklistWidgetState extends State<PreWorkoutChecklistWidget> {
  bool _checkSpace = false;
  bool _checkLighting = false;
  bool _checkNoPain = false;

  void _update() {
    widget.onAllChecked(_checkSpace && _checkLighting && _checkNoPain);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.fact_check_outlined, color: Color(0xFF00E676), size: 20),
              SizedBox(width: 8),
              Text(
                'CHECKLIST SEBELUM MULAI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _checkTile(
            title: 'Area latihan bebas dari hambatan',
            val: _checkSpace,
            onChanged: (v) {
              setState(() => _checkSpace = v ?? false);
              _update();
            },
          ),
          _checkTile(
            title: 'Pencahayaan ruangan cukup terang',
            val: _checkLighting,
            onChanged: (v) {
              setState(() => _checkLighting = v ?? false);
              _update();
            },
          ),
          _checkTile(
            title: 'Tidak merasakan nyeri akut saat ini',
            val: _checkNoPain,
            onChanged: (v) {
              setState(() => _checkNoPain = v ?? false);
              _update();
            },
          ),
        ],
      ),
    );
  }

  Widget _checkTile({required String title, required bool val, required ValueChanged<bool?> onChanged}) {
    return CheckboxListTile(
      value: val,
      onChanged: onChanged,
      title: Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      activeColor: const Color(0xFF00E676),
      checkColor: Colors.black,
      contentPadding: EdgeInsets.zero,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
