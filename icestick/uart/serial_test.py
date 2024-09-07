import serial
import time
import random 
# Configure the serial port
ser = serial.Serial('/dev/ttyUSB0', 115200)
flag = 0

packetA = b'\xFF\x00\x11\x01\x02\x03\x04\x0a'
packetB = b'\xFF\x01\x11\x05\x06\x07\x08\x1a'
test = b'\xDE\xAD\xBE\xEF'

chars = "skdjkqjbvkbawii2d9b977@(792f7297@G(&fg2))"

try:
    while True:
        ser.write(chars[random.randint(0, len(chars) -1)].encode('utf-8'))
        time.sleep(0.1)

        if ser.in_waiting > 0:
            print(ser.read(ser.in_waiting))
            # incoming_bytes = ser.read(ser.in_waiting)
            # [print(hex(byte), end=' ') for byte in incoming_bytes]
            # print()

        # # # Prompt for user input
        # # message = input("Enter message to send: ")
        # time.sleep(0.1)
        


        # print(f"Sent: {message}")
        # time.sleep(1)

except KeyboardInterrupt:
    print("\nExiting...")
finally:
    # Ensure the serial port is closed on exit
    ser.close()
