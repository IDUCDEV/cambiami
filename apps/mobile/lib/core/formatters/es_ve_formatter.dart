/// Formateador único es-VE de Cambiami (`design/DESIGN_SYSTEM.md` §8).
///
/// Ninguna pantalla formatea por su cuenta: toda cifra de la app pasa por
/// esta clase. Es una pieza pura: sin estado, sin `DateTime.now()`, sin
/// `Locale` del sistema y sin dependencias de UI.
///
/// Reglas duras de §8:
/// - Decimal con coma y miles con punto, solo a partir de 4 dígitos enteros.
/// - `Bs` pospuesto (`889,58 Bs`) y `$` antepuesto (`$ 1,00`), con espacio.
/// - Menos tipográfico `−` (U+2212), nunca el guion ASCII.
/// - Espacio antes de `%` (`0,04 %`).
///
/// Decisiones a documentar en el test:
/// - D-1: `9:00 a. m.` sin cero a la izquierda (§7.7, §13.2 y design.md),
///   frente al `09:00 a. m.` literal de la tabla de §8.
/// - D-2: `rate` conserva decimales naturales hasta 6, con mínimo de 2.
/// - D-3: `parse('1.234')` se lee como decimal, no como 1 234.
/// - D-4: dólar negativo se escribe `−$ 1,50`.
/// - D-5: los empates de redondeo siguen la semántica de
///   `toStringAsFixed`; no se inventa half-even.
abstract final class EsVeFormatter {
  /// Menos tipográfico U+2212.
  static const String _minus = '\u2212';

  /// Dólar literal, para no escaparlo en cada interpolación.
  static const String _dollar = r'$';

