import serial
import time

# Configure the serial port
ser = serial.Serial('/dev/ttyUSB0', 115200)
flag = 0

packetA = b'\xFF\x00\x11\x01\x02\x03\x04\x0a'
packetB = b'\xFF\x01\x11\x05\x06\x07\x08\x1a'

try:
    while True:
        # ser.write(packetA)
        # time.sleep(0.1)
        # ser.write(packetB)

        if ser.in_waiting > 0:
            incoming_bytes = ser.read(ser.in_waiting)
            try:
                incoming_text = incoming_bytes.decode('utf-8')
                print(f"rx: {incoming_text}")
            except UnicodeDecodeError:
                print("rx:", incoming_bytes.hex())

        # # # Prompt for user input
        # # message = input("Enter message to send: ")
        # time.sleep(0.1)
        

        # ser.write("****************".encode('utf-8'))

        # print(f"Sent: {message}")
        # time.sleep(1)

except KeyboardInterrupt:
    print("\nExiting...")
finally:
    # Ensure the serial port is closed on exit
    ser.close()
