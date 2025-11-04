import 'package:katya_ai_rechain_mesh/quantum/src/complex_number.dart';
import 'package:katya_ai_rechain_mesh/quantum/src/quantum_gate.dart';

/// Phase shift gate (S gate)
class PhaseGate extends QuantumGate {
  PhaseGate() : super(1, [
    [ComplexNumber(1, 0), ComplexNumber.zero],
    [ComplexNumber.zero, ComplexNumber(0, 1)],
  ]);
  
  @override
  String get name => 'Phase';
}

/// T gate (π/8 gate)
class TGate extends QuantumGate {
  TGate() : super(1, [
    [ComplexNumber(1, 0), ComplexNumber.zero],
    [ComplexNumber.zero, ComplexNumber(1 / 1.414, 1 / 1.414)],
  ]);
  
  @override
  String get name => 'T';
}

/// Controlled-NOT gate
class CNOT extends QuantumGate {
  CNOT() : super(2, [
    [ComplexNumber.one, ComplexNumber.zero, ComplexNumber.zero, ComplexNumber.zero],
    [ComplexNumber.zero, ComplexNumber.one, ComplexNumber.zero, ComplexNumber.zero],
    [ComplexNumber.zero, ComplexNumber.zero, ComplexNumber.zero, ComplexNumber.one],
    [ComplexNumber.zero, ComplexNumber.zero, ComplexNumber.one, ComplexNumber.zero],
  ]);
  
  @override
  String get name => 'CNOT';
}

/// SWAP gate
class SwapGate extends QuantumGate {
  SwapGate() : super(2, [
    [ComplexNumber.one, ComplexNumber.zero, ComplexNumber.zero, ComplexNumber.zero],
    [ComplexNumber.zero, ComplexNumber.zero, ComplexNumber.one, ComplexNumber.zero],
    [ComplexNumber.zero, ComplexNumber.one, ComplexNumber.zero, ComplexNumber.zero],
    [ComplexNumber.zero, ComplexNumber.zero, ComplexNumber.zero, ComplexNumber.one],
  ]);
  
  @override
  String get name => 'SWAP';
}

/// Toffoli gate (CCNOT)
class ToffoliGate extends QuantumGate {
  ToffoliGate() : super(3, [
    [ComplexNumber.one, ComplexNumber.zero, ComplexNumber.zero, ComplexNumber.zero, 
     ComplexNumber.zero, ComplexNumber.zero, ComplexNumber.zero, ComplexNumber.zero],
    [ComplexNumber.zero, ComplexNumber.one, ComplexNumber.zero, ComplexNumber.zero, 
     ComplexNumber.zero, ComplexNumber.zero, ComplexNumber.zero, ComplexNumber.zero],
    [ComplexNumber.zero, ComplexNumber.zero, ComplexNumber.one, ComplexNumber.zero, 
     ComplexNumber.zero, ComplexNumber.zero, ComplexNumber.zero, ComplexNumber.zero],
    [ComplexNumber.zero, ComplexNumber.zero, ComplexNumber.zero, ComplexNumber.one, 
     ComplexNumber.zero, ComplexNumber.zero, ComplexNumber.zero, ComplexNumber.zero],
    [ComplexNumber.zero, ComplexNumber.zero, ComplexNumber.zero, ComplexNumber.zero, 
     ComplexNumber.one, ComplexNumber.zero, ComplexNumber.zero, ComplexNumber.zero],
    [ComplexNumber.zero, ComplexNumber.zero, ComplexNumber.zero, ComplexNumber.zero, 
     ComplexNumber.zero, ComplexNumber.one, ComplexNumber.zero, ComplexNumber.zero],
    [ComplexNumber.zero, ComplexNumber.zero, ComplexNumber.zero, ComplexNumber.zero, 
     ComplexNumber.zero, ComplexNumber.zero, ComplexNumber.zero, ComplexNumber.one],
    [ComplexNumber.zero, ComplexNumber.zero, ComplexNumber.zero, ComplexNumber.zero, 
     ComplexNumber.zero, ComplexNumber.zero, ComplexNumber.one, ComplexNumber.zero],
  ]);
  
  @override
  String get name => 'Toffoli';
}
