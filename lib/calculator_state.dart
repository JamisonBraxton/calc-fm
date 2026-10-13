enum InputPhase { entering, waiting, result, error }

/// Arithmetic is deliberately evaluated left to right, without precedence.
class CalculatorState {
  String display = '0';
  double? accumulator;
  String? pendingOperator;
  InputPhase phase = InputPhase.entering;
  String message = 'Enter a number to begin.';
  bool hasOperand = false;

  String get phaseLabel => switch (phase) {
    InputPhase.entering => 'Entering operand',
    InputPhase.waiting => 'Waiting for operand',
    InputPhase.result => 'Result ready',
    InputPhase.error => 'Needs attention',
  };

  String get context => accumulator == null
      ? 'LEFT-TO-RIGHT CALCULATOR'
      : '${format(accumulator!)} ${pendingOperator ?? '='}';

  static String format(double value) {
    if (value == 0) return '0';
    final text = value.toStringAsPrecision(12);
    final parts = text.split('e');
    final mantissa = parts.first.contains('.')
        ? parts.first
              .replaceFirst(RegExp(r'0+$'), '')
              .replaceFirst(RegExp(r'\.$'), '')
        : parts.first;
    return parts.length == 1 ? mantissa : '${mantissa}e${parts.last}';
  }

  void clear() {
    display = '0';
    accumulator = null;
    pendingOperator = null;
    phase = InputPhase.entering;
    hasOperand = false;
    message = 'All clear. Enter a number to begin.';
  }

  void digit(String value) {
    if (!RegExp(r'^[0-9]$').hasMatch(value)) return;
    if (phase == InputPhase.result || phase == InputPhase.error) clear();
    if (phase == InputPhase.waiting || !hasOperand) display = '0';
    phase = InputPhase.entering;
    if (display.replaceAll('.', '').length >= 12) {
      message = 'Use up to 12 digits per operand.';
      return;
    }
    display = display == '0' ? value : display + value;
    hasOperand = true;
    message = 'Choose an operator or press equals.';
  }

  void decimal() {
    if (phase == InputPhase.result || phase == InputPhase.error) clear();
    if (phase == InputPhase.waiting || !hasOperand) display = '0';
    phase = InputPhase.entering;
    hasOperand = true;
    if (!display.contains('.')) display += '.';
    message = 'Continue entering the decimal number.';
  }

  void operator(String value) {
    if (!['+', '−', '×', '÷'].contains(value)) return;
    if (phase == InputPhase.error) {
      message = 'Press AC or enter a digit to start again.';
      return;
    }
    if (phase == InputPhase.waiting) {
      pendingOperator = value;
      message = 'Operator replaced. Enter the next number.';
      return;
    }
    if (!hasOperand && phase != InputPhase.result) {
      message = 'Enter a number before choosing an operator.';
      return;
    }
    if (pendingOperator != null && hasOperand) {
      if (!_apply()) return;
    } else {
      accumulator = double.parse(display);
    }
    pendingOperator = value;
    phase = InputPhase.waiting;
    hasOperand = false;
    message = 'Enter the next number.';
  }

  void equals() {
    if (phase == InputPhase.error) return;
    if (phase == InputPhase.waiting) {
      message = 'Enter the next number, then press equals.';
      return; // Preserve the pending operator and accumulator.
    }
    if (phase == InputPhase.result) return;
    if (!hasOperand) {
      message = 'Enter a number first.';
      return;
    }
    if (pendingOperator != null && !_apply()) return;
    accumulator = double.parse(display);
    pendingOperator = null;
    phase = InputPhase.result;
    hasOperand = false;
    message = 'Result ready. A digit starts a new calculation.';
  }

  bool _apply() {
    final right = double.parse(display);
    final left = accumulator!;
    if (pendingOperator == '÷' && right == 0) {
      _fail('Cannot divide by zero. Press AC or enter a digit.');
      return false;
    }
    final answer = switch (pendingOperator) {
      '+' => left + right,
      '−' => left - right,
      '×' => left * right,
      '÷' => left / right,
      _ => right,
    };
    if (!answer.isFinite) {
      _fail('Result is too large. Press AC or enter a digit.');
      return false;
    }
    accumulator = answer;
    display = format(answer);
    return true;
  }

  void _fail(String reason) {
    display = 'Error';
    accumulator = null;
    pendingOperator = null;
    hasOperand = false;
    phase = InputPhase.error;
    message = reason;
  }
}
