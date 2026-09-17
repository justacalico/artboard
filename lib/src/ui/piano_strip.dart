import 'package:flutter/material.dart';

import '../music/pitch_mapper.dart';

/// Mini piano used to pick the key. White keys are naturals, the
/// raised black keys are sharps.
class PianoStrip extends StatelessWidget {
  const PianoStrip({super.key, required this.rootMidi, required this.onSelect});

  final int rootMidi;
  final ValueChanged<int> onSelect;

  static const _whiteOrder = [0, 2, 4, 5, 7, 9, 11];
  static const _blackAfterWhite = {0: 1, 1: 3, 3: 6, 4: 8, 5: 10};

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final whiteW = constraints.maxWidth / _whiteOrder.length;
        final blackW = whiteW * 0.58;
        final blackH = constraints.maxHeight * 0.58;
        return Stack(
          children: [
            Row(
              children: [
                for (var i = 0; i < _whiteOrder.length; i++)
                  SizedBox(
                    width: whiteW,
                    height: constraints.maxHeight,
                    child: _WhiteKey(
                      selected: rootMidi == kRootNotes[_whiteOrder[i]].$2,
                      onTap: () => onSelect(kRootNotes[_whiteOrder[i]].$2),
                    ),
                  ),
              ],
            ),
            for (final entry in _blackAfterWhite.entries)
              Positioned(
                left: whiteW * (entry.key + 1) - blackW / 2,
                top: 0,
                child: SizedBox(
                  width: blackW,
                  height: blackH,
                  child: _BlackKey(
                    selected: rootMidi == kRootNotes[entry.value].$2,
                    onTap: () => onSelect(kRootNotes[entry.value].$2),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _WhiteKey extends StatelessWidget {
  const _WhiteKey({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1C1B1A) : Colors.white,
          border: Border.all(color: const Color(0x55000000), width: 0.5),
        ),
      ),
    );
  }
}

class _BlackKey extends StatelessWidget {
  const _BlackKey({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF6B4FCE) : const Color(0xFF1C1B1A),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(2)),
        ),
      ),
    );
  }
}
