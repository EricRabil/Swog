//===--------------------------- OSLogFloatFormatting.swift ------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===------------------------------------------------------------------------------===//

// This file defines types and functions for specifying formatting of
// floating-point typed interpolations passed to the os log APIs.

import Swift

@frozen
public struct BackportedOSLogFloatFormatting {
  /// When set, a `+` will be printed for all non-negative floats.
  @usableFromInline
  internal var explicitPositiveSign: Bool

  /// Whether to use uppercase letters to represent numerals greater than 9
  /// (default is to use lowercase). This applies to hexadecimal digits, NaN, Inf,
  /// the symbols E and X used to denote exponent and hex format.
  @usableFromInline
  internal var uppercase: Bool

  // Note: includePrefix is not supported for FloatFormatting. The format specifier %a
  // always prints a prefix, %efg don't need one.

  /// Number of digits to display following the radix point. Hex notation does not accept
  /// a precision. For non-hex notations, precision can be a dynamic value. The default
  /// precision is 6 for non-hex notations.
  @usableFromInline
  internal var precision: (() -> Int)?

  @usableFromInline
  internal enum Notation {
    /// Hexadecimal formatting.
    case hex

    /// fprintf's `%f` formatting.
    ///
    /// Prints all digits before the radix point, and `precision` digits following
    /// the radix point. If `precision` is zero, the radix point is omitted.
    ///
    /// Note that very large floating-point values may print quite a lot of digits
    /// when using this format, even if `precision` is zero--up to hundreds for
    /// `Double`, and thousands for `Float80`. Note also that this format is
    /// very likely to print non-zero values as all-zero. If these are a concern, use
    /// `.exponential` or `.hybrid` instead.
    ///
    /// Systems may impose an upper bound on the number of digits that are
    /// supported following the radix point.
    case fixed

    /// fprintf's `%e` formatting.
    ///
    /// Prints the number in the form [-]d.ddd...dde±dd, with `precision` significant
    /// digits following the radix point. Systems may impose an upper bound on the number
    /// of digits that are supported.
    case exponential

    /// fprintf's `%g` formatting.
    ///
    /// Behaves like `.fixed` when the number is scaled close to 1.0, and like
    /// `.exponential` if it has a very large or small exponent.
    case hybrid
  }

  @usableFromInline
  internal var notation: Notation

  @_transparent
  @usableFromInline
  internal init(
    explicitPositiveSign: Bool = false,
    uppercase: Bool = false,
    precision: (() -> Int)?,
    notation: Notation
  ) {
    self.explicitPositiveSign = explicitPositiveSign
    self.uppercase = uppercase
    self.precision = precision
    self.notation = notation
  }

  /// Displays an interpolated floating-point value in fprintf's `%f` format with
  /// default precision.
  ///
  /// Prints all digits before the radix point, and 6 digits following the radix point.
  /// Note also that this format is very likely to print non-zero values as all-zero.
  ///
  /// Note that very large floating-point values may print quite a lot of digits
  /// when using this format --up to hundreds for `Double`. Note also that this
  /// format is very likely to print non-zero values as all-zero. If these are a concern,
  /// use `.exponential` or `.hybrid` instead.
  @_semantics("constant_evaluable")
  @inlinable
  @_optimize(speed)
  public static var fixed: BackportedOSLogFloatFormatting { .fixed() }

  /// Displays an interpolated floating-point value in fprintf's `%f` format with
  /// specified precision, and optional sign and case.
  ///
  /// Prints all digits before the radix point, and `precision` digits following
  /// the radix point. If `precision` is zero, the radix point is omitted.
  ///
  /// Note that very large floating-point values may print quite a lot of digits
  /// when using this format, even if `precision` is zero--up to hundreds for
  /// `Double`. Note also that this format is very likely to print non-zero values as
  /// all-zero. If these are a concern, use `.exponential` or `.hybrid` instead.
  ///
  /// Systems may impose an upper bound on the number of digits that are
  /// supported following the radix point.
  ///
  /// All parameters to this function except `precision` must be boolean literals.
  ///
  /// - Parameters:
  ///   - precision: Number of digits to display after the radix point.
  ///   - explicitPositiveSign: Pass `true` to add a + sign to non-negative
  ///     numbers.
  ///   - uppercase: Pass `true` to use uppercase letters or `false` to use
  ///     lowercase letters. The default is `false`.
  @_semantics("constant_evaluable")
  @inlinable
  @_optimize(speed)
  public static func fixed(
    precision: @escaping @autoclosure () -> Int,
    explicitPositiveSign: Bool = false,
    uppercase: Bool = false
  ) -> BackportedOSLogFloatFormatting {
    return BackportedOSLogFloatFormatting(
      explicitPositiveSign: explicitPositiveSign,
      uppercase: uppercase,
      precision: precision,
      notation: .fixed
    )
  }

