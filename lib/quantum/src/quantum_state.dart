import 'dart:math' as math;
import 'package:katya_ai_rechain_mesh/quantum/src/complex_number.dart';

/// Represents the quantum state of a qubit or a system of qubits
class QuantumState {
  /// Creates a quantum state with the given number of qubits
  QuantumState(int numQubits) : _numQubits = numQubits {
    final numStates = 1 << numQubits;
    _state = List<ComplexNumber>.filled(numStates, ComplexNumber.zero);
    _state[0] = ComplexNumber(1, 0);  // Initialize to |0...0⟩
  }

  /// Number of qubits in this quantum state
  final int _numQubits;

  /// The state vector as a list of complex amplitudes
  late List<ComplexNumber> _state;

  /// Gets the number of qubits in this quantum state
  int get numQubits => _numQubits;

  /// Gets the state vector
  List<ComplexNumber> get state => List.unmodifiable(_state);

  /// Applies a quantum gate to this state
  void applyGate(ComplexMatrix gate, List<int> targetQubits) {
    // TODO: Implement gate application to the quantum state
  }

  /// Measures the quantum state, collapsing it to a classical state
  int measure() {
    final rand = math.Random().nextDouble();
    var cumulativeProb = 0.0;

    for (var i = 0; i < _state.length; i++) {
      final prob = _state[i].modulusSquared;
      cumulativeProb += prob;

      if (rand <= cumulativeProb) {
        // Collapse to the measured state
        _state = List.filled(_state.length, ComplexNumber.zero);
        _state[i] = ComplexNumber.one;
        return i;
      }
    }

    // This should theoretically never be reached due to normalization
    throw StateError('Invalid quantum state: probabilities do not sum to 1');
  }

  /// Creates a deep copy of this quantum state
  QuantumState copy() {
    final newState = QuantumState(_numQubits);
    newState._state = List<ComplexNumber>.from(_state);
    return newState;
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    for (var i = 0; i < _state.length; i++) {
      if (_state[i] != ComplexNumber.zero) {
        if (buffer.isNotEmpty) buffer.write(' + ');
        buffer.write('${_state[i]}|${i.toRadixString(2).padLeft(_numQubits, '0')}⟩');
      }
    }
    return buffer.toString();
  }
}

/// Extension for Complex number operations
extension ComplexExtensions on Complex {
  /// Returns the squared modulus of the complex number
  double get modulusSquared => x * x + y * y;
}

/// Represents a complex matrix for quantum gates
class ComplexMatrix {
  final int rows;
  final int cols;
  final List<List<ComplexNumber>> data;

  ComplexMatrix(this.rows, this.cols) : data = List.generate(rows, (_) => List.filled(cols, ComplexNumber.zero));

  ComplexMatrix.identity(int size)
      : rows = size,
        cols = size,
        data = List.generate(size, (i) => List.generate(size, (j) => i == j ? ComplexNumber.one : ComplexNumber.zero));

  ComplexNumber get(int row, int col) => data[row][col];
  void set(int row, int col, ComplexNumber value) => data[row][col] = value;

  /// Kronecker product of two matrices
  static ComplexMatrix kronecker(ComplexMatrix a, ComplexMatrix b) {
    final result = ComplexMatrix(a.rows * b.rows, a.cols * b.cols);

    for (var i = 0; i < a.rows; i++) {
      for (var j = 0; j < a.cols; j++) {
        for (var k = 0; k < b.rows; k++) {
          for (var l = 0; l < b.cols; l++) {
            result.set(i * b.rows + k, j * b.cols + l, a.get(i, j) * b.get(k, l));
          }
        }
      }
    }

    return result;
  }
}
