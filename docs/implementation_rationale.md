# Implementation rationale

See JamisonBraxton_Implementation.docx in the package root for the formatted version, state diagram, and tables.

Calculator Implementation Rationale

Jamison Braxton | CSC 4360 | Assignment 01 Calculator State Lab

Student ID: ____________________

Calc.fm is a Flutter calculator with a Last.fm-inspired red, black, and neutral interface. It evaluates arithmetic from left to right and makes the input phase visible. This report explains the state contract, the three selected features, transition tests, accessibility decisions, and a comparison of actual Gemini and ChatGPT responses.

Selected undergraduate features

Theme toggle, clear / all clear, and error handling are the three selected enhanced features. Decimal input is also supported as basic numeric input. Percentage and sign toggle are not selected. Standard Material button feedback is used, rather than claiming a separate custom animation feature.

Implementation and evidence

CalculatorState in lib/calculator_state.dart handles the arithmetic. CalculatorApp in lib/main.dart is a StatefulWidget; button callbacks call model methods inside setState(). The theme switch changes themeMode without resetting arithmetic. LayoutBuilder, a constrained content width, a four-column GridView, and vertical scrolling support different screen sizes.

The dependency-free Dart transition harness ran successfully: all 507 checks passed, including repeated invariant checks after individual taps. The result is recorded in docs/transition_results.txt. The 23 flutter_test model cases and 6 widget cases have been written, but the Flutter suite and Android release have not been validated. This distinction matters: model results do not prove device behavior.

Design choices

The original Calc.fm wordmark, black header, red equals button, bold heading, and simple surfaces reflect the requested Last.fm theme. The display prioritizes the current operand or result, while a smaller context line shows the accumulator and pending operator. Light and dark surfaces transition over 250 milliseconds.

AI assistance disclosure

ChatGPT assisted with code, test design, this rationale, and the comparison. Gemini Flash-Lite was consulted through its web interface. Both agents received the two selected Test Drive prompts and the architecture question on October 12, 2026, America/New_York. Gemini responses are preserved in docs/gemini_transcript.txt; ChatGPT responses are in docs/chatgpt_responses.md. The Gemini prompts were submitted by the assistant on my behalf. No AI answer is treated as test evidence.

01 State as a transition system

The following drawing records the state before input and after each tap in 12 + 3 × 4 =. Read the top row left to right, then follow the arrow down and the bottom row right to left. Each box lists display / accumulator / pending operator / phase; a dash means null.

The final result is 60: the multiply tap first commits 12 + 3 = 15, then equals commits 15 × 4. A waiting state displays the running accumulator even though no new operand has been entered.

Authoritative fields and derived values

The accumulator, pendingOperator, and phase are authoritative. In this implementation, display also stores the editable current-operand text during entry; there is no separate currentOperand field. That preserves partial input such as 0. or 1.20. Outside entry, display is a stored formatted result. hasOperand distinguishes real input from the initial zero and from a displayed total while waiting. The context and phaseLabel getters derive their visible text from the model.

A cleaner future representation would store currentOperand separately and derive display from phase, currentOperand, and accumulator. Storing a second independent numeric display value would risk divergence. The present model avoids an independent operand number, but still requires transitions to keep its display buffer and accumulator consistent.

Invariant

After every tap, waiting implies accumulator is non-null, pendingOperator is non-null, and hasOperand is false. Result phase has no pending operator. AC establishes display 0, null accumulator and operator, entering phase, and no operand. The local harness checks the waiting invariant after every key in its sequences and checks every reset field.

State transitions

02 Trace the evaluation contract

This calculator commits the pending operation whenever another operator follows an operand. Therefore 2 + 3 × 4 means (2 + 3) × 4 = 20. A conventional expression calculator defers evaluation and gives multiplication precedence, so 2 + (3 × 4) = 14.

The regression checks assert both intermediate 5 after 2 + 3 × and final 20 after 4 =. An implementation that silently switches to conventional precedence fails the final check; an implementation that delays computation until equals fails the intermediate check. These checks passed in tool/transition_check.dart.

03 Design transition focused tests

The last two tests are the important pair for stale accumulator bugs. They first create old state, cross a reset boundary, and then calculate again. A display-only AC check can pass while retaining the old accumulator. Likewise, entering a digit after equals may look correct while hidden state contaminates the next operation. Both full follow-up calculations passed in the local harness.

04 Accessibility across state changes

A screen reader should announce a committed running total when the next operator applies arithmetic, the final result on equals, and meaningful errors or resets. It should not reread the entire number after every digit. Button feedback already identifies the pressed key. Focus should remain on the control used rather than jumping to the display.

The UI keeps a separate announcement string in a live Semantics region. It becomes Running total 5 when × commits 2 + 3, remains unchanged when 4 is entered, and becomes Result 20 on equals. The visible numeric display remains available to read but is not itself a live region. Help text is visible without generating a second automatic announcement.

The proposed focus order is theme switch, display and calculation context, AC, then the keypad in row order: 7 8 9 Divide; 4 5 6 Multiply; 1 2 3 Subtract; 0 Decimal point Equals Add. Use concise spoken labels and preserve separate actionable semantics nodes for every key. The existing widget tree follows that order; actual TalkBack traversal still needs verification.

The widget test announce committed totals instead of each digit enables semantics, enters 2 + 3 × 4 =, and checks that the live label changes only at the committed total and final result. This test is written but has not run. On an Android device, repeat it with TalkBack and verify that feedback is neither missing nor duplicated and that focus remains stable.

05 AI logic under adversarial input

