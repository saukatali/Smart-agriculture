import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BarData {
  final String day;
  final double value; // 0.0 to 1.0 relative height
  final String label;

  const BarData({
    required this.day,
    required this.value,
    required this.label,
  });
}

class CustomBarChart extends StatefulWidget {
  final List<BarData> bars;
  final int activeIndex;
  final double height;
  final ValueChanged<int>? onBarSelected;

  const CustomBarChart({
    super.key,
    required this.bars,
    this.activeIndex = 4, // Default to Friday or Sunday as in reference
    this.height = 110,
    this.onBarSelected,
  });

  @override
  State<CustomBarChart> createState() => _CustomBarChartState();
}

class _CustomBarChartState extends State<CustomBarChart> {
  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.activeIndex;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(widget.bars.length, (index) {
          final bar = widget.bars[index];
          final isSelected = index == _selected;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() => _selected = index);
                widget.onBarSelected?.call(index);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Bar
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: bar.value.clamp(0.15, 1.0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.chartBarActive
                                  : AppColors.chartBarDefault,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Day label
                    Text(
                      bar.day,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
