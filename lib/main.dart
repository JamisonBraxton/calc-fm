import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'calculator_state.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  bool dark = false;
  final calculator = CalculatorState();
  String announcement = 'Calculator ready';
  static const red = Color(0xFFD51007);

  ThemeData makeTheme(Brightness brightness) => ThemeData(
        useMaterial3: true,
        brightness: brightness,
        colorScheme:
            ColorScheme.fromSeed(seedColor: red, brightness: brightness),
        scaffoldBackgroundColor: brightness == Brightness.dark
            ? const Color(0xFF111111)
            : const Color(0xFFF3F3F3),
        fontFamily: 'Roboto',
      );

  void press(String key) => setState(() {
        final previousOperator = calculator.pendingOperator;
        final hadOperand = calculator.hasOperand;
        if (key == 'AC') {
          calculator.clear();
        } else if (key == '=') {
          calculator.equals();
        } else if (key == '.') {
          calculator.decimal();
        } else if (['+', '−', '×', '÷'].contains(key)) {
          calculator.operator(key);
        } else {
          calculator.digit(key);
        }
        if (key == 'AC') {
          announcement = 'All clear. Zero';
        } else if (calculator.phase == InputPhase.error) {
          announcement = calculator.message;
        } else if (key == '=') {
          announcement = calculator.phase == InputPhase.result
              ? 'Result ${calculator.display}'
              : calculator.message;
        } else if (['+', '−', '×', '÷'].contains(key) &&
            previousOperator != null &&
            hadOperand) {
          announcement = 'Running total ${calculator.display}';
        }
      });

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Calc.fm • Calculator State Lab',
        debugShowCheckedModeBanner: false,
        theme: makeTheme(Brightness.light),
        darkTheme: makeTheme(Brightness.dark),
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        themeAnimationDuration: const Duration(milliseconds: 250),
        home: Builder(
          builder: (context) {
            final ink = dark ? Colors.white : const Color(0xFF161616);
            final muted =
                dark ? const Color(0xFFBBBBBB) : const Color(0xFF606060);
            final surface = dark ? const Color(0xFF222222) : Colors.white;
            final border =
                dark ? const Color(0xFF414141) : const Color(0xFFDDDDDD);
            const keys = [
              '7',
              '8',
              '9',
              '÷',
              '4',
              '5',
              '6',
              '×',
              '1',
              '2',
              '3',
              '−',
              '0',
              '.',
              '=',
              '+',
            ];
            return Scaffold(
              body: SafeArea(
                child: Column(
                  children: [
                    Container(
                      color: const Color(0xFF101010),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.graphic_eq, color: red, size: 29),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FittedBox(
                                alignment: Alignment.centerLeft,
                                fit: BoxFit.scaleDown,
                                child: const Text(
                                  'calc.fm',
                                  style: TextStyle(
                                    color: red,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1.4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            dark
                                ? Icons.dark_mode_outlined
                                : Icons.light_mode_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          Semantics(
                            label: 'Dark theme',
                            child: Switch(
                              key: const Key('theme-toggle'),
                              value: dark,
                              activeTrackColor: red,
                              onChanged: (value) =>
                                  setState(() => dark = value),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                            child: Center(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 470),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Make every number count.',
                                      style: TextStyle(
                                        fontSize: 30,
                                        height: 1.08,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -1.1,
                                        color: ink,
                                      ),
                                    ),
                                    const SizedBox(height: 9),
                                    Text(
                                      'Your numbers. One running total.',
                                      style:
                                          TextStyle(color: muted, fontSize: 14),
                                    ),
                                    const SizedBox(height: 20),
                                    Wrap(
                                      alignment: WrapAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 12,
                                      runSpacing: 6,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 4,
                                              height: 18,
                                              color: red,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'CALCULATOR',
                                              style: TextStyle(
                                                color: ink,
                                                fontSize: 11,
                                                letterSpacing: 1.5,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'STATE LAB / 01',
                                          style: TextStyle(
                                            color: muted,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 250),
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: surface,
                                        border: Border.all(color: border),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            calculator.context,
                                            style: TextStyle(
                                              color: muted,
                                              fontSize: 12,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Semantics(
                                            label: 'Calculator display',
                                            child: SizedBox(
                                              height: 65,
                                              width: double.infinity,
                                              child: FittedBox(
                                                alignment:
                                                    Alignment.centerRight,
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  calculator.display,
                                                  key: const Key('display'),
                                                  style: TextStyle(
                                                    fontSize: 58,
                                                    height: 1,
                                                    fontWeight: FontWeight.w700,
                                                    color: ink,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          Divider(color: border, height: 1),
                                          const SizedBox(height: 14),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.circle,
                                                size: 7,
                                                color: red,
                                              ),
                                              const SizedBox(width: 7),
                                              Expanded(
                                                child: Text(
                                                  calculator.phaseLabel,
                                                  style: TextStyle(
                                                    color: muted,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                'L → R',
                                                style: TextStyle(
                                                  color: muted,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: OutlinedButton(
                                        key: const Key('key-AC'),
                                        onPressed: () => press('AC'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: ink,
                                          side: BorderSide(color: border),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                        ),
                                        child: const Text('AC  ·  ALL CLEAR'),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    LayoutBuilder(
                                      builder: (context, grid) {
                                        final extent = math.max(
                                          52.0,
                                          math.min(
                                              76.0, (grid.maxWidth - 24) / 4),
                                        );
                                        return GridView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: keys.length,
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 4,
                                            mainAxisExtent: extent,
                                            crossAxisSpacing: 8,
                                            mainAxisSpacing: 8,
                                          ),
                                          itemBuilder: (context, index) {
                                            final key = keys[index];
                                            final isEquals = key == '=';
                                            final isOperator = [
                                              '+',
                                              '−',
                                              '×',
                                              '÷',
                                            ].contains(key);
                                            final selected =
                                                calculator.pendingOperator ==
                                                    key;
                                            final label = switch (key) {
                                              '÷' => 'Divide',
                                              '×' => 'Multiply',
                                              '−' => 'Subtract',
                                              '+' => 'Add',
                                              '=' => 'Equals',
                                              '.' => 'Decimal point',
                                              _ => key,
                                            };
                                            return Semantics(
                                              label: label,
                                              excludeSemantics: true,
                                              button: true,
                                              onTap: () => press(key),
                                              child: ElevatedButton(
                                                key: Key('key-$key'),
                                                onPressed: () => press(key),
                                                style: ElevatedButton.styleFrom(
                                                  elevation: 0,
                                                  padding: EdgeInsets.zero,
                                                  backgroundColor: isEquals
                                                      ? red
                                                      : isOperator
                                                          ? (dark
                                                              ? const Color(
                                                                  0xFF363636,
                                                                )
                                                              : const Color(
                                                                  0xFFE4E4E4,
                                                                ))
                                                          : surface,
                                                  foregroundColor: isEquals
                                                      ? Colors.white
                                                      : ink,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            3),
                                                    side: BorderSide(
                                                      color: selected
                                                          ? red
                                                          : border,
                                                      width: selected ? 2 : 1,
                                                    ),
                                                  ),
                                                  textStyle: const TextStyle(
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                child: Text(key),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    Semantics(
                                      liveRegion: true,
                                      label: announcement,
                                      child: const SizedBox.shrink(),
                                    ),
                                    Text(
                                      calculator.message,
                                      key: const Key('message'),
                                      style: TextStyle(
                                        color: muted,
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 22),
                                    Divider(color: border),
                                    Text(
                                      'JAMISON BRAXTON  /  CSC 4360',
                                      style: TextStyle(
                                        color: muted,
                                        fontSize: 10,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Last.fm-inspired student project · Not affiliated with Last.fm',
                                      style:
                                          TextStyle(color: muted, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
}
