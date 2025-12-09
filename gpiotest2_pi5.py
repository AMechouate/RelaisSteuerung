#!/usr/bin/python3
from gpiozero import OutputDevice
import time

# GPIO | Relay
#--------------
# 26     01
# 19     02
# 13     03
# 06     04
# 12     05
# 16     06
# 20     07
# 21     08

gpioList = [26, 19, 13, 6, 12, 16, 20, 21]

# Erstelle OutputDevice-Objekte (active_high=False bedeutet LOW = ein)
relays = [OutputDevice(pin, active_high=False) for pin in gpioList]

# Sleep time variables
sleepTimeShort = 0.2
sleepTimeLong = 0.1

# MAIN LOOP
try:
    while True:
        for relay in relays:
            relay.on()   # Relais ein
            time.sleep(sleepTimeShort)
            relay.off()  # Relais aus
            time.sleep(sleepTimeLong)

except KeyboardInterrupt:
    print("Quit")
    # Cleanup
    for relay in relays:
        relay.close()

