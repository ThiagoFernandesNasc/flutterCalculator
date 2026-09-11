import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  bool isDarkMode = true;

  void toggleTheme() {
    setState(() => isDarkMode = !isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
      home: CalculatorScreen(
        isDarkMode: isDarkMode,
        onToggleTheme: toggleTheme,
      ),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const CalculatorScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _equation = '';

  double? _firstOperand;
  String? _pendingOperator;
  bool _shouldResetDisplay = false;

  static const Color _darkBackground = Color(0xFF17161D);
  static const Color _lightBackground = Color(0xFFF2F7F7);
  static const Color _darkNumberButton = Color(0xFF2B2A33);
  static const Color _darkFunctionButton = Color(0xFF5A5F6D);
  static const Color _lightNumberButton = Colors.white;
  static const Color _lightFunctionButton = Color(0xFFDCE1E7);
  static const Color _operatorButton = Color(0xFF4F62F6);
  static const Color _mutedDarkText = Color(0xFF7F7D88);
  static const Color _mutedLightText = Color(0xFF999BA3);
  static const String _divide = '\u00F7';
  static const String _multiply = '\u00D7';

  Color get _backgroundColor =>
      widget.isDarkMode ? _darkBackground : _lightBackground;

  Color get _numberButtonColor =>
      widget.isDarkMode ? _darkNumberButton : _lightNumberButton;

  Color get _functionButtonColor =>
      widget.isDarkMode ? _darkFunctionButton : _lightFunctionButton;

  Color get _primaryTextColor =>
      widget.isDarkMode ? Colors.white : Colors.black;

  Color get _mutedTextColor =>
      widget.isDarkMode ? _mutedDarkText : _mutedLightText;

  String get _clearLabel => _display == '0' && _equation.isEmpty ? 'AC' : 'C';

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final shortestSide = media.size.shortestSide;
    final calculatorWidth = shortestSide < 430 ? shortestSide : 390.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: widget.isDarkMode
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        color: _backgroundColor,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const horizontalPadding = 40.0;
                const verticalPadding = 20.0;
                const rowOuterGap = 12.0;
                const buttonOuterGap = 12.0;
                final widthButtonSize =
                    (calculatorWidth - horizontalPadding - buttonOuterGap * 4) /
                    4;
                final heightButtonSize =
                    (constraints.maxHeight -
                            verticalPadding -
                            30 -
                            116 -
                            16 -
                            24) /
                        5 -
                    rowOuterGap;
                final buttonSize = widthButtonSize
                    .clamp(54.0, heightButtonSize.clamp(54.0, 86.0))
                    .toDouble();

                return Center(
                  child: SizedBox(
                    width: calculatorWidth,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                      child: Column(
                        children: [
                          _buildThemeToggle(),
                          const Spacer(flex: 2),
                          _buildDisplay(),
                          const SizedBox(height: 16),
                          _buildKeypad(buttonSize),
                          const Spacer(),
                          _buildHomeIndicator(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle() {
    return GestureDetector(
      onTap: widget.onToggleTheme,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 60,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: widget.isDarkMode
              ? const Color(0xFF292936)
              : const Color(0xFFE6ECEF),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              alignment: widget.isDarkMode
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: widget.isDarkMode
                      ? const Color(0xFF4B4F5D)
                      : const Color(0xFFC8CDD2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            AnimatedAlign(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              alignment: widget.isDarkMode
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Icon(
                widget.isDarkMode ? Icons.dark_mode : Icons.wb_sunny_rounded,
                size: 18,
                color: widget.isDarkMode
                    ? const Color(0xFF6375FF)
                    : const Color(0xFF6778FF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplay() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            height: 32,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                _equation,
                maxLines: 1,
                style: TextStyle(
                  color: _mutedTextColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              _display,
              maxLines: 1,
              style: TextStyle(
                color: _primaryTextColor,
                fontSize: 72,
                height: 1,
                fontWeight: FontWeight.w300,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad(double buttonSize) {
    final rows = <List<_ButtonSpec>>[
      [
        _ButtonSpec(_clearLabel, _CalcButtonType.function, _onClearPressed),
        _ButtonSpec('+/-', _CalcButtonType.function, _onPlusMinusPressed),
        _ButtonSpec('%', _CalcButtonType.function, _onPercentPressed),
        _ButtonSpec(
          _divide,
          _CalcButtonType.operator,
          () => _onOperatorPressed(_divide),
        ),
      ],
      [
        _ButtonSpec('7', _CalcButtonType.number, () => _onDigitPressed('7')),
        _ButtonSpec('8', _CalcButtonType.number, () => _onDigitPressed('8')),
        _ButtonSpec('9', _CalcButtonType.number, () => _onDigitPressed('9')),
        _ButtonSpec(
          _multiply,
          _CalcButtonType.operator,
          () => _onOperatorPressed(_multiply),
        ),
      ],
      [
        _ButtonSpec('4', _CalcButtonType.number, () => _onDigitPressed('4')),
        _ButtonSpec('5', _CalcButtonType.number, () => _onDigitPressed('5')),
        _ButtonSpec('6', _CalcButtonType.number, () => _onDigitPressed('6')),
        _ButtonSpec(
          '-',
          _CalcButtonType.operator,
          () => _onOperatorPressed('-'),
        ),
      ],
      [
        _ButtonSpec('1', _CalcButtonType.number, () => _onDigitPressed('1')),
        _ButtonSpec('2', _CalcButtonType.number, () => _onDigitPressed('2')),
        _ButtonSpec('3', _CalcButtonType.number, () => _onDigitPressed('3')),
        _ButtonSpec(
          '+',
          _CalcButtonType.operator,
          () => _onOperatorPressed('+'),
        ),
      ],
      [
        _ButtonSpec('.', _CalcButtonType.number, _onDecimalPressed),
        _ButtonSpec('0', _CalcButtonType.number, () => _onDigitPressed('0')),
        _ButtonSpec(
          'backspace',
          _CalcButtonType.number,
          _onBackspace,
          icon: Icons.backspace_outlined,
        ),
        _ButtonSpec('=', _CalcButtonType.operator, _onEqualsPressed),
      ],
    ];

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((spec) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _buildButton(spec, buttonSize),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildButton(_ButtonSpec spec, double buttonSize) {
    final isSelectedOperator =
        spec.type == _CalcButtonType.operator &&
        _pendingOperator == spec.label &&
        _shouldResetDisplay;

    Color backgroundColor;
    Color foregroundColor;

    switch (spec.type) {
      case _CalcButtonType.number:
        backgroundColor = _numberButtonColor;
        foregroundColor = _primaryTextColor;
        break;
      case _CalcButtonType.function:
        backgroundColor = _functionButtonColor;
        foregroundColor = _primaryTextColor;
        break;
      case _CalcButtonType.operator:
        backgroundColor = _operatorButton;
        foregroundColor = Colors.white;
        break;
    }

    return SizedBox.square(
      dimension: buttonSize,
      child: Material(
        color: isSelectedOperator ? Colors.white : backgroundColor,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: spec.onTap,
          child: Center(
            child: spec.icon == null
                ? Text(
                    spec.label,
                    style: TextStyle(
                      color: isSelectedOperator
                          ? _operatorButton
                          : foregroundColor,
                      fontSize: spec.label.length > 2 ? 22 : 25,
                      fontWeight: FontWeight.w500,
                      height: 1,
                    ),
                  )
                : Icon(
                    spec.icon,
                    color: isSelectedOperator
                        ? _operatorButton
                        : foregroundColor,
                    size: 21,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeIndicator() {
    return Container(
      width: 104,
      height: 4,
      margin: const EdgeInsets.only(top: 18, bottom: 2),
      decoration: BoxDecoration(
        color: _primaryTextColor,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }

  void _onDigitPressed(String digit) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_shouldResetDisplay || _display == '0' || _display == 'Erro') {
        _display = digit;
        _shouldResetDisplay = false;
        return;
      }

      if (_plainDigitCount >= 9) return;
      _display = _formatTypingValue(_plainDisplay + digit);
    });
  }

  void _onDecimalPressed() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_shouldResetDisplay || _display == 'Erro') {
        _display = '0.';
        _shouldResetDisplay = false;
        return;
      }

      if (!_display.contains('.')) {
        _display = '$_display.';
      }
    });
  }

  void _onClearPressed() {
    HapticFeedback.mediumImpact();
    setState(() {
      _display = '0';
      _equation = '';
      _firstOperand = null;
      _pendingOperator = null;
      _shouldResetDisplay = false;
    });
  }

  void _onPlusMinusPressed() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_display == '0' || _display == 'Erro') return;
      _display = _display.startsWith('-')
          ? _display.substring(1)
          : '-$_display';
    });
  }

  void _onPercentPressed() {
    HapticFeedback.lightImpact();
    setState(() {
      final value = _currentValue;
      if (value == null) return;
      _display = _formatNumber(value / 100);
    });
  }

  void _onOperatorPressed(String operator) {
    HapticFeedback.lightImpact();
    setState(() {
      final currentValue = _currentValue;
      if (currentValue == null) return;

      if (_pendingOperator != null && !_shouldResetDisplay) {
        _firstOperand = _calculate(
          _firstOperand!,
          currentValue,
          _pendingOperator!,
        );
        _display = _formatNumber(_firstOperand!);
      } else {
        _firstOperand = currentValue;
      }

      _equation = '${_formatNumber(_firstOperand!)} $operator';
      _pendingOperator = operator;
      _shouldResetDisplay = true;
    });
  }

  void _onEqualsPressed() {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_pendingOperator == null || _firstOperand == null) return;

      final currentValue = _currentValue;
      if (currentValue == null) return;

      _equation =
          '${_formatNumber(_firstOperand!)} $_pendingOperator ${_formatNumber(currentValue)}';
      _display = _formatNumber(
        _calculate(_firstOperand!, currentValue, _pendingOperator!),
      );
      _pendingOperator = null;
      _firstOperand = null;
      _shouldResetDisplay = true;
    });
  }

  void _onBackspace() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_shouldResetDisplay || _display == 'Erro') return;

      final plain = _plainDisplay;
      if (plain.length <= 1 || (plain.length == 2 && plain.startsWith('-'))) {
        _display = '0';
        return;
      }

      _display = _formatTypingValue(plain.substring(0, plain.length - 1));
    });
  }

  double _calculate(double a, double b, String operator) {
    switch (operator) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case _multiply:
        return a * b;
      case _divide:
        return b == 0 ? double.nan : a / b;
      default:
        return b;
    }
  }

  double? get _currentValue {
    if (_display == 'Erro') return null;
    return double.tryParse(_display.replaceAll(',', ''));
  }

  String get _plainDisplay => _display.replaceAll(',', '');

  int get _plainDigitCount =>
      _plainDisplay.replaceAll('-', '').replaceAll('.', '').length;

  String _formatTypingValue(String value) {
    if (value.endsWith('.')) {
      return '${_formatIntegerPart(value.substring(0, value.length - 1))}.';
    }

    final parts = value.split('.');
    final integer = _formatIntegerPart(parts.first);
    return parts.length > 1 ? '$integer.${parts.last}' : integer;
  }

  String _formatNumber(double value) {
    if (value.isNaN || value.isInfinite) return 'Erro';

    final rounded = value.abs() >= 1e12
        ? value.toStringAsExponential(4)
        : value.toStringAsFixed(6);
    final normalized = rounded
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');

    if (normalized.contains('e')) return normalized;
    return _formatTypingValue(normalized);
  }

  String _formatIntegerPart(String value) {
    final isNegative = value.startsWith('-');
    final digits = isNegative ? value.substring(1) : value;
    if (digits.isEmpty) return isNegative ? '-' : '0';

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      if (i > 0 && remaining % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }

    return '${isNegative ? '-' : ''}$buffer';
  }
}

enum _CalcButtonType { number, function, operator }

class _ButtonSpec {
  final String label;
  final _CalcButtonType type;
  final VoidCallback onTap;
  final IconData? icon;

  const _ButtonSpec(this.label, this.type, this.onTap, {this.icon});
}
