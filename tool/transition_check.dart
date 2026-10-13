import '../lib/calculator_state.dart';

int checks = 0;
void check(bool condition, String name) {
  if (!condition) throw StateError('FAIL: $name');
  checks++;
  print('PASS: $name');
}

void enter(CalculatorState c, String keys) {
  for (final key in keys.split('')) {
    if (key == '=') {
      c.equals();
    } else if (key == '.') {
      c.decimal();
    } else if (['+', '−', '×', '÷'].contains(key)) {
      c.operator(key);
    } else {
      c.digit(key);
    }
    check(
      c.phase != InputPhase.waiting ||
          (c.accumulator != null && c.pendingOperator != null && !c.hasOperand),
      'waiting-state invariant after $key',
    );
  }
}

void main() {
  final c = CalculatorState();
  enter(c, '12+3×');
  check(c.display == '15' && c.accumulator == 15, 'Q1 running total 15');
  enter(c, '4=');
  check(c.display == '60', 'Q1 result 60');
  c.clear();
  enter(c, '2+3×');
  check(c.display == '5', 'Q2 intermediate total 5');
  enter(c, '4=');
  check(c.display == '20', 'Q2 left-to-right result 20');
  for (final example in <String, String>{
    '9+×2=': '18',
    '1+×2=': '2',
    '1+1=3': '3',
    '20−4÷2+3×5=': '55',
    '4+2==': '6',
    '7÷2=': '3.5',
    '0−5=': '-5',
    '.5+.2.5=': '0.75',
  }.entries) {
    c.clear();
    enter(c, example.key);
    check(c.display == example.value, '${example.key} -> ${example.value}');
  }
  c.clear();
  enter(c, '12+3');
  check(c.display == '3' && c.accumulator == 12, 'digit after operator');
  c.clear();
  enter(c, '7+=');
  check(
    c.display == '7' &&
        c.accumulator == 7 &&
        c.pendingOperator == '+' &&
        c.phase == InputPhase.waiting,
    'equals with no operand preserves state',
  );
  enter(c, '2=');
  check(c.display == '9', 'resume after incomplete equals');
  for (final prefix in ['12', '9+', '9+1=', '8÷0=']) {
    c.clear();
    enter(c, prefix);
    c.clear();
    check(
      c.display == '0' &&
          c.accumulator == null &&
          c.pendingOperator == null &&
          c.phase == InputPhase.entering &&
          !c.hasOperand,
      'AC resets after $prefix',
    );
    enter(c, '2+3=');
    check(c.display == '5', 'no stale accumulator after AC from $prefix');
  }
  c.clear();
  enter(c, '9+1=2+3=');
  check(c.display == '5', 'no stale accumulator after result');
  c.clear();
  enter(c, '8÷0=');
  check(
    c.phase == InputPhase.error && c.message.contains('zero'),
    'zero division error',
  );
  enter(c, '6+2=');
  check(c.display == '8', 'digit recovery from error');
  c.clear();
  enter(c, '8÷0+');
  check(c.phase == InputPhase.error, 'zero division while chaining');
  c.clear();
  enter(c, '999999999999');
  for (var i = 0; i < 30 && c.phase != InputPhase.error; i++) {
    enter(c, '×999999999999×');
  }
  check(c.phase == InputPhase.error, 'overflow is recoverable error');
  print(
    'All $checks checks passed. Pure Dart model only; UI/device tests are separate.',
  );
}