A short counterexample for operator replacement is 1 + × 2 =, which must produce 2. An implementation that evaluates the second operator immediately can incorrectly add 1 to itself and later multiply, producing 4. Another short counterexample is 1 + 1 = 3: the display must become 3, not 23. A longer follow-up, 9 + 1 = 2 + 3 =, catches hidden accumulator reuse even when the first new digit looks correct.

The repair is to handle waiting before arithmetic in operator(): replace pendingOperator and return. In digit(), check result/error phases first and clear the old calculation before adding the new input. Both branches already exist in CalculatorState. The counterexample tests and the follow-up calculation passed in the local harness.

These are implementation defects because the assignment explicitly requires replacement and a fresh calculation after equals. A behavior not specified by the contract, such as the number of displayed significant digits, is a design choice to document rather than an automatic bug. This implementation uses 12 significant digits and ignores repeated equals without a new operand.

06 Architecture and maintainability

Both agents received this exact question: “For a left-to-right calculator, should chained operations live in one stateful widget, a small calculator model, or an expression parser? Compare complexity, testability, and extension cost.”

Gemini recommended a framework-independent calculator model, emphasizing isolated unit tests and lower extension cost. ChatGPT also recommended a small model while retaining StatefulWidget and setState() for the UI. That advice fits this assignment: CalculatorState imports no Flutter code, and the actual Dart harness ran its transitions without a widget or emulator.

I accept the separation of logic from rendering. I do not accept the strongest wording in Gemini’s response: a model does not guarantee flawless tests or effortless extensions, and an expression parser can be configured for equal-precedence left-to-right evaluation. It is simply more machinery than this running-total contract needs. A small, well-organized stateful widget can also be reasonable for a prototype.

The first refactor would separate currentOperand text from formatted output and make display a getter. I would then replace string operators with an enum and keep state fields private so only transitions can change them. The current tests should remain unchanged during that refactor to demonstrate preserved behavior.

Challenges and decisions

The central challenge was distinguishing a displayed total from a newly entered operand. The waiting phase and hasOperand flag prevent the previous number from being reused when an operator is replaced or equals is pressed early. A second challenge was making errors recoverable without leaving a pending operation behind; _fail() clears the arithmetic fields, and AC or a digit can start over.

The accessibility review led to replacing per-digit live output with event-based announcements. Width constraints, scrolling, and fit-to-width result text address basic layout pressure, but shrinking text is not a complete large-text accessibility solution. Large-text and TalkBack behavior remain device verification tasks.

AI Test Drive comparison

Agents: ChatGPT in this conversation and Gemini Flash-Lite in an unsigned web session. Date: October 12, 2026, America/New_York. Selected prompts: Bug Hunt and Accessibility. The identical prompt text and ChatGPT responses are preserved in docs/chatgpt_responses.md; Gemini’s observed responses are in docs/gemini_transcript.txt. The first Gemini bug-hunt generation was interrupted and redone; the completed second version is the one compared here.

Prompt 01 Bug Hunt

Gemini correctly traced 2 + 3 × 4 = to 20 and described replacing an operator. However, it treated a repeated equals as repetition of the last operation: 4 + 2 = = produced 8 in its proposed test. It also called AC a core feature without qualifying that AC is selected optionally in this assignment. Its zero-division recovery required clear, whereas this app also permits a new digit.

ChatGPT’s response followed the provided contract: 7 + = leaves 7 and the pending + unchanged; 4 + 2 = = remains 6. It distinguished mandatory transitions from selected AC and error-handling features. ChatGPT had the full assignment context in this conversation; Gemini received the unchanged standalone prompt. This is a practical advice comparison, not a controlled model benchmark.

Decision: accept Gemini’s sequential arithmetic and operator replacement suggestions, but reject repeated-operation equals for this assignment. Verification: the actual local harness ran 4 + 2 = = and returned 6, and it checked that 7 + = preserves the accumulator, operator, display, and waiting phase. These results resolve the disagreement against the specification rather than by majority vote.

Prompt 02 Accessibility

Both agents recommended meaningful labels, logical focus order, large-text testing, contrast checks, non-color state cues, and usable touch targets. Gemini supplied Android XML/Compose examples and suggested announcing the result whenever it changes. ChatGPT recommended Flutter Semantics and announcing committed totals rather than every keystroke.

Decision: accept the accessibility goals, translate Android-specific API advice to Flutter, and avoid a live announcement for every digit. Preserve a separate button node for each key; do not merge the entire keypad into one inaccessible action. The implementation uses explicit operator labels, a thicker selected-operator border, text context, scrollable content, and a separate live announcement label. The written semantics test targets that policy; actual TalkBack, contrast, and large-text checks are still pending.

Evidence and remaining verification

Model evidence: tool/transition_check.dart and docs/transition_results.txt; all 507 checks passed with Dart 3.13.5. Source evidence: digit(), operator(), equals(), clear(), and _apply() in CalculatorState; press() and Semantics widgets in main.dart. Flutter tests are supplied separately and are not claimed as executed.

Before submission: enter the student ID, run flutter analyze and flutter test, build and install the APK, verify the app on Android, publish the complete project to an instructor-accessible GitHub repository, and create github_link.txt with its actual URL. The APK must be named JamisonBraxton_CalculatorApp.apk. The Word document uses the required JamisonBraxton_Implementation.docx filename.

References: supplied Calculator State Lab assignment and the expanded questions; https://www.last.fm/; https://docs.flutter.dev/ui/accessibility; https://api.flutter.dev/flutter/material/Switch/Switch.html. Gemini session: https://gemini.google.com/app/e47f757534e04151 (anonymous session availability is not guaranteed; the local transcript is preserved).