  /// Días de la semana de `DateTime.weekday` (1 = lunes).
  static const List<String> _weekdays = <String>[
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  static final RegExp _nonZero = RegExp('[1-9]');
  static final RegExp _allowedChars = RegExp(r'^[0-9.,]+$');
  static final RegExp _digitsOnly = RegExp(r'^\d+$');
  static final RegExp _spaces = RegExp(r'\s+');

  /// Tasa publicada por la fuente: hasta 6 decimales, mínimo 2.
  ///
  /// `889.5754` → `889,5754 Bs`; `1.5` → `1,50 Bs`.
  static String rate(num value) {
    final fixed = value.toStringAsFixed(6);
    return '${_group(_trimTrailingZeros(fixed))} Bs';
  }

  /// Monto en bolívares: siempre 2 decimales.
  ///
  /// `1234.5` → `1.234,50 Bs`; `999.5` → `999,50 Bs` (sin punto de miles).
  static String bs(num value) => '${_group(value.toStringAsFixed(2))} Bs';

  /// Monto en dólares: `$` delante y siempre 2 decimales.
  ///
  /// `1` → `$ 1,00`; `1234.5` → `$ 1.234,50`; `-1.5` → `−$ 1,50` (D-4).
  static String usd(num value) {
    final amount = _group(value.toStringAsFixed(2));
    return amount.startsWith(_minus)
        ? '$_minus$_dollar ${amount.substring(1)}'
        : '$_dollar $amount';
  }

  /// Variación de la tasa: monto en Bs (2 decimales) y porcentaje.
  ///
  /// `changePct` llega ya en puntos porcentuales (0.04 es 0,04 %), como lo
  /// calcula `record_rate_snapshot()`. El `+` solo aparece en el monto
  /// positivo; el porcentaje positivo va sin signo.
  ///
  /// `(0.32, 0.04)` → `+0,32 Bs (0,04 %)`;
  /// `(-1.55, -0.16)` → `−1,55 Bs (−0,16 %)`;
  /// `(0, 0)` → `0,00 Bs (0,00 %)`.
  static String variation(num change, num changePct) {
    final amount = _group(change.toStringAsFixed(2));
    final percent = _group(changePct.toStringAsFixed(2));
    final positive = !amount.startsWith(_minus) && _nonZero.hasMatch(amount);
    return '${positive ? '+' : ''}$amount Bs ($percent %)';
  }

  /// Brecha: recibe un RATIO y lo convierte a porcentaje.
  ///
  /// `0.1195` → `11,95 %`. No se multiplica dos veces: la UI pasa el ratio
  /// tal cual sale de la vista `rates_latest`.
  static String gap(num ratio) =>
      '${_group((ratio * 100).toStringAsFixed(2))} %';

  /// Fecha larga: `Lunes, 02/11/26`.
  ///
  /// El día de la semana se hardcodea para no depender de `intl` ni del
  /// locale del sistema; `DateTime.weekday` va de 1 (lunes) a 7 (domingo).
  static String date(DateTime value) {
    final weekday = _weekdays[value.weekday - 1];
    final day = _twoDigits(value.day);
    final month = _twoDigits(value.month);
    final year = _twoDigits(value.year % 100);
    return '$weekday, $day/$month/$year';
  }

  /// Hora de 12 horas con sufijo: `9:00 a. m.` (D-1).
  ///
  /// Sin cero a la izquierda, minutos con dos dígitos y sufijo `a. m.` /
  /// `p. m.` separado por un espacio. Medianoche es `12:00 a. m.` y mediodía
  /// `12:00 p. m.`. No convierte zonas horarias: recibe el `DateTime` ya en
  /// la zona de presentación.
  static String time(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = _twoDigits(value.minute);
    final suffix = value.hour < 12 ? 'a. m.' : 'p. m.';
    return '$hour:$minute $suffix';
  }

  /// Convierte el texto del usuario a número.
  ///
  /// Acepta coma y punto como separador decimal, el menos tipográfico `−` y
  /// espacios sobrantes. Devuelve `null` si el texto no es un número válido
  /// (`''`, `abc`, `1,2,3`). Con un único separador se interpreta como
  /// decimal (D-3): `1.234` es 1,234 y no 1 234. Con dos separadores, el
  /// último manda como decimal: `1.234,56` → 1234.56.
  static double? parse(String input) {
    var text = input.replaceAll(_minus, '-').replaceAll(_spaces, '');
    if (text.isEmpty) return null;

    var negative = false;
    if (text.startsWith('+') || text.startsWith('-')) {
      negative = text.startsWith('-');
      text = text.substring(1);
    }
    if (text.isEmpty || !_allowedChars.hasMatch(text)) return null;

    final comma = text.lastIndexOf(',');
    final dot = text.lastIndexOf('.');
    var integerPart = text;
    var decimalPart = '';
    var hasDecimal = false;

    if (comma >= 0 && dot >= 0) {
      final decimal = comma > dot ? comma : dot;
      integerPart = text.substring(0, decimal);
      decimalPart = text.substring(decimal + 1);
      final grouping = decimal == comma ? '.' : ',';
      integerPart = integerPart.replaceAll(grouping, '');
      if (integerPart.contains(',') || integerPart.contains('.')) {
        return null;
      }
      hasDecimal = true;
    } else if (comma >= 0 || dot >= 0) {
      final separator = comma >= 0 ? ',' : '.';
      final parts = text.split(separator);
      if (parts.length == 2) {
        integerPart = parts.first;
        decimalPart = parts.last;
        hasDecimal = true;
      } else {
        if (parts.first.isEmpty || parts.first.length > 3) return null;
        for (final part in parts.skip(1)) {
          if (part.length != 3) return null;
        }
        integerPart = parts.join();
        decimalPart = '';
        hasDecimal = false;
      }
    }

    if (!_digitsOnly.hasMatch(integerPart)) return null;
    if (hasDecimal && !_digitsOnly.hasMatch(decimalPart)) return null;

    final normalized = hasDecimal ? '$integerPart.$decimalPart' : integerPart;
    final value = double.tryParse(normalized);
    if (value == null) return null;
    return negative ? -value : value;
  }

  /// Agrupa la parte entera en bloques de 3 desde la derecha.
  static String _groupDigits(String digits) {
    if (digits.length <= 3) return digits;
    final buffer = StringBuffer();
    var index = digits.length % 3;
    if (index != 0) buffer.write(digits.substring(0, index));
    while (index < digits.length) {
      if (buffer.isNotEmpty) buffer.write('.');
      buffer.write(digits.substring(index, index + 3));
      index += 3;
    }
    return buffer.toString();
  }

  /// Pasa un número ASCII (`-1234.50`) a es-VE (`−1.234,50`).
  ///
  /// El signo se decide sobre el valor ya redondeado: `-0.00` se muestra
  /// como `0,00`, sin menos.
  static String _group(String ascii) {
    final negative = ascii.startsWith('-');
    final unsigned = negative ? ascii.substring(1) : ascii;
    final dot = unsigned.indexOf('.');
    final integer = dot == -1 ? unsigned : unsigned.substring(0, dot);
    final fraction = dot == -1 ? '' : unsigned.substring(dot + 1);
    final grouped = _groupDigits(integer);
    final body = fraction.isEmpty ? grouped : '$grouped,$fraction';
    final isZero = !_nonZero.hasMatch(unsigned);
    return negative && !isZero ? '$_minus$body' : body;
  }

  /// Quita ceros finales de la parte decimal, conservando al menos dos.
  static String _trimTrailingZeros(String fixed) {
    final dot = fixed.indexOf('.');
    if (dot == -1) return fixed;
    var end = fixed.length;
    while (end - dot - 1 > 2 && fixed[end - 1] == '0') {
      end--;
    }
    return fixed.substring(0, end);
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
