import 'package:cambiami/core/error/exceptions.dart';
import 'package:cambiami/core/error/failures.dart';

/// Texto y acción que la presentación necesita para dibujar un error.
///
/// - `message`: copy canónico listo para mostrar (o para decidir silenciarlo
///   en UI, p. ej. degradación de cache).
/// - `canRetry`: si tiene sentido ofrecer la acción "Reintentar".
///
/// **Dónde usarlo:** en la capa de **presentación** (cubit/bloc/estado), como
/// resultado de [ErrorMapper.map]. La UI solo lo renderiza.
typedef ErrorInfo = ({String message, bool canRetry});

/// Único productor de mensajes de error (`DESIGN_SYSTEM.md` §13.4, ADR 0004).
///
/// Centraliza dos traducciones:
/// - [from] / [fromAppException]: `AppException` (datos) → [Failure]
///   (dominio).
/// - [map]: [Failure] (dominio) → [ErrorInfo] (texto + reintento).
///
/// No contiene estado ni dependencias; todos sus miembros son estáticos.
abstract final class ErrorMapper {
  /// Copy canónico para fallos al actualizar/consultar tasas.
  ///
  /// **Dónde usarlo:** lo produce [map] ante fallos de infraestructura
  /// (red, servidor, parseo, cache). No construir mensajes ad-hoc en features.
  static const String updateRates = 'No pudimos actualizar las tasas.';

  /// Copy canónico para la vista vacía ("no hay datos publicados").
  ///
  /// **Dónde usarlo:** en la capa de **presentación** (cubit/UI) al emitir un
  /// estado de vacío (p. ej. `RatesEmpty`) cuando la consulta fue correcta
  /// pero no hay filas. **No** es un [Failure] y **no** lo produce [map].
  static const String noRates = 'No hay tasas publicadas.';

  /// Copy canónico para entrada de monto inválida.
  ///
  /// **Dónde usarlo:** lo produce [map] para [ValidationFailure] de monto.
  /// También puede usarse como referencia canónica al construir una validación
  /// de monto (`ValidationFailure(ErrorMapper.fieldAmount)`).
  static const String invalidAmount = 'Ingresa un monto válido.';

  /// Copy canónico para tasa de cálculo inválida (0 o negativa).
  ///
  /// **Dónde usarlo:** lo produce [map] para
  /// `ValidationFailure(ErrorMapper.fieldRate)`. Úsalo como discriminador
  /// canónico al construir/lanzar esa validación.
  static const String invalidRate = 'No pudimos calcular con esta tasa.';

  /// Etiqueta canónica de la acción de reintento.
  ///
  /// **Dónde usarlo:** en la capa de **presentación/UI** para el botón de
  /// reintentar, normalmente cuando `ErrorInfo.canRetry` es `true` (o en
  /// estados vacíos que ofrezcan reintento).
  static const String retry = 'Reintentar';

  /// Discriminador canónico: validación de monto.
  ///
  /// **Dónde usarlo:** al lanzar/construir
  /// `ValidationException(ErrorMapper.fieldAmount)` o
  /// `ValidationFailure(ErrorMapper.fieldAmount)` (datasource/repositorio/caso
  /// de uso, según dónde ocurra la regla). [map] lo traduce a [invalidAmount].
  static const String fieldAmount = 'amount';

  /// Discriminador canónico: validación de tasa.
  ///
  /// **Dónde usarlo:** al lanzar/construir
  /// `ValidationException(ErrorMapper.fieldRate)` o
  /// `ValidationFailure(ErrorMapper.fieldRate)`. [map] lo traduce a
  /// [invalidRate].
  static const String fieldRate = 'rate';

  /// Convierte cualquier error capturado en un [Failure] de dominio.
  ///
  /// **Capa:** frontera **datos → dominio** (típicamente en el
  /// `RepositoryImpl`, dentro de un `catch (e)`).
  ///
  /// **Cuándo usarlo:**
  /// - Al capturar errores provenientes del datasource/IO y necesitas devolver
  ///   un fallo al dominio (p. ej. `return Left(ErrorMapper.from(e));` cuando
  ///   se use `fpdart`).
  /// - Cuando no sabes si el error capturado es una [AppException] modelada u
  ///   otro `Object` inesperado.
  ///
  /// **Comportamiento:** si [error] es una [AppException], delega en
  /// [fromAppException] (traducción exhaustiva). Si no, aplica un **fallback
  /// único** (`NetworkFailure`) para errores no modelados.
  ///
  /// **Importante:** si necesitas conservar el detalle técnico (`e.toString()`,
  /// body, `statusCode`), **regístralo en el log antes** de llamar a este
  /// método: el detalle no se expone en el [ErrorInfo] de UI.
  ///
  /// **No usarlo en:** datasource (allí se *lanza* la excepción, no se mapea)
  /// ni en presentación (la UI recibe [Failure] y usa [map]).
  static Failure from(Object error) {
    if (error is AppException) {
      return fromAppException(error);
    }
    // Fallback único para errores no modelados.
    return const NetworkFailure();
  }

