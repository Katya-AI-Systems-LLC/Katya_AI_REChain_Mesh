/// A simple complex number implementation for quantum computing
library;

import 'dart:math' as math;

class ComplexNumber {
  /// The real part of the complex number
  final double real;

  /// The imaginary part of the complex number
  final double imaginary;

  /// Creates a complex number with the given real and imaginary parts
  const ComplexNumber(this.real, this.imaginary);

  /// The complex number 0 + 0i
  static const zero = ComplexNumber(0, 0);

  /// The complex number 1 + 0i
  static const one = ComplexNumber(1, 0);

  /// The imaginary unit i (0 + 1i)
  static const i = ComplexNumber(0, 1);

  /// Creates a complex number from polar coordinates
  factory ComplexNumber.fromPolar(double r, double theta) {
    return ComplexNumber(
      r * _cos(theta),
      r * _sin(theta),
    );
  }

  /// The modulus (magnitude) of the complex number
  double get modulus => _sqrt(real * real + imaginary * imaginary);

  /// The argument (angle) of the complex number in radians
  double get argument => _atan2(imaginary, real);

  /// The complex conjugate
  ComplexNumber get conjugate => ComplexNumber(real, -imaginary);

  /// The square of the modulus
  double get modulusSquared => real * real + imaginary * imaginary;

  /// Adds two complex numbers
  ComplexNumber operator +(ComplexNumber other) {
    return ComplexNumber(
      real + other.real,
      imaginary + other.imaginary,
    );
  }

  /// Subtracts two complex numbers
  ComplexNumber operator -(ComplexNumber other) {
    return ComplexNumber(
      real - other.real,
      imaginary - other.imaginary,
    );
  }

  /// Multiplies two complex numbers
  ComplexNumber operator *(dynamic other) {
    if (other is num) {
      return ComplexNumber(real * other, imaginary * other);
    } else if (other is ComplexNumber) {
      return ComplexNumber(
        real * other.real - imaginary * other.imaginary,
        real * other.imaginary + imaginary * other.real,
      );
    }
    throw ArgumentError('Can only multiply by num or ComplexNumber');
  }

  /// Divides this complex number by another
  ComplexNumber operator /(dynamic other) {
    if (other is num) {
      return ComplexNumber(real / other, imaginary / other);
    } else if (other is ComplexNumber) {
      final denom = other.modulusSquared;
      return ComplexNumber(
        (real * other.real + imaginary * other.imaginary) / denom,
        (imaginary * other.real - real * other.imaginary) / denom,
      );
    }
    throw ArgumentError('Can only divide by num or ComplexNumber');
  }

  /// Whether this complex number is equal to another
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ComplexNumber &&
        other.real == real &&
        other.imaginary == imaginary;
  }

  @override
  int get hashCode => Object.hash(real, imaginary);

  @override
  String toString() {
    if (imaginary == 0) return real.toString();
    if (real == 0) return '${imaginary}i';
    return '$real ${imaginary >= 0 ? '+' : '-'} ${imaginary.abs()}i';
  }

  // Helper methods for mathematical operations
  static double _sqrt(double x) => math.sqrt(x);
  static double _cos(double x) => math.cos(x);
  static double _sin(double x) => math.sin(x);
  static double _atan2(double a, double b) => math.atan2(a, b);
}

/// Extension to make it easier to create complex numbers from doubles
extension ComplexNumberExtension on num {
  /// Creates a complex number with this as the real part and 0 as the imaginary part
  ComplexNumber toComplex() => ComplexNumber(toDouble(), 0);

  /// Creates a complex number with 0 as the real part and this as the imaginary part
  ComplexNumber get i => ComplexNumber(0, toDouble());
}