  /// Displays an interpolated floating-point value in fprintf's `%f` format with
  /// default precision, and optional sign and case.
  ///
  /// Prints all digits before the radix point, and 6 digits following the radix point.
  /// Note also that this format is very likely to print non-zero values as all-zero.
  ///
  /// Note that very large floating-point values may print quite a lot of digits
  /// when using this format, even if `precision` is zero--up to hundreds for
  /// `Double`. Note also that this format is very likely to print non-zero values as
  /// all-zero. If these are a concern, use `.exponential` or `.hybrid` instead.
  ///
  /// Systems may impose an upper bound on the number of digits that are
  /// supported following the radix point.
  ///
  /// All parameters to this function must be boolean literals.
  /// - Parameters:
  ///   - explicitPositiveSign: Pass `true` to add a + sign to non-negative
  ///     numbers.
  ///   - uppercase: Pass `true` to use uppercase letters or `false` to use
  ///     lowercase letters. The default is `false`.
  @_semantics("constant_evaluable")
  @inlinable
  @_optimize(speed)
  public static func fixed(
    explicitPositiveSign: Bool = false,
    uppercase: Bool = false
  ) -> BackportedOSLogFloatFormatting {
    return BackportedOSLogFloatFormatting(
      explicitPositiveSign: explicitPositiveSign,
      uppercase: uppercase,
      precision: nil,
      notation: .fixed
    )
  }

  /// Displays an interpolated floating-point value in hexadecimal format.
  @_semantics("constant_evaluable")
  @inlinable
  @_optimize(speed)
  public static var hex: BackportedOSLogFloatFormatting { .hex() }

  /// Displays an interpolated floating-point value in hexadecimal format with
  /// optional sign and case.
  ///
  /// All parameters to this function must be boolean literals.
  ///
  /// - Parameters:
  ///   - explicitPositiveSign: Pass `true` to add a + sign to non-negative
  ///     numbers.
  ///   - uppercase: Pass `true` to use uppercase letters or `false` to use
  ///     lowercase letters. The default is `false`.
  @_semantics("constant_evaluable")
  @inlinable
  @_optimize(speed)
  public static func hex(
    explicitPositiveSign: Bool = false,
    uppercase: Bool = false
  ) -> BackportedOSLogFloatFormatting {
    return BackportedOSLogFloatFormatting(
      explicitPositiveSign: explicitPositiveSign,
      uppercase: uppercase,
      precision: nil,
      notation: .hex
    )
  }

  /// Displays an interpolated floating-point value in fprintf's `%e` format.
  ///
  /// Prints the number in the form [-]d.ddd...dde±dd.
  @_semantics("constant_evaluable")
  @inlinable
  @_optimize(speed)
  public static var exponential: BackportedOSLogFloatFormatting { .exponential() }

  /// Displays an interpolated floating-point value in fprintf's `%e` format with
  /// specified precision, and optional sign and case.
  ///
  /// Prints the number in the form [-]d.ddd...dde±dd, with `precision` significant
  /// digits following the radix point. Systems may impose an upper bound on the number
  /// of digits that are supported.
  ///
  /// All parameters except `precision` must be boolean literals.
  ///
  /// - Parameters:
  ///   - precision: Number of digits to display after the radix point.
  ///   - explicitPositiveSign: Pass `true` to add a + sign to non-negative
  ///     numbers.
  ///   - uppercase: Pass `true` to use uppercase letters or `false` to use
  ///     lowercase letters. The default is `false`.
  @_semantics("constant_evaluable")
  @inlinable
  @_optimize(speed)
  public static func exponential(
    precision: @escaping @autoclosure () -> Int,
    explicitPositiveSign: Bool = false,
    uppercase: Bool = false
  ) -> BackportedOSLogFloatFormatting {
    return BackportedOSLogFloatFormatting(
      explicitPositiveSign: explicitPositiveSign,
      uppercase: uppercase,
      precision: precision,
      notation: .exponential
    )
  }

  /// Displays an interpolated floating-point value in fprintf's `%e` format with
  /// an optional sign and case.
  ///
  /// Prints the number in the form [-]d.ddd...dde±dd.
  ///
  /// All parameters to this function must be boolean literals.
  ///
  /// - Parameters:
  ///   - explicitPositiveSign: Pass `true` to add a + sign to non-negative
  ///     numbers.
  ///   - uppercase: Pass `true` to use uppercase letters or `false` to use
  ///     lowercase letters. The default is `false`.
  @_semantics("constant_evaluable")
  @inlinable
  @_optimize(speed)
  public static func exponential(
    explicitPositiveSign: Bool = false,
    uppercase: Bool = false
  ) -> BackportedOSLogFloatFormatting {
    return BackportedOSLogFloatFormatting(
      explicitPositiveSign: explicitPositiveSign,
      uppercase: uppercase,
      precision: nil,
      notation: .exponential
    )
  }