  /// Traduce una [AppException] modelada a su [Failure] equivalente.
  ///
  /// **Capa:** frontera **datos → dominio** (repositorio / orquestación de
  /// datos).
  ///
  /// **Cuándo usarlo:**
  /// - Cuando ya tienes tipada una [AppException] y quieres la traducción
  ///   directa y exhaustiva.
  /// - Normalmente lo invoca [from]; puedes llamarlo directo si en el `catch`
  ///   atrapaste `on AppException catch (e)`.
  ///
  /// **Comportamiento (exhaustivo sobre la jerarquía sellada):**
  /// - `NetworkException` → `NetworkFailure`.
  /// - `ServerException(code, detail)` → `ServerFailure(code, detail)` (el
  ///   `detail` se conserva solo para diagnóstico/log, nunca para UI).
  /// - `ParseException(field, detail)` → `ParseFailure(field)`.
  /// - `CacheException` → `CacheFailure`.
  /// - `ValidationException(field, detail)` → `ValidationFailure(field)`.
  ///
  /// **No usarlo en:** datasource ni presentación. No produce texto de UI; para
  /// eso usa [map] sobre el [Failure] resultante.
  static Failure fromAppException(AppException exception) {
    if (exception is NetworkException) {
      return const NetworkFailure();
    }
    if (exception is ServerException) {
      return ServerFailure(exception.code, exception.detail);
    }
    if (exception is ParseException) {
      return ParseFailure(exception.field);
    }
    if (exception is CacheException) {
      return const CacheFailure();
    }
    if (exception is ValidationException) {
      return ValidationFailure(exception.field);
    }

    // Inalcanzable: jerarquía sellada totalmente cubierta.
    throw StateError('AppException no contemplada: $exception');
  }

  /// Convierte un [Failure] de dominio en [ErrorInfo] (copy + reintento).
  ///
  /// **Capa:** frontera **dominio → presentación** (cubit/bloc).
  ///
  /// **Cuándo usarlo:**
  /// - Cuando un caso de uso/repositorio devolvió un [Failure] (p. ej. el lado
  ///   `Left` de un `Either`) y el cubit debe emitir un estado de error.
  /// - Para obtener el mensaje canónico y la bandera `canRetry` que la UI
  ///   renderiza (`state.message`, botón [retry] si `canRetry`).
  ///
  /// **Comportamiento:**
  /// - Red → [updateRates], reintentable.
  /// - Servidor → [updateRates], reintentable solo si el código es 5xx (no en
  ///   401/403 ni en otros 4xx/0); ver [_serverRetryable].
  /// - Parseo/cache → [updateRates], no reintentable (la UI puede degradar
  ///   cache en silencio según el estado).
  /// - Validación → [invalidRate] si `field == fieldRate`, en caso contrario
  ///   [invalidAmount]; no reintentable.
  ///
  /// **No usarlo en:** datasource ni repositorio para fabricar copy. La UI no
  /// debe leer campos del [Failure] para decidir el texto: debe usar este
  /// [ErrorInfo]. Los estados que no son fallos (vacío, carga, offline con
  /// datos) no pasan por [map].
  static ErrorInfo map(Failure failure) {
    if (failure is NetworkFailure) {
      return (message: updateRates, canRetry: true);
    }
    if (failure is ServerFailure) {
      return (message: updateRates, canRetry: _serverRetryable(failure.code));
    }
    if (failure is ParseFailure) {
      return (message: updateRates, canRetry: false);
    }
    if (failure is CacheFailure) {
      return (message: updateRates, canRetry: false);
    }
    if (failure is ValidationFailure) {
      final message = failure.field == fieldRate ? invalidRate : invalidAmount;
      return (message: message, canRetry: false);
    }

    // Inalcanzable: jerarquía sellada totalmente cubierta.
    throw StateError('Failure no contemplado: $failure');
  }

  /// Determina si un error de servidor es reintentable según su [code] HTTP.
  ///
  /// **Capa:** uso **interno** de [ErrorMapper] (lo invoca [map]); no forma
  /// parte de la API pública pensada para features.
  ///
  /// **Cuándo aplica:** solo para [ServerFailure].
  ///
  /// **Regla:**
  /// - `401`, `403` → `false` (configuración/permisos; reintentar no lo
  ///   corrige).
  /// - `>= 500` → `true` (fallo transitorio del servidor).
  /// - Resto (otros 4xx, `0`, etc.) → `false`.
  static bool _serverRetryable(int code) {
    if (code == 401 || code == 403) return false;
    return code >= 500;
  }
}
