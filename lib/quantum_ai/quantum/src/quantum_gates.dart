// Quantum Gates Implementation
// This module defines various quantum gates used in quantum circuits

import 'dart:math';

/// Base class for all quantum gates
abstract class QuantumGate {
  final String type;
  final List<int> qubits;
  final Map<String, dynamic> parameters;

  const QuantumGate({
    required this.type,
    required this.qubits,
    this.parameters = const {},
  });

  /// Apply this gate to a quantum state (to be implemented by subclasses)
  void apply(QuantumSimulator simulator);

  @override
  String toString() =>
      '$type${qubits.join(',')}${parameters.isNotEmpty ? ' $parameters' : ''}';
}

/// Identity gate (does nothing)
class IdentityGate extends QuantumGate {
  IdentityGate(int qubit) : super(type: 'I', qubits: [qubit]);

  @override
  void apply(QuantumSimulator simulator) {
    // Identity operation does nothing
  }
}

/// Hadamard gate (creates superposition)
class HadamardGate extends QuantumGate {
  HadamardGate(int qubit) : super(type: 'H', qubits: [qubit]);

  @override
  void apply(QuantumSimulator simulator) {
    simulator.applyGate(this);
  }
}

/// Pauli-X gate (quantum NOT)
class PauliXGate extends QuantumGate {
  PauliXGate(int qubit) : super(type: 'X', qubits: [qubit]);

  @override
  void apply(QuantumSimulator simulator) {
    simulator.applyGate(this);
  }
}

/// Pauli-Y gate
class PauliYGate extends QuantumGate {
  PauliYGate(int qubit) : super(type: 'Y', qubits: [qubit]);

  @override
  void apply(QuantumSimulator simulator) {
    simulator.applyGate(this);
  }
}

/// Pauli-Z gate
class PauliZGate extends QuantumGate {
  PauliZGate(int qubit) : super(type: 'Z', qubits: [qubit]);

  @override
  void apply(QuantumSimulator simulator) {
    simulator.applyGate(this);
  }
}

/// Phase shift gate
class PhaseGate extends QuantumGate {
  PhaseGate(int qubit, double angle)
      : super(type: 'P', qubits: [qubit], parameters: {'angle': angle});

  @override
  void apply(QuantumSimulator simulator) {
    simulator.applyGate(this);
  }
}

/// Rotation around X-axis
class RXGate extends QuantumGate {
  RXGate(int qubit, double angle)
      : super(type: 'RX', qubits: [qubit], parameters: {'angle': angle});

  @override
  void apply(QuantumSimulator simulator) {
    simulator.applyGate(this);
  }
}

/// Rotation around Y-axis
class RYGate extends QuantumGate {
  RYGate(int qubit, double angle)
      : super(type: 'RY', qubits: [qubit], parameters: {'angle': angle});

  @override
  void apply(QuantumSimulator simulator) {
    simulator.applyGate(this);
  }
}

/// Rotation around Z-axis
class RZGate extends QuantumGate {
  RZGate(int qubit, double angle)
      : super(type: 'RZ', qubits: [qubit], parameters: {'angle': angle});

  @override
  void apply(QuantumSimulator simulator) {
    simulator.applyGate(this);
  }
}

/// Controlled-NOT gate
class CNOTGate extends QuantumGate {
  CNOTGate(int controlQubit, int targetQubit)
      : super(type: 'CNOT', qubits: [controlQubit, targetQubit]);

  int get controlQubit => qubits[0];
  int get targetQubit => qubits[1];

  @override
  void apply(QuantumSimulator simulator) {
    simulator.applyGate(this);
  }
}

/// SWAP gate
class SWAPGate extends QuantumGate {
  SWAPGate(int qubit1, int qubit2)
      : super(type: 'SWAP', qubits: [qubit1, qubit2]);

  @override
  void apply(QuantumSimulator simulator) {
    simulator.applyGate(this);
  }
}

/// Toffoli (CCNOT) gate
class ToffoliGate extends QuantumGate {
  ToffoliGate(int control1, int control2, int target)
      : super(type: 'CCNOT', qubits: [control1, control2, target]);

  @override
  void apply(QuantumSimulator simulator) {
    // Implementation for Toffoli gate
    // ...
  }
}

/// Fredkin (CSWAP) gate
class FredkinGate extends QuantumGate {
  FredkinGate(int control, int target1, int target2)
      : super(type: 'CSWAP', qubits: [control, target1, target2]);

  @override
  void apply(QuantumSimulator simulator) {
    // Implementation for Fredkin gate
    // ...
  }
}

/// Quantum Fourier Transform gate
class QFTGate extends QuantumGate {
  final int size;

  QFTGate(List<int> qubits, {this.size = 0})
      : assert(qubits.length > 1, 'QFT requires at least 2 qubits'),
        super(type: 'QFT', qubits: qubits);

  @override
  void apply(QuantumSimulator simulator) {
    // Implementation of Quantum Fourier Transform
    final n = qubits.length;

    for (int j = n - 1; j >= 0; j--) {
      // Apply Hadamard to qubit j
      HadamardGate(qubits[j]).apply(simulator);

      // Apply controlled rotations
      for (int k = j - 1; k >= 0; k--) {
        final angle = pi / pow(2, j - k);
        // Apply controlled R_k gate
        // ...
      }
    }

    // Swap qubits to complete QFT
    for (int i = 0; i < n ~/ 2; i++) {
      SWAPGate(qubits[i], qubits[n - 1 - i]).apply(simulator);
    }
  }
}

/// Inverse Quantum Fourier Transform gate
class IQFTGate extends QFTGate {
  IQFTGate(super.qubits);

  @override
  void apply(QuantumSimulator simulator) {
    // Apply QFT in reverse order with negative angles
    final n = qubits.length;

    // Swap qubits first
    for (int i = 0; i < n ~/ 2; i++) {
      SWAPGate(qubits[i], qubits[n - 1 - i]).apply(simulator);
    }

    for (int j = 0; j < n; j++) {
      // Apply controlled rotations in reverse order with negative angles
      for (int k = j - 1; k >= 0; k--) {
        final angle = -pi / pow(2, j - k);
        // Apply controlled R_k^ gate with negative angle
        // ...
      }

      // Apply Hadamard to qubit j
      HadamardGate(qubits[j]).apply(simulator);
    }
  }
}
