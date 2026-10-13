# Calc.fm — Calculator State Lab

Jamison Braxton · CSC 4360 undergraduate pathway

Flutter/Dart calculator inspired by Last.fm's red, black, and neutral visual theme.
Selected features: **theme toggle, all clear, and error handling**.

## Current status

- Full assignment requirements and expanded reflection questions reviewed.
- Arithmetic source, responsive Flutter UI, and reflection document written.
- Actual Gemini Flash-Lite and ChatGPT comparisons completed for two Test Drive
  prompts and the architecture question. Transcripts and decisions included.
- Pure Dart model harness executed: **507 checks passed** (including repeated
  per-tap invariants, not 507 independent test cases).
- 23 Flutter model test cases and 6 widget test cases supplied; Flutter suite unverified.
- No APK, emulator/device verification, or GitHub repository upload completed here.
- Flutter startup was automatically blocked after attempting cloud instance-metadata
  access. The local dependency-free Dart harness completed without that startup path.

## Open and run on your Windows computer

Extract the ZIP. In VS Code, open the `calculator_app` folder, then choose
**Terminal → New Terminal**. The terminal must be in the folder with `pubspec.yaml`.
Run these commands one at a time using your installed Flutter SDK:

```powershell
flutter doctor
flutter create --platforms=android --project-name calculator_app .
flutter pub get
dart format lib test tool
flutter analyze
flutter test
dart tool/transition_check.dart
flutter devices
flutter run
```

`flutter create` supplies Android platform files missing from this source-only package.
Do not use `--overwrite`; retain the provided lib and test files. If it generates a
counter-app sample test, remove that sample and retain the supplied calculator tests.
Launch an Android emulator or connect an Android device before `flutter run`.

## Build and test the required APK

```powershell
flutter build apk
Copy-Item build\app\outputs\flutter-apk\app-release.apk JamisonBraxton_CalculatorApp.apk
flutter install --release
```

Install the release on an emulator/device, repeat the checklist in docs, and capture
actual evidence. This task requires a tested APK, not just source code or a renamed ZIP.

## GitHub and submission

1. Generate the Android project files with the commands above. Create a new GitHub
   repository (for example `Calculator-State-Lab`) and upload the whole project,
   including `android/`, `lib/`, `test/`, `tool/`, `pubspec.yaml`, and `pubspec.lock`.
   Exclude build caches, local.properties, .dart_tool, and private student-ID material.
2. Ensure the instructor can access that repository. Create `github_link.txt`
   containing the repository's **actual URL**, by itself. No URL has been invented.
3. Add your student ID to `JamisonBraxton_Implementation.docx`. Update its verification
   status after running Flutter tests and installing the release APK.
4. Submit exactly these required deliverables to the course's designated location:
   - `github_link.txt`
   - `JamisonBraxton_CalculatorApp.apk`
   - `JamisonBraxton_Implementation.docx`

The source ZIP is a convenience package, not a substitute for the APK or repository.

## Behavior and files

- `2 + 3 × 4 =` → 20; the × tap immediately displays 5.
- `9 + × 2 =` → 18. Repeated operators replace the pending operator.
- `7 + =` → 7 with + still pending. `4 + 2 = =` stays 6.
- A digit after equals starts fresh. AC clears all arithmetic fields.
- Zero division/overflow show recoverable errors; AC or a digit restarts.
- Inputs allow 12 digits; results show up to 12 significant digits.
- Theme choice and arithmetic state are independent, and neither persists across restart.

`lib/main.dart` holds the UI and setState callbacks. `lib/calculator_state.dart`
contains the framework-independent state machine. `tool/transition_check.dart`
is the executed dependency-free model harness. `docs/transition_results.txt`
contains its real output. Flutter tests are in `test/`.

The Word rationale is supplied beside this project in the ZIP. AI records are in
`docs/chatgpt_responses.md`, `docs/gemini_transcript.txt`, and `docs/gemini_evidence.jpg`.

References: https://www.last.fm/ and the course's supplied Calculator State Lab assignment.
The app uses no Last.fm logo/assets, API, or network requests.
