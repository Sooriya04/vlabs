#!/usr/bin/env bash
# ==============================================================================
# Script Name: exp2a_benchmark.sh
# Lab Experiment 2a: Virtual Machine Resource Configuration and Execution Benchmarking
# Description: Automates VM hardware resource inspection (Memory, Disk, CPU, Network),
#              checks/installs OpenJDK, compiles SumTest.java, and runs execution benchmarks.
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JAVA_SRC="$SCRIPT_DIR/SumTest.java"

echo "=============================================================="
echo "  EXPERIMENT 2a: VM Hardware Inspection & Java Benchmark      "
echo "=============================================================="
echo ""

echo "=== [1] Verifying System Memory (RAM) ==="
free -h
echo ""

echo "=== [2] Verifying Storage & Disk Allocation ==="
df -h /
echo ""

echo "=== [3] Verifying CPU Architecture & Core Allocation ==="
lscpu | grep -E "Model name|CPU\(s\)|Architecture|Hypervisor" || lscpu | head -n 12
echo ""

echo "=== [4] Verifying Network Interfaces ==="
ip -br addr show 2>/dev/null || ip a
echo ""

echo "=== [5] Checking Java Development Kit (JDK) ==="
if ! command -v javac &>/dev/null || ! command -v java &>/dev/null; then
    echo "[*] Java / Javac not found. Installing OpenJDK..."
    sudo apt update && sudo apt install -y default-jdk
else
    echo "[*] Java compiler detected: $(javac -version 2>&1)"
fi
echo ""

echo "=== [6] Compiling Java Benchmark (SumTest.java) ==="
if [ ! -f "$JAVA_SRC" ]; then
    echo "Error: $JAVA_SRC not found!"
    exit 1
fi

(cd "$SCRIPT_DIR" && javac SumTest.java)
echo "Compilation successful: SumTest.class generated."
echo ""

echo "=== [7] Executing Benchmark with System Time Measurement ==="
echo "Running Java summation loop benchmark..."
(cd "$SCRIPT_DIR" && time java SumTest)
echo ""

echo "=============================================================="
echo " Experiment 2a verification and benchmarking completed.        "
echo " Compare the above execution time with Windows Host benchmark! "
echo "=============================================================="