  /// Displays an interpolated floating-point value in fprintf's `%g` format.
  ///
  /// Behaves like `.fixed` when the number is scaled close to 1.0, and like
  /// `.exponential` if it has a very large or small exponent.
  @_semantics("constant_evaluable")
  @inlinable
  @_optimize(speed)
  public static var hybrid: BackportedOSLogFloatFormatting { .hybrid() }

  /// Displays an interpolated floating-point value in fprintf's `%g` format with the
  /// specified precision, and optional sign and case.
  ///
  /// Behaves like `.fixed` when the number is scaled close to 1.0, and like
  /// `.exponential` if it has a very large or small exponent.
  ///
  /// All parameters except `precision` must be boolean literals.
  ///
  /// - Parameters:
  ///   - precision: Number of digits to display after the radix point.
  ///   - explicitPositiveSign: Pass `true` to add a + sign to non-negative
  ///     numbers.
  ///   - uppercase: Pass `true` to use uppercase letters or `false` to use
  ///     lowercase letters. The default is `false`.
  @_semantics("constant_evaluable")
  @inlinable
  @_optimize(speed)
  public static func hybrid(
    precision: @escaping @autoclosure () -> Int,
    explicitPositiveSign: Bool = false,
    uppercase: Bool = false
  ) -> BackportedOSLogFloatFormatting {
    return BackportedOSLogFloatFormatting(
      explicitPositiveSign: explicitPositiveSign,
      uppercase: uppercase,
      precision: precision,
      notation: .hybrid
    )
  }

  /// Displays an interpolated floating-point value in fprintf's `%g` format with
  /// optional sign and case.
  ///
  /// Behaves like `.fixed` when the number is scaled close to 1.0, and like
  /// `.exponential` if it has a very large or small exponent.
  ///
  /// All parameters to this function must be boolean literals.
  ///
  /// - Parameters:
  ///   - explicitPositiveSign: Pass `true` to add a + sign to non-negative
  ///     numbers.
  ///   - uppercase: Pass `true` to use uppercase letters or `false` to use
  ///     lowercase letters. The default is `false`.
  @_semantics("constant_evaluable")
  @inlinable
  @_optimize(speed)
  public static func hybrid(
    explicitPositiveSign: Bool = false,
    uppercase: Bool = false
  ) -> BackportedOSLogFloatFormatting {
    return BackportedOSLogFloatFormatting(
      explicitPositiveSign: explicitPositiveSign,
      uppercase: uppercase,
      precision: nil,
      notation: .hybrid
    )
  }
}

extension BackportedOSLogFloatFormatting {
  /// Returns a fprintf-compatible length modifier for a given argument type
  @_semantics("constant_evaluable")
  @inlinable
  @_optimize(speed)
  internal static func _formatStringLengthModifier<I: FloatingPoint>(
    _ type: I.Type
  ) -> StaticString? {
    switch type {
    //   fprintf formatters promote Float to Double
    case is Float.Type: return ""
    case is Double.Type: return ""
#if !os(Windows) && (arch(i386) || arch(x86_64))
    //   fprintf formatters use L for Float80
    case is Float80.Type: return "L"
#endif
    default: return nil
    }
  }

  /// Constructs an os_log format specifier for the given type `type`
  /// using the specified alignment `align` and privacy qualifier `privacy`.
  @_semantics("constant_evaluable")
  @inlinable
  @_optimize(speed)
  internal func formatSpecifier<I: FloatingPoint>(
    for type: I.Type,
    align: BackportedOSLogStringAlignment,
    privacy: BackportedOSLogPrivacy
  ) -> ClumpedStaticString {
    var specification: ClumpedStaticString = "%"
    // Add privacy qualifier after % sign within curly braces. This is an
    // os log specific flag.
    if let privacySpecifier = privacy.privacySpecifier {
      specification += "{"
      specification += privacySpecifier
      specification += "}"
    }

    // 1. Flags
    // IEEE: `+` The result of a signed conversion shall always begin with a sign
    // ( '+' or '-' )
    if explicitPositiveSign {
      specification += "+"
    }

    // IEEE: `-` The result of the conversion shall be left-justified within the field.
    // The conversion is right-justified if this flag is not specified.
    if case .start = align.anchor {
      specification += "-"
    }

    if let _ = align.minimumColumnWidth {
      // The alignment could be a dynamic value. Therefore, use a star here and pass it
      // as an additional argument.
      specification += "*"
    }

    if let _ = precision {
      specification += ".*"
    }

    guard let lengthModifier =
      BackportedOSLogFloatFormatting._formatStringLengthModifier(type) else {
      fatalError("Float type has unknown length")
    }
    specification.append(lengthModifier)

    // 3. Precision and conversion specifier.
    switch notation {
    case .fixed:
      specification += (uppercase ? "F" : "f")
    case .exponential:
      specification += (uppercase ? "E" : "e")
    case .hybrid:
      specification += (uppercase ? "G" : "g")
    case .hex:
      //guard type.radix == 2 else { return nil }
      specification += (uppercase ? "A" : "a")
    default:
      fatalError("Unknown float notation")
    }
    return specification
  }
}

