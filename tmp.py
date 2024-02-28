import psutil

def get_disk_usage():
    disk_partitions = psutil.disk_partitions()
    disk_usage = {}
    for partition in disk_partitions:
        try:
            usage = psutil.disk_usage(partition.mountpoint)
            disk_usage[partition.device] = {
                "mountpoint": partition.mountpoint,
                "total": usage.total,
                "used": usage.used,
                "free": usage.free,
                "percent": usage.percent
            }
        except Exception as e:
            print(f"Error getting disk usage for {partition.mountpoint}: {e}")
    return disk_usage

def main():
    disk_usage = get_disk_usage()
    for device, usage_info in disk_usage.items():
        if device == "/dev/sda3":
                  print(f"Device: {device}")
                  print(f"Mountpoint: {usage_info['mountpoint']}")
                  print(f"Total space: {usage_info['total']} bytes")
                  print(f"Used space: {usage_info['used']} bytes")
                  print(f"Free space: {usage_info['free']} bytes")
                  print(f"Percentage used: {usage_info['percent']}%")
                  print()

if __name__ == "__main__":
    main()
