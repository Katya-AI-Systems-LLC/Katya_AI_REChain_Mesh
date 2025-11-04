#!/usr/bin/env python3
"""
Benchmark comparison script for Katya Mesh implementations.
Compares performance across Go, C++, C, and Rust implementations.
"""

import subprocess
import re
import json
import matplotlib.pyplot as plt
import numpy as np
from pathlib import Path
import sys

class BenchmarkRunner:
    def __init__(self):
        self.results = {}
        self.test_dir = Path(__file__).parent

    def run_go_benchmarks(self):
        """Run Go benchmarks and parse results."""
        print("Running Go benchmarks...")
        try:
            result = subprocess.run(
                ['go', 'test', '-bench=.', '-benchmem', './tests/benchmark'],
                cwd=self.test_dir.parent.parent,
                capture_output=True,
                text=True,
                timeout=300
            )

            self.results['go'] = self.parse_go_benchmarks(result.stdout)
        except subprocess.TimeoutExpired:
            print("Go benchmarks timed out")
            self.results['go'] = {}
        except Exception as e:
            print(f"Error running Go benchmarks: {e}")
            self.results['go'] = {}

    def run_cpp_benchmarks(self):
        """Run C++ benchmarks using Google Benchmark."""
        print("Running C++ benchmarks...")
        try:
            # Build benchmark executable
            build_result = subprocess.run(
                ['make', 'cpp-bench'],
                cwd=self.test_dir.parent.parent,
                capture_output=True,
                timeout=60
            )

            if build_result.returncode == 0:
                # Run benchmarks
                result = subprocess.run(
                    ['./build/cpp-bench'],
                    cwd=self.test_dir.parent.parent,
                    capture_output=True,
                    text=True,
                    timeout=300
                )

                self.results['cpp'] = self.parse_cpp_benchmarks(result.stdout)
            else:
                print("Failed to build C++ benchmarks")
                self.results['cpp'] = {}
        except subprocess.TimeoutExpired:
            print("C++ benchmarks timed out")
            self.results['cpp'] = {}
        except Exception as e:
            print(f"Error running C++ benchmarks: {e}")
            self.results['cpp'] = {}

    def run_c_benchmarks(self):
        """Run C benchmarks."""
        print("Running C benchmarks...")
        try:
            # Build benchmark executable
            build_result = subprocess.run(
                ['make', 'c-bench'],
                cwd=self.test_dir.parent.parent,
                capture_output=True,
                timeout=60
            )

            if build_result.returncode == 0:
                # Run benchmarks
                result = subprocess.run(
                    ['./build/c-bench'],
                    cwd=self.test_dir.parent.parent,
                    capture_output=True,
                    text=True,
                    timeout=300
                )

                self.results['c'] = self.parse_c_benchmarks(result.stdout)
            else:
                print("Failed to build C benchmarks")
                self.results['c'] = {}
        except subprocess.TimeoutExpired:
            print("C benchmarks timed out")
            self.results['c'] = {}
        except Exception as e:
            print(f"Error running C benchmarks: {e}")
            self.results['c'] = {}

    def run_rust_benchmarks(self):
        """Run Rust benchmarks."""
        print("Running Rust benchmarks...")
        try:
            result = subprocess.run(
                ['cargo', 'bench'],
                cwd=self.test_dir.parent.parent / 'rust',
                capture_output=True,
                text=True,
                timeout=300
            )

            self.results['rust'] = self.parse_rust_benchmarks(result.stdout)
        except subprocess.TimeoutExpired:
            print("Rust benchmarks timed out")
            self.results['rust'] = {}
        except Exception as e:
            print(f"Error running Rust benchmarks: {e}")
            self.results['rust'] = {}

    def parse_go_benchmarks(self, output):
        """Parse Go benchmark output."""
        results = {}
        lines = output.split('\n')

        for line in lines:
            if line.startswith('Benchmark'):
                parts = line.split()
                if len(parts) >= 4:
                    name = parts[0].replace('Benchmark', '').lower()
                    time_ns = float(parts[2])
                    results[name] = time_ns

        return results

    def parse_cpp_benchmarks(self, output):
        """Parse C++ benchmark output."""
        results = {}
        lines = output.split('\n')

        for line in lines:
            if 'BM_' in line and 'iterations' in line:
                # Parse Google Benchmark format
                parts = line.split()
                if len(parts) >= 4:
                    name = parts[0].replace('BM_', '').lower()
                    time_match = re.search(r'(\d+\.\d+)ns', line)
                    if time_match:
                        time_ns = float(time_match.group(1))
                        results[name] = time_ns

        return results

    def parse_c_benchmarks(self, output):
        """Parse C benchmark output."""
        results = {}
        lines = output.split('\n')

        for line in lines:
            if 'iterations in' in line and 'ms' in line:
                parts = line.split()
                if len(parts) >= 6:
                    name = parts[0].lower()
                    time_ms = float(parts[4])
                    time_ns = time_ms * 1_000_000  # Convert to nanoseconds
                    results[name] = time_ns

        return results

    def parse_rust_benchmarks(self, output):
        """Parse Rust benchmark output."""
        results = {}
        lines = output.split('\n')

        for line in lines:
            if 'test bench_' in line and 'time:' in line:
                parts = line.split()
                if len(parts) >= 5:
                    name = parts[1].replace('bench_', '')
                    time_match = re.search(r'(\d+\.\d+)\s*ns', line)
                    if time_match:
                        time_ns = float(time_match.group(1))
                        results[name] = time_ns

        return results

    def save_results(self):
        """Save benchmark results to JSON file."""
        with open(self.test_dir / 'benchmark_results.json', 'w') as f:
            json.dump(self.results, f, indent=2)

    def generate_comparison_chart(self):
        """Generate comparison chart."""
        benchmarks = [
            'node_creation',
            'message_send',
            'crypto_encrypt',
            'crypto_decrypt',
            'flooding_protocol',
            'gossip_protocol',
            'consensus_protocol'
        ]

        languages = ['go', 'cpp', 'c', 'rust']
        colors = ['blue', 'green', 'red', 'orange']

        fig, axes = plt.subplots(2, 4, figsize=(20, 10))
        axes = axes.flatten()

        for i, bench in enumerate(benchmarks):
            ax = axes[i]
            values = []

            for lang in languages:
                if lang in self.results and bench in self.results[lang]:
                    values.append(self.results[lang][bench])
                else:
                    values.append(0)

            bars = ax.bar(languages, values, color=colors)
            ax.set_title(f'{bench.replace("_", " ").title()}')
            ax.set_ylabel('Time (ns)')
            ax.tick_params(axis='x', rotation=45)

            # Add value labels on bars
            for bar, value in zip(bars, values):
                if value > 0:
                    height = bar.get_height()
                    ax.text(bar.get_x() + bar.get_width()/2., height,
                           '.1f', ha='center', va='bottom')

        plt.tight_layout()
        plt.savefig(self.test_dir / 'benchmark_comparison.png', dpi=300, bbox_inches='tight')
        plt.show()

    def print_summary(self):
        """Print benchmark summary."""
        print("\n" + "="*60)
        print("KATYA MESH BENCHMARK COMPARISON SUMMARY")
        print("="*60)

        benchmarks = [
            'node_creation',
            'message_send',
            'crypto_encrypt',
            'crypto_decrypt',
            'flooding_protocol',
            'gossip_protocol',
            'consensus_protocol'
        ]

        print("<15")
        print("-" * 60)

        for bench in benchmarks:
            print("<15")
            for lang in ['go', 'cpp', 'c', 'rust']:
                if lang in self.results and bench in self.results[lang]:
                    time_ns = self.results[lang][bench]
                    if time_ns < 1000:
                        print("<10")
                    elif time_ns < 1_000_000:
                        print("<10")
                    else:
                        print("<10")
                else:
                    print("<10")
            print()

        print("\nBenchmark results saved to benchmark_results.json")
        print("Comparison chart saved to benchmark_comparison.png")

def main():
    runner = BenchmarkRunner()

    print("Starting Katya Mesh benchmark comparison...")
    print("This may take several minutes...\n")

    # Run all benchmarks
    runner.run_go_benchmarks()
    runner.run_cpp_benchmarks()
    runner.run_c_benchmarks()
    runner.run_rust_benchmarks()

    # Save and display results
    runner.save_results()
    runner.print_summary()

    try:
        runner.generate_comparison_chart()
    except ImportError:
        print("matplotlib not available, skipping chart generation")
    except Exception as e:
        print(f"Error generating chart: {e}")

if __name__ == '__main__':
    main()
