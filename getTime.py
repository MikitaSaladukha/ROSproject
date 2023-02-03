from datetime import datetime

now = datetime.now()

current_time = now.strftime("%H:%M:%S")
print(current_time)