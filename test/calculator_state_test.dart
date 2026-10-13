import 'package:flutter_test/flutter_test.dart';
import 'package:calculator_app/calculator_state.dart';

void enter(CalculatorState state, String sequence) {
  for (final key in sequence.split('')) {
    if (key == '=') {
      state.equals();
    } else if (key == '.') {
      state.decimal();
    } else if (['+', '−', '×', '÷'].contains(key)) {
      state.operator(key);
    } else {
      state.digit(key);
    }
  }
}

void main() {
  late CalculatorState state;
  setUp(() => state = CalculatorState());

  test('digits build an operand; leading zeros are collapsed', () {
    enter(state, '0072');
    expect(state.display, '72');
    expect(state.hasOperand, isTrue);
  });
  test('digit after operator starts a new operand', () {
    enter(state, '12+3');
    expect(state.display, '3');
    expect(state.accumulator, 12);
    expect(state.pendingOperator, '+');
  });
  test('next operator applies pending operation and shows running total', () {
    enter(state, '2+3×');
    expect(state.display, '5');
    expect(state.accumulator, 5);
    expect(state.phase, InputPhase.waiting);
    enter(state, '4=');
    expect(state.display, '20');
  });
  test('all four operations chain left to right', () {
    enter(state, '20−4÷2+3×5=');
    expect(state.display, '55');
  });
  test('consecutive operators replace the pending operator', () {
    enter(state, '9+×2=');
    expect(state.display, '18');
  });
  test('equals with no new operand preserves arithmetic state', () {
    enter(state, '7+=');
    expect(state.display, '7');
    expect(state.accumulator, 7);
    expect(state.pendingOperator, '+');
    expect(state.phase, InputPhase.waiting);
    enter(state, '2=');
    expect(state.display, '9');
  });
  test('digit after equals starts a fresh calculation', () {
    enter(state, '2+3=8');
    expect(state.display, '8');
    expect(state.accumulator, isNull);
    expect(state.pendingOperator, isNull);
  });
  test('operator after equals continues from the result', () {
    enter(state, '2+3=×4=');
    expect(state.display, '20');
  });
  test('repeated equals does not repeat arithmetic', () {
    enter(state, '3+4===');
    expect(state.display, '7');
  });
  test('AC resets every arithmetic field from each phase', () {
    for (final sequence in ['12', '12+', '12+3=', '8÷0=']) {
      enter(state, sequence);
      state.clear();
      expect(state.display, '0');
      expect(state.accumulator, isNull);
      expect(state.pendingOperator, isNull);
      expect(state.hasOperand, isFalse);
      expect(state.phase, InputPhase.entering);
    }
  });
  test('division by zero errors at equals and recovers with a digit', () {
    enter(state, '8÷0=');
    expect(state.phase, InputPhase.error);
    expect(state.display, 'Error');
    expect(state.message, contains('zero'));
    enter(state, '6+2=');
    expect(state.display, '8');
  });
  test('AC followed by a calculation cannot reuse a stale accumulator', () {
    enter(state, '9+');
    state.clear();
    enter(state, '2+3=');
    expect(state.display, '5');
  });
  test('new calculation after equals cannot reuse a stale accumulator', () {
    enter(state, '9+1=2+3=');
    expect(state.display, '5');
  });
  test('smallest operator replacement counterexample', () {
    enter(state, '1+×2=');
    expect(state.display, '2');
  });
  test('small digit after equals counterexample', () {
    enter(state, '1+1=3');
    expect(state.display, '3');
    expect(state.accumulator, isNull);
  });
  test('division by zero errors during chaining too', () {
    enter(state, '8÷0+');
    expect(state.phase, InputPhase.error);
    state.operator('×');
    expect(state.phase, InputPhase.error);
    expect(state.pendingOperator, isNull);
  });
  test('empty equals or operator provides guidance without arithmetic', () {
    state.equals();
    expect(state.display, '0');
    expect(state.phase, InputPhase.entering);
    state.operator('+');
    expect(state.pendingOperator, isNull);
    expect(state.message, contains('Enter a number'));
  });
  test('zero is a valid operand and negative results work', () {
    enter(state, '0−5=');
    expect(state.display, '-5');
  });
  test('decimal entry rejects duplicates and starts new operands', () {
    enter(state, '.5+.2.5=');
    expect(state.display, '0.75');
  });
  test('decimal after equals starts a fresh calculation', () {
    enter(state, '4+2=.5');
    expect(state.display, '0.5');
    expect(state.accumulator, isNull);
  });
  test('division uses fractional arithmetic', () {
    enter(state, '7÷2=');
    expect(state.display, '3.5');
  });
  test('input is limited to twelve digits', () {
    enter(state, '1234567890123');
    expect(state.display, '123456789012');
    expect(state.message, contains('12 digits'));
  });
  test('very large chained results enter a recoverable error', () {
    enter(state, '999999999999');
    for (var i = 0; i < 30 && state.phase != InputPhase.error; i++) {
      enter(state, '×999999999999×');
    }
    expect(state.phase, InputPhase.error);
    state.clear();
    expect(state.display, '0');
  });
}
