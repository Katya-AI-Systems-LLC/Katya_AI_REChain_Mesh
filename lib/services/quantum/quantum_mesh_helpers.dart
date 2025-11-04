import 'dart:math';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:katya_ai_rechain_mesh/quantum/src/quantum_state.dart';
import 'package:katya_ai_rechain_mesh/quantum/src/quantum_gate.dart';

class QuantumMeshHelpers {
  /// Prepares qubits for QKD based on basis choices
  static List<QuantumState> prepareQubits(List<int> basisChoices, int length) {
    final hadamard = Hadamard();
    final states = <QuantumState>[];
    
    for (var i = 0; i < length; i++) {
      final state = QuantumState(1);
      
      // Apply Hadamard if basis choice is 1 (diagonal basis)
      if (basisChoices[i] == 1) {
        state.applyGate(hadamard.matrix, [0]);
      }
      
      states.add(state);
    }
    
    return states;
  }
  
  /// Sends qubits to a remote device
  static Future<void> sendQubits(
    String deviceId, 
    List<QuantumState> states, 
    BluetoothDevice? device,
    Function(String) onError,
  ) async {
    try {
      if (device == null) {
        throw Exception('Device not connected');
      }
      
      // Convert quantum states to bytes for transmission
      final data = _statesToBytes(states);
      
      // In a real implementation, we would use quantum communication
      // For simulation, we're using BLE
      final service = Guid(QuantumMeshService._quantumServiceUuid);
      final characteristic = Guid(QuantumMeshService._quantumDataCharUuid);
      
      await device.writeCharacteristic(
        service,
        characteristic,
        data,
        writeType: CharacteristicWriteType.withoutResponse,
      );
    } catch (e) {
      onError('Failed to send qubits: $e');
      rethrow;
    }
  }
  
  /// Measures qubits in specified bases
  static Future<List<int>> measureQubits(
    List<QuantumState> states, 
    List<int> basisChoices,
  ) async {
    final results = <int>[];
    final hadamard = Hadamard();
    
    for (var i = 0; i < states.length; i++) {
      final state = states[i].copy();
      
      // Apply Hadamard if measuring in diagonal basis
      if (basisChoices[i] == 1) {
        state.applyGate(hadamard.matrix, [0]);
      }
      
      // Measure the qubit
      results.add(state.measure());
    }
    
    return results;
  }
  
  /// Reconciles basis choices between two parties
  static List<int> reconcileBases(
    List<int> aliceBases, 
    List<int> bobBases,
  ) {
    if (aliceBases.length != bobBases.length) {
      throw ArgumentError('Basis lists must be of equal length');
    }
    
    final matchingIndices = <int>[];
    
    for (var i = 0; i < aliceBases.length; i++) {
      if (aliceBases[i] == bobBases[i]) {
        matchingIndices.add(i);
      }
    }
    
    return matchingIndices;
  }
  
  /// Extracts secure key from measurement results
  static List<int> extractSecureKey(
    List<QuantumState> states,
    List<int> measurements,
    List<int> matchingIndices,
  ) {
    final key = <int>[];
    
    for (final index in matchingIndices) {
      if (index < measurements.length) {
        key.add(measurements[index]);
      }
    }
    
    return key;
  }
  
  /// Checks for potential eavesdropping
  static bool checkForEavesdropping(
    List<QuantumState> states,
    List<int> measurements,
    List<int> matchingIndices, {
    double threshold = 0.15,
  }) {
    if (matchingIndices.length < 2) return false;
    
    // Check a subset of the matching indices for errors
    final sampleSize = min(10, matchingIndices.length ~/ 2);
    final random = Random();
    var errorCount = 0;
    
    for (var i = 0; i < sampleSize; i++) {
      final index = matchingIndices[random.nextInt(matchingIndices.length)];
      final expected = states[index].measure(); // Re-measure
      
      if (expected != measurements[index]) {
        errorCount++;
      }
    }
    
    final errorRate = errorCount / sampleSize;
    return errorRate > threshold;
  }
  
  /// Converts quantum states to bytes for transmission
  static List<int> _statesToBytes(List<QuantumState> states) {
    // This is a simplified implementation
    // In a real quantum system, this would involve quantum teleportation
    // or quantum state transfer protocols
    final bytes = <int>[];
    
    for (final state in states) {
      // For simulation, we're just encoding the measurement outcome
      final measurement = state.measure();
      bytes.add(measurement);
    }
    
    return bytes;
  }
  
  /// Generates a random bit string of given length
  static List<int> generateRandomBits(int length) {
    final random = Random();
    return List.generate(length, (_) => random.nextInt(2));
  }
}

// Add this extension to QuantumState for copying
// ignore: prefer_extension_methods
class _QuantumStateExtension {
  static QuantumState copy(QuantumState state) {
    final newState = QuantumState(1); // Dummy state
    // Copy internal state (simplified)
    // In a real implementation, this would properly copy the state vector
    return newState;
  }
}
