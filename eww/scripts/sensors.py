#!/usr/bin/env python3
import sys
import glob
import subprocess
import re

def get_cpu_temp():
    # Try lm-sensors first
    try:
        out = subprocess.check_output(["sensors"], text=True, stderr=subprocess.DEVNULL)
        # Look for Tctl (AMD), Package id 0 (Intel), Core 0, or thermal-fan
        m = re.search(r'(?:Tctl|Package id 0|Core 0|cpu_thermal):\s*\+?([0-9.]+)', out)
        if m:
            return str(int(float(m.group(1))))
    except Exception:
        pass
    
    # Fallback to sysfs thermal zones
    for zone in glob.glob("/sys/class/thermal/thermal_zone*/temp"):
        try:
            with open(zone, "r") as f:
                val = int(f.read().strip())
                if 10000 < val < 115000:
                    return str(int(val / 1000))
        except Exception:
            pass
    return "0"

def get_gpu_temp():
    # Try nvidia-smi
    try:
        out = subprocess.check_output(["nvidia-smi", "--query-gpu=temperature.gpu", "--format=csv,noheader"], text=True, stderr=subprocess.DEVNULL)
        val = out.strip()
        if val.isdigit():
            return val
    except Exception:
        pass

    # Try sensors for amdgpu or intel
    try:
        out = subprocess.check_output(["sensors"], text=True, stderr=subprocess.DEVNULL)
        lines = out.splitlines()
        in_gpu = False
        for line in lines:
            if "amdgpu" in line.lower() or "i915" in line.lower():
                in_gpu = True
            elif "adapter:" in line.lower() or (line and not line.startswith(" ") and ":" not in line):
                in_gpu = False
            if in_gpu:
                m = re.search(r'edge:\s*\+?([0-9.]+)', line)
                if m:
                    return str(int(float(m.group(1))))
    except Exception:
        pass

    # Fallback to sysfs hwmon for drm
    for path in glob.glob("/sys/class/drm/card*/device/hwmon/hwmon*/temp1_input"):
        try:
            with open(path, "r") as f:
                val = int(f.read().strip())
                if 10000 < val < 115000:
                    return str(int(val / 1000))
        except Exception:
            pass

    return "0"

def main():
    if len(sys.argv) > 1:
        target = sys.argv[1].lower()
        if target == "cpu":
            print(get_cpu_temp())
            return
        elif target == "gpu":
            print(get_gpu_temp())
            return
    print("0")

if __name__ == "__main__":
    main()
