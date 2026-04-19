/// Represents a tip option for the tip selector UI.
class TipOption {
  const TipOption({
    required this.percentage,
    required this.amount,
    this.isCustom = false,
  });

  final int percentage; // 10, 15, 20
  final double amount;
  final bool isCustom;

  String get label => isCustom ? 'Custom' : '$percentage%';

  /// Preset tip options based on base fare.
  static List<TipOption> presets(double baseFare) {
    return [
      TipOption(percentage: 10, amount: baseFare * 0.10),
      TipOption(percentage: 15, amount: baseFare * 0.15),
      TipOption(percentage: 20, amount: baseFare * 0.20),
    ];
  }
}
