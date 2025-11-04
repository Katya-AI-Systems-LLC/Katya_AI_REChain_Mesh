import 'dart:math' as math;

/// A class representing a complex number with real and imaginary parts.
class ComplexNumber {
  /// The real part of the complex number.
  final double real;
  
  /// The imaginary part of the complex number.
  final double imaginary;

  /// Creates a complex number with the given real and imaginary parts.
  const ComplexNumber(this.real, this.imaginary);

  /// Creates a complex number with only a real part.
  const ComplexNumber.real(this.real) : imaginary = 0.0;

  /// Creates a complex number with only an imaginary part.
  const ComplexNumber.imaginary(this.imaginary) : real = 0.0;

  /// Creates a complex number from polar coordinates.
  ///
  /// [r] is the magnitude (radius).
  /// [theta] is the angle in radians.
  factory ComplexNumber.fromPolar(double r, double theta) {
    return ComplexNumber(
      r * math.cos(theta),
      r * math.sin(theta),
    );
  }

  /// Returns the complex conjugate of this number.
  ComplexNumber get conjugate => ComplexNumber(real, -imaginary);

  /// Returns the magnitude (absolute value) of this complex number.
  double get magnitude => math.sqrt(real * real + imaginary * imaginary);

  /// Returns the phase (angle) of this complex number in radians.
  double get phase => math.atan2(imaginary, real);

  /// Returns the square of the magnitude.
  double get magnitudeSquared => real * real + imaginary * imaginary;

  /// Returns true if this complex number is real (has no imaginary part).
  bool get isReal => imaginary == 0.0;

  /// Returns true if this complex number is purely imaginary.
  bool get isImaginary => real == 0.0 && imaginary != 0.0;

  /// Returns the sum of this complex number and [other].
  ComplexNumber operator +(ComplexNumber other) {
    return ComplexNumber(
      real + other.real,
      imaginary + other.imaginary,
    );
  }

  /// Returns the difference of this complex number and [other].
  ComplexNumber operator -(ComplexNumber other) {
    return ComplexNumber(
      real - other.real,
      imaginary - other.imaginary,
    );
  }

  /// Returns the product of this complex number and [other].
  ComplexNumber operator *(ComplexNumber other) {
    return ComplexNumber(
      real * other.real - imaginary * other.imaginary,
      real * other.imaginary + imaginary * other.real,
    );
  }

  /// Returns the quotient of this complex number and [other].
  ComplexNumber operator /(ComplexNumber other) {
    final denominator = other.magnitudeSquared;
    if (denominator == 0.0) {
      throw const DivisionByZeroException();
    }
    return ComplexNumber(
      (real * other.real + imaginary * other.imaginary) / denominator,
      (imaginary * other.real - real * other.imaginary) / denominator,
    );
  }

  /// Returns the negation of this complex number.
  ComplexNumber operator -() => ComplexNumber(-real, -imaginary);

  /// Returns true if this complex number is equal to [other].
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ComplexNumber &&
        other.real == real &&
        other.imaginary == imaginary;
  }

  @override
  int get hashCode => Object.hash(real, imaginary);

  /// Returns a string representation of this complex number.
  @override
  String toString() {
    if (imaginary == 0) return real.toString();
    if (real == 0) return '${imaginary}i';
    return '$real ${imaginary >= 0 ? '+' : '-'} ${imaginary.abs()}i';
  }

  /// Returns the exponential of this complex number.
  ComplexNumber exp() {
    final expReal = math.exp(real);
    return ComplexNumber(
      expReal * math.cos(imaginary),
      expReal * math.sin(imaginary),
    );
  }

  /// Returns the natural logarithm of this complex number.
  ComplexNumber log() {
    return ComplexNumber(
      math.log(magnitude),
      phase,
    );
  }

  /// Returns this complex number raised to the power of [exponent].
  ComplexNumber pow(ComplexNumber exponent) {
    if (exponent.isReal && exponent.imaginary == 0) {
      // Handle real exponents more efficiently
      final r = math.pow(magnitude, exponent.real).toDouble();
      final theta = phase * exponent.real;
      return ComplexNumber(
        r * math.cos(theta),
        r * math.sin(theta),
      );
    }
    // General case: a^b = e^(b * ln(a))
    return (exponent * log()).exp();
  }
}

/// Exception thrown when attempting to divide by zero.
class DivisionByZeroException implements Exception {
  /// Creates a [DivisionByZeroException].
  const DivisionByZeroException();
  
  @override
  String toString() => 'Division by zero in complex number operation';
}
