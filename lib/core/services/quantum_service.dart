/// Abstract interface for quantum computing service
abstract class QuantumService {
  /// Initialize the quantum computing system
  Future<void> initialize();

  /// Create a quantum circuit with specified number of qubits
  Future<QuantumCircuit> createCircuit(int qubitCount);

  /// Create an entangled pair of qubits
  Future<EntangledPair> createEntangledPair();

  /// Apply quantum error correction to a state
  Future<QuantumState> applyErrorCorrection(
    QuantumState state,
    ErrorCorrectionCode code,
  );

  /// Perform quantum teleportation
  Future<void> teleportState({
    required QuantumState state,
    required String targetPeerId,
  });

  /// Generate quantum key distribution
  Future<QuantumKey> generateQuantumKey(String peerId);

  /// Measure a quantum state
  Future<List<int>> measureState(QuantumState state);

  /// Apply quantum gates to a circuit
  Future<void> applyGates(
    QuantumCircuit circuit,
    List<QuantumGate> gates,
  );

  /// Simulate quantum circuit execution
  Future<QuantumResult> simulateCircuit(QuantumCircuit circuit);

  /// Check if quantum hardware is available
  bool get isQuantumHardwareAvailable;

  /// Get quantum processor capabilities
  Map<String, dynamic> get quantumCapabilities;

  /// Clean up quantum resources
  Future<void> dispose();
}

/// Represents a quantum circuit
class QuantumCircuit {
  final int qubitCount;
  final List<QuantumGate> gates;

  const QuantumCircuit(this.qubitCount, [this.gates = const []]);

  QuantumCircuit copyWith({
    int? qubitCount,
    List<QuantumGate>? gates,
  }) {
    return QuantumCircuit(
      qubitCount ?? this.qubitCount,
      gates ?? this.gates,
    );
  }
}

/// Represents a quantum gate
class QuantumGate {
  final String name;
  final List<List<double>> matrix;
  final List<int> targetQubits;

  const QuantumGate(this.name, this.matrix, this.targetQubits);
}

/// Represents a quantum state
class QuantumState {
  final List<double> amplitudes;
  final int qubitCount;

  const QuantumState(this.amplitudes, this.qubitCount);
}

/// Represents an entangled pair
class EntangledPair {
  final String id;
  final QuantumState qubit1;
  final QuantumState qubit2;

  const EntangledPair(this.id, this.qubit1, this.qubit2);
}

/// Quantum error correction codes
enum ErrorCorrectionCode {
  bitFlip,
  phaseFlip,
  shorCode,
  surfaceCode,
}

/// Result of quantum computation
class QuantumResult {
  final List<int> measurements;
  final double probability;
  final Map<String, dynamic> metadata;

  const QuantumResult(this.measurements, this.probability, this.metadata);
}

/// Quantum key for encryption
class QuantumKey {
  final String keyId;
  final Uint8List keyData;
  final String algorithm;
  final DateTime createdAt;

  const QuantumKey(this.keyId, this.keyData, this.algorithm, this.createdAt);
}
