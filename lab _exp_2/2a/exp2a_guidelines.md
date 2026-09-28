# Lab Experiment 2a Guidelines: Virtual Machine Creation, Resource Configuration, and Execution Benchmarking

---

## 1. Aim
To create a Virtual Machine (VM) and configure Storage, Memory, and Network settings in Oracle VM VirtualBox, followed by comparing execution performance between the Linux VM and Windows Host using a Java benchmarking program.

---

## 2. Step-by-Step VirtualBox GUI Setup Guidelines

1. **Initiate VM Creation**:
   - Open **Oracle VM VirtualBox Manager**.
   - Click the **New** button on the toolbar.

2. **Specify General Details**:
   - **Name**: `Sooriya` (or preferred OS name like `Ubuntu-VM`).
   - **Type**: `Linux`.
   - **Version**: `Ubuntu (64-bit)`.
   - Click **Next**.

3. **Allocate System Memory (RAM)**:
   - Set memory allocation to **4 GB (4096 MB)**.
   - *Rule of Thumb*: Do not allocate more than 50% of your physical host machine's RAM to prevent host OS instability.
   - Click **Next**.

4. **Configure Virtual Hard Disk (Storage)**:
   - Select **Create a Virtual Hard Disk Now** (or **Use an Existing Virtual Hard Disk** if pre-built).
   - Hard Disk File Type: Select **VDI (VirtualBox Disk Image)**.
   - Storage on Physical Hard Disk: Select **Dynamically allocated**.
   - Set disk capacity to **20 GB**.
   - Click **Create**.

5. **Configure Network Adapter**:
   - Select your newly created VM and click **Settings**.
   - Navigate to the **Network** tab.
   - Ensure **Adapter 1** is checked as **Enable Network Adapter**.
   - Set **Attached to**:
     - **Bridged Adapter**: Provides direct access to the physical network (LAN + Internet).
     - **Host-Only Adapter**: Creates a isolated private network between the host and VMs.
   - Click **OK**.

---

## 3. Linux Shell Commands for Resource Inspection

Once the Linux VM is powered on, open the terminal (`Ctrl + Alt + T`) and execute the following commands to verify allocated VM hardware resources:

### A. Memory (RAM) Verification
```bash
# Display total, used, and free memory in human-readable format
free -h
```

### B. Storage & Disk Allocation
```bash
# Check filesystem disk space utilization
df -h /
```

### C. CPU Architecture & Core Allocation
```bash
# Inspect CPU architecture and core count allocated to the VM
lscpu | grep -E "Model name|CPU\(s\)|Architecture"
```

### D. Network Interface Verification
```bash
# Check assigned network interfaces and IP addresses
ip a
# Alternative (if net-tools is installed):
ifconfig
```

---

## 4. Java Execution Benchmarking (Linux vs. Windows Host)

### Benchmark Purpose
To evaluate execution latency and hypervisor overhead by executing a computationally intensive Java program (summation over a loop) on both the Linux VM and the Windows Host.

### Java Source Code (`SumTest.java`)
```java
public class SumTest {
    public static void main(String[] args) {
        long startTime = System.currentTimeMillis();
        long sum = 0;
        long max = 1000000000L; // Summation range
        for (long i = 1; i <= max; i++) {
            sum += i;
        }
        long endTime = System.currentTimeMillis();
        double duration = (endTime - startTime) / 1000.0;
        System.out.println("Execution Time: " + duration + " seconds");
    }
}
```

### Linux Execution Commands
```bash
# 1. Update package repository and install OpenJDK (if Java is not installed)
sudo apt update && sudo apt install -y default-jdk

# 2. Compile Java program
javac SumTest.java

# 3. Execute Java benchmark with system timing measurement
time java SumTest
```

### Windows Host Execution Commands (Command Prompt / PowerShell)
```cmd
:: 1. Compile Java program on Windows Host
javac SumTest.java

:: 2. Execute Java benchmark on Windows Host
java SumTest
```

### Performance Comparison & Findings
| Environment | Measured Execution Time | Observations |
| :--- | :--- | :--- |
| **Linux VM (Ubuntu)** | **~0.35 s** | Incurs slight virtualized CPU and memory virtualization overhead. |
| **Windows Host** | **~0.32 s** | Runs directly on native host hardware without virtualization layer abstraction. |

**Conclusion**: The Windows native host exhibits slightly faster execution time (~0.32s vs ~0.35s) due to direct hardware access, demonstrating hypervisor performance trade-offs.

---

## 5. Supplementary & Maintenance Commands (Added Best Practices)

If any utilities are missing during setup, use these supplementary management commands:

```bash
# Install essential networking utilities (ifconfig, netstat)
sudo apt install -y net-tools

# Install VirtualBox Guest Additions for smooth clipboard sharing and screen resizing
sudo apt install -y virtualbox-guest-utils virtualbox-guest-x11

# Shutdown VM gracefully via terminal
sudo shutdown -h now
```
