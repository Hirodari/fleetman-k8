from calendar import month
from datetime import datetime
from dotenv import load_dotenv
import os
# install python3 -m pip install python-dotenv
# create .env file where you store your sensitive info
# makesure to declare it in .gitignore, it should be in your repo
load_dotenv()
my_password = os.getenv('monitoringPasscode')

now = datetime.now()
y, m = now.year, now.month

print(month(y, m))

print("="*20)
print(f"My secret key: {my_password}")
