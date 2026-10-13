# Verification checklist

**Status: the pure Dart transition harness passed all 507 checks. Flutter widget tests and Android device evidence are pending.**

Run `flutter analyze` and `flutter test` from the project folder after generating
the Android scaffold. Record actual output; do not mark checks passed before
running them.

| Check | Input/actions | Expected result | Actual status |
| --- | --- | --- | --- |
| Running total | 2 + 3 × | Display 5, pending × | Pending device check |
| Left-to-right | Continue 4 = | 20 | Pending device check |
| All operations | AC; 20 − 4 ÷ 2 + 3 × 5 = | 55 | Pending device check |
| Replace operator | AC; 9 + × 2 = | 18 | Pending device check |
| Incomplete equals | AC; 7 + = | 7; + remains pending; guidance visible | Pending device check |
| Resume incomplete | Continue 2 = | 9 | Pending device check |
| Digit after result | Then 8 | Fresh operand 8 | Pending device check |
| Continue result | AC; 2 + 3 = × 4 = | 20 | Pending device check |
| Repeated equals | AC; 3 + 4 = = | 7 | Pending device check |
| Reset | Enter 12 + then AC | 0, no pending operator or accumulator | Pending device check |
| Division by zero | AC; 8 ÷ 0 = | Error with recovery instructions | Pending device check |
| Chained zero divisor | AC; 8 ÷ 0 + | Same recoverable error | Pending device check |
| Digit recovery | After error, 6 + 2 = | 8 | Pending device check |
| AC recovery | After error, AC | 0 and fresh state | Pending device check |
| Decimal arithmetic | AC; .5 + .25 = | 0.75 | Pending device check |
| Negative result | AC; 0 − 5 = | -5 | Pending device check |
| Fractional division | AC; 7 ÷ 2 = | 3.5 | Pending device check |
| Theme state | Enter 7 +; change theme; enter 2 = | 9; no arithmetic reset | Pending device check |
| Both themes | Toggle twice | All surfaces readable in each theme | Pending device check |
| Narrow portrait | 320 × 568 logical pixels | Scrollable; usable keypad; no overflow | Pending device check |
| Landscape | 568 × 320 logical pixels | Scrollable; usable keypad; no overflow | Pending device check |
| Accessibility | TalkBack + larger system text | Labels intelligible; controls reachable | Pending device check |
| Release install | Build APK and install on Android | Launch and repeat core/error flows | Pending device check |

## Evidence to capture from the real app

- Light theme showing the running total 5 after `2 + 3 ×`.
- Result 20 after completing `4 =`.
- Dark theme showing the same functional UI.
- Division-by-zero message and successful recovery.
- Narrow-device screenshot and actual emulator/device name.
- Successful analyzer/test output and installed-release verification.

Submit the tested APK, actual GitHub link, and completed Word rationale. Record actual device verification and enter the student ID before submission.
