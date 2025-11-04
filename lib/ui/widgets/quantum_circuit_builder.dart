import 'package:flutter/material.dart';
import 'package:katya_ai_rechain_mesh/quantum/quantum_core.dart';
import 'package:katya_ai_rechain_mesh/ui/widgets/quantum_loading.dart';

class QuantumCircuitBuilder extends StatefulWidget {
  final QuantumCore quantumCore;
  final int numQubits;
  final ValueChanged<QuantumCircuit>? onCircuitChanged;

  const QuantumCircuitBuilder({
    super.key,
    required this.quantumCore,
    this.numQubits = 2,
    this.onCircuitChanged,
  });

  @override
  _QuantumCircuitBuilderState createState() => _QuantumCircuitBuilderState();
}

class _QuantumCircuitBuilderState extends State<QuantumCircuitBuilder> {
  late QuantumCircuit _circuit;
  final List<Map<String, dynamic>> _gates = [];
  bool _isSimulating = false;
  Map<String, int>? _simulationResults;

  final List<QuantumGate> _availableGates = [
    Hadamard(),
    PauliX(),
    PauliY(),
    PauliZ(),
    PhaseGate(),
    TGate(),
  ];

  @override
  void initState() {
    super.initState();
    _resetCircuit();
  }

  void _resetCircuit() {
    setState(() {
      _circuit = widget.quantumCore.createCircuit();
      _gates.clear();
      _simulationResults = null;
    });
    _notifyCircuitChanged();
  }

  Future<void> _addGate(QuantumGate gate, int targetQubit,
      {int? controlQubit}) async {
    setState(() {
      _isSimulating = true;
      _simulationResults = null;
    });

    try {
      if (controlQubit != null) {
        _circuit.applyControlledGate(gate, [controlQubit], [targetQubit]);
        _gates.add({
          'type': 'controlled',
          'gate': gate,
          'control': controlQubit,
          'target': targetQubit,
        });
      } else {
        _circuit.applyGate(gate, [targetQubit]);
        _gates.add({
          'type': 'single',
          'gate': gate,
          'target': targetQubit,
        });
      }

      _notifyCircuitChanged();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error applying gate: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSimulating = false);
      }
    }
  }

  Future<void> _runSimulation() async {
    if (_gates.isEmpty) return;

    setState(() => _isSimulating = true);

    try {
      // Run simulation with 1000 shots
      final results = _circuit.run(shots: 1000);

      if (mounted) {
        setState(() => _simulationResults = results);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Simulation error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSimulating = false);
      }
    }
  }

  void _notifyCircuitChanged() {
    widget.onCircuitChanged?.call(_circuit);
  }

  @override
  Widget build(BuildContext context) {
    return QuantumLoading(
      isLoading: _isSimulating,
      loadingText: 'Executing quantum operation...',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circuit visualization
          _buildCircuitVisualization(),

          // Gate palette
          _buildGatePalette(),

          // Simulation controls
          _buildSimulationControls(),

          // Results
          if (_simulationResults != null) _buildResults(),
        ],
      ),
    );
  }

  Widget _buildCircuitVisualization() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          for (int i = 0; i < widget.numQubits; i++) ...[
            _buildQubitLine(i),
            if (i < widget.numQubits - 1) const Divider(),
          ],
        ],
      ),
    );
  }

  Widget _buildQubitLine(int qubitIndex) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Qubit label
          SizedBox(
            width: 40,
            child: Text('q$qubitIndex',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),

          // Gates on this qubit
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _gates
                    .where((g) =>
                        g['target'] == qubitIndex || g['control'] == qubitIndex)
                    .map((gate) => _buildGateWidget(gate, qubitIndex))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGateWidget(Map<String, dynamic> gate, int qubitIndex) {
    final isControl = gate['control'] == qubitIndex;
    final isTarget = gate['target'] == qubitIndex;

    if (isControl) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.blue.shade700, width: 2),
        ),
      );
    }

    if (isTarget) {
      final gateSymbol = _getGateSymbol(gate['gate']);
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Text(gateSymbol,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      );
    }

    return const SizedBox(width: 40);
  }

  String _getGateSymbol(QuantumGate gate) {
    if (gate is Hadamard) return 'H';
    if (gate is PauliX) return 'X';
    if (gate is PauliY) return 'Y';
    if (gate is PauliZ) return 'Z';
    if (gate is PhaseGate) return 'P(π/2)';
    if (gate is TGate) return 'T';
    return 'G';
  }

  Widget _buildGatePalette() {
    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Available Gates',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _availableGates.map((gate) {
              return ElevatedButton(
                onPressed: () => _showQubitSelector(gate),
                child: Text(_getGateSymbol(gate)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showQubitSelector(QuantumGate gate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Apply ${gate.runtimeType} to qubit:'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < widget.numQubits; i++)
              ListTile(
                title: Text('Qubit $i'),
                onTap: () {
                  Navigator.pop(context);
                  _addGate(gate, i);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulationControls() {
    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: _runSimulation,
            child: const Text('Run Simulation (1000 shots)'),
          ),
          const SizedBox(width: 8.0),
          TextButton(
            onPressed: _resetCircuit,
            child: const Text('Reset Circuit'),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_simulationResults == null) return const SizedBox.shrink();

    final results = _simulationResults!;
    final totalShots = results.values.fold(0, (sum, count) => sum + count);

    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Simulation Results',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8.0),
          ...results.entries.map((entry) {
            final percentage =
                (entry.value / totalShots * 100).toStringAsFixed(1);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text('|${entry.key}⟩:',
                        style: const TextStyle(fontFamily: 'monospace')),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: entry.value / totalShots,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Text('$percentage%'),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
