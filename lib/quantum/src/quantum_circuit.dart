import 'package:katya_ai_rechain_mesh/quantum/src/quantum_gate.dart';
import 'package:katya_ai_rechain_mesh/quantum/src/quantum_state.dart';

/// Represents a quantum circuit that can be executed on a quantum computer
class QuantumCircuit {
  /// Creates a new quantum circuit with the given number of qubits
  QuantumCircuit(this.numQubits, {this.numClassicalBits = 0}) {
    _state = QuantumState(numQubits);
  }

  /// Number of qubits in the circuit
  final int numQubits;
  
  /// Number of classical bits for measurement results
  final int numClassicalBits;
  
  /// The current quantum state of the circuit
  late QuantumState _state;
  
  /// List of gates in the circuit
  final List<Map<String, dynamic>> _gates = [];
  
  /// Applies a quantum gate to the circuit
  void applyGate(QuantumGate gate, List<int> targetQubits, {String? name}) {
    _gates.add({
      'gate': gate,
      'targets': targetQubits,
      'name': name,
    });
    _state.applyGate(gate.matrix, targetQubits);
  }
  
  /// Applies a controlled gate to the circuit
  void applyControlledGate(
    QuantumGate gate, 
    List<int> controlQubits, 
    List<int> targetQubits, {
    String? name,
  }) {
    _gates.add({
      'gate': gate,
      'controls': controlQubits,
      'targets': targetQubits,
      'name': name,
    });
    // TODO: Implement controlled gate application
  }
  
  /// Measures a qubit and stores the result in a classical bit
  void measure(int qubit, int classicalBit) {
    if (qubit < 0 || qubit >= numQubits) {
      throw ArgumentError('Qubit index out of range');
    }
    if (classicalBit < 0 || classicalBit >= numClassicalBits) {
      throw ArgumentError('Classical bit index out of range');
    }
    
    _gates.add({
      'type': 'measure',
      'qubit': qubit,
      'classicalBit': classicalBit,
    });
    
    // TODO: Implement measurement
  }
  
  /// Runs the circuit and returns the measurement results
  Map<String, int> run({int shots = 1}) {
    final results = <String, int>{};
    
    for (var i = 0; i < shots; i++) {
      final state = _state.copy();
      final measurements = List<int>.filled(numQubits, 0);
      
      // Execute all gates in the circuit
      for (final gate in _gates) {
        if (gate['type'] == 'measure') {
          final qubit = gate['qubit'] as int;
          measurements[qubit] = state.measure();
        }
      }
      
      // Convert measurement results to a binary string
      final result = measurements.reversed.join();
      results[result] = (results[result] ?? 0) + 1;
    }
    
    return results;
  }
  
  /// Returns a string representation of the circuit
  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('QuantumCircuit with $numQubits qubits and $numClassicalBits classical bits');
    
    for (var i = 0; i < _gates.length; i++) {
      final gate = _gates[i];
      buffer.write('$i: ');
      
      if (gate['type'] == 'measure') {
        buffer.writeln('Measure q[${gate['qubit']}] -> c[${gate['classicalBit']}]');
      } else {
        final name = gate['name'] ?? gate['gate'].runtimeType.toString();
        final targets = (gate['targets'] as List<int>).join(',');
        
        if (gate['controls'] != null) {
          final controls = (gate['controls'] as List<int>).map((c) => 'q[$c]').join(',');
          buffer.writeln('$name (controls: $controls, targets: q[$targets])');
        } else {
          buffer.writeln('$name q[$targets]');
        }
      }
    }
    
    return buffer.toString();
  }
  
  /// Gets the current state vector of the circuit
  List<ComplexNumber> get stateVector => _state.state;
  
  /// Resets the circuit to the |0...0⟩ state
  void reset() {
    _state = QuantumState(numQubits);
  }
}
