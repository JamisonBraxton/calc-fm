# ChatGPT responses and exact prompts

Agent: ChatGPT, this assignment conversation. Date: October 12, 2026, America/New_York.
These are actual responses authored by ChatGPT for this task. ChatGPT had the assignment
context; Gemini received the same prompt text within its separate conversation.

## Agent Test 01 — Bug Hunt

### Exact prompt
For a left-to-right running-total calculator, propose six key sequences with the expected display after each operator and after equals. Include 2 + 3 × 4, repeated operators, equals without a new operand, and AC reset. Identify which are core contract tests and which need optional error handling.

### ChatGPT response

| Sequence | Display after operators and equals | Classification |
| --- | --- | --- |
| 2 + 3 × 4 = | +: 2; ×: 5; =: 20 | Core left-to-right contract |
| 9 + × 2 = | +: 9; ×: 9; =: 18 | Core operator replacement |
| 7 + = 2 = | +: 7; first =: 7 (still waiting); second =: 9 | Core incomplete-equals contract |
| 9 + AC 2 + 3 = | first +: 9; AC: 0; second +: 2; =: 5 | AC optional feature, required once selected |
| 1 + 1 = 3 + 2 = | first +: 1; first =: 2; digit 3 starts fresh; second +: 3; final =: 5 | Core digit-after-result contract |
| 8 ÷ 0 = AC 6 + 2 = | ÷: 8; first =: Error; AC: 0; +: 6; final =: 8 | Optional error handling and selected AC recovery |

For this assignment, equals with no new operand must not repeat arithmetic. As an additional
regression check, 4 + 2 = = stays at 6. Test internal fields too: after 7 + =, the accumulator
is 7, pending operator is +, phase is waiting, and no new operand exists. After AC, assert
all arithmetic fields reset and then calculate again to expose stale state.

## Agent Test 02 — Accessibility

### Exact prompt
Review a mobile calculator made of a number/operator button grid, a result display, and a light/dark theme. Give five specific accessibility checks or changes for TalkBack users, large text, and color-vision differences. Separate what to test from what to change.

### ChatGPT response

1. **Operator labels.** Test TalkBack announcements for every key. Change ambiguous symbolic
   names to short semantic labels such as Multiply, Divide, Decimal point, and All clear.
   Preserve each key as a distinct actionable button.
2. **Announcements and focus.** Test that a completed running total and final result are
   announced once without moving focus. Change live-region text only when arithmetic is
   committed, an error occurs, or the calculator resets. Avoid rereading the whole number
   after each digit. Use a stable reading order from theme and display through AC to keypad rows.
3. **Large text and narrow layouts.** Test the largest device font setting, narrow portrait,
   and landscape. Change rigid layouts to scroll or reflow. Ensure buttons do not clip labels;
   shrinking a long result may prevent overflow but is not a substitute for readable large text.
4. **Themes and non-color cues.** Test text contrast in both themes and inspect selected
   operators without relying on color perception. Change subtle color-only indications to
   include a border/shape difference, textual context, and semantic state where appropriate.
5. **Targets and input.** Test at least 48 by 48 logical-pixel targets, focus traversal,
   and activation without accidental neighbor taps. Increase hit regions or spacing as
   necessary, and use Flutter semantics tests as a supplement to real TalkBack testing.

## Question 06 — Architecture

### Exact prompt
For a left-to-right calculator, should chained operations live in one stateful widget, a small calculator model, or an expression parser? Compare complexity, testability, and extension cost.

### ChatGPT response

A small calculator model is the best fit. Keep StatefulWidget and setState() for the view,
while the model owns arithmetic transitions. This adds one class but permits fast tests of
input sequences without rendering the UI. Theme changes remain separate from calculations.

A single stateful widget has the lowest initial setup cost and can be appropriate for a tiny
prototype. Its cost rises when arithmetic, formatting, theme controls, and accessibility
logic become interleaved. It is still testable; the problem is coupling, not impossibility.

A parser adds tokenization and evaluation rules that this contract does not need. It is
useful when parentheses or a conventional-precedence mode are added. Parsers are not
inherently incompatible with left-to-right evaluation; they can assign equal precedence.
The simpler running-total state machine is nevertheless easier to align with this rubric.

For the next developer, first separate the editable currentOperand from the derived
formatted display, protect state fields from arbitrary mutation, and use a typed operator
enum. Retain the existing transition tests to demonstrate that refactoring preserves behavior.
