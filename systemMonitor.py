#!/home/hiro/jupyterEnv/bin/python3

import psutil
import smtplib
import socket
import os
from dotenv import load_dotenv
# import configparser

from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from datetime import datetime

def bytes_to_gb(bytes):
    gb = bytes / (1024 ** 3)
    return gb

def get_hostname():
    hostname = socket.gethostname()
    return hostname

# Function to get disk usage
def get_disk_usage():
    disk_partitions = psutil.disk_partitions()
    disk_usage = {}
    for partition in disk_partitions:
        try:
            usage = psutil.disk_usage(partition.mountpoint)
            disk_usage[partition.device] = {
                "mountpoint": partition.mountpoint,
                "total": bytes_to_gb(usage.total),
                "used": bytes_to_gb(usage.used),
                "free": bytes_to_gb(usage.free),
                "percent": usage.percent
            }
        except Exception as e:
            print(f"Error getting disk usage for {partition.mountpoint}: {e}")
    return disk_usage

# Function to get system performance
def get_system_performance():
    cpu_percent = psutil.cpu_percent()
    mem = psutil.virtual_memory()
    mem_percent = mem.percent
    return cpu_percent, mem_percent

# config = configparser.ConfigParser()
# config.read('/home/hiro/Documents/Docker & Kubernetes/Kubernetes/config.ini')
# Function to send email
# loading my dot env keys
load_dotenv()
def send_email(subject, body):
    from_email = os.getenv('senderEmailID') 
    to_email = os.getenv('receiverEmailID') #config['Credentials']['receiverEmailID']
    password = os.getenv('monitoringPasscode') #config['Credentials']['monitoringPasscode']
    msg = MIMEMultipart()
    msg['From'] = from_email
    msg['To'] = to_email
    msg['Subject'] = subject

    msg.attach(MIMEText(body, 'plain'))

    server = smtplib.SMTP('smtp.stackmail.com', 587)
    server.starttls()
    server.login(from_email, password)
    text = msg.as_string()
    server.sendmail(from_email, to_email, text)
    server.quit()

# Thresholds for disk usage and system performance
disk_threshold = 70  # percent
cpu_threshold = 70   # percent
mem_threshold = 60   # percent

# Main function
def main():
    hostname = get_hostname()
    disk_usage = get_disk_usage()
    for device, usage_info in disk_usage.items():
        if device == "/dev/sda3" and usage_info['percent'] > disk_threshold:
            send_email("Disk Space Alert", 
                f"Summary of the disk usage: \
                \n{'='*30} \
                \n \
                \{datetime.now().strftime('%d-%m-%Y %H:%M:%S')} \
                \nHostname: {hostname} \
                \nThe device: {device} \
                \nMounted on: / \
                \nSize: {round(usage_info['total'], 1)} Gi \
                \nUsed: {round(usage_info['used'], 1)} Gi \
                \nFree: {round(usage_info['free'], 1)} Gi \
                \nUse : {round(usage_info['percent'], 1)} %"
            )

    cpu_percent, mem_percent = get_system_performance()
    if cpu_percent > cpu_threshold:
        send_email("CPU Usage Alert", 
            f"Summary of CPU usage: \
            \n{'='*30} \
            \n{datetime.now().strftime('%d-%m-%Y %H:%M:%S')} \
            \nHostname: {hostname} \
            \nThe device: {device} \
            \nThe CPU usage is {cpu_percent}%.")

    if mem_percent > mem_threshold:
        send_email("Memory Usage Alert", 
            f"Summary of Memory usage: \
            \n{'='*20} \
            \n{datetime.now().strftime('%d-%m-%Y %H:%M:%S')} \
            \nHostname: {hostname} \
            \nThe device: {device} \
            \nThe memory usage is {mem_percent}%.")

 

if __name__ == "__main__":
    main()
    print(f"{datetime.now().strftime('%d-%m-%Y %H:%M:%S')}: email sent!")
