#!/usr/bin/python3
import lgpio as GPIO
import time
import sys

# Öffne GPIO-Chip
try:
    chip = GPIO.gpiochip_open(0)
except:
    print("Fehler: Kann GPIO-Chip nicht öffnen")
    sys.exit(1)

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

# Versuche zuerst alle Pins freizugeben (falls sie belegt sind)
for i in gpioList:
    try:
        GPIO.gpio_free(chip, i)
    except:
        pass

# Setze alle Pins als Output und initialisiere auf HIGH (Relais aus)
for i in gpioList:
    try:
        GPIO.gpio_claim_output(chip, i, lFlags=0)
        GPIO.gpio_write(chip, i, 1)  # HIGH = Relais aus
    except Exception as e:
        print(f"Fehler bei GPIO {i}: {e}")
        try:
            GPIO.gpio_free(chip, i)
            time.sleep(0.1)
            GPIO.gpio_claim_output(chip, i, lFlags=0)
            GPIO.gpio_write(chip, i, 1)
        except:
            print(f"Kann GPIO {i} nicht initialisieren")
            continue

# Sleep time variables
sleepTimeShort = 0.2
sleepTimeLong = 0.1

# MAIN LOOP
try:
    while True:
        for i in gpioList:
            try:
                GPIO.gpio_write(chip, i, 0)  # LOW = Relais ein
                time.sleep(sleepTimeShort)
                GPIO.gpio_write(chip, i, 1)  # HIGH = Relais aus
                time.sleep(sleepTimeLong)
            except Exception as e:
                print(f"Fehler bei GPIO {i}: {e}")

except KeyboardInterrupt:
    print("Quit")
    # Reset GPIO settings
    for i in gpioList:
        try:
            GPIO.gpio_free(chip, i)
        except:
            pass
    try:
        GPIO.gpiochip_close(chip)
    except:
        pass

