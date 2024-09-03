import serial
import time

# Configure the serial port
ser = serial.Serial('/dev/ttyUSB0', 115200)
flag = 0
try:
    while True:
        # Check for incoming bytes
        if ser.in_waiting > 0:
            incoming_bytes = ser.read(ser.in_waiting)
            try:
                # Attempt to decode as UTF-8
                incoming_text = incoming_bytes.decode('utf-8')
                print(f"rx: {incoming_text}")
            except UnicodeDecodeError:
                # Handle bytes that can't be decoded
                print("rx:", incoming_bytes.hex())

        # # Prompt for user input
        # message = input("Enter message to send: ")
        time.sleep(0.1)
        
        # # Send the message
        if flag == 0:
            ser.write("*".encode('utf-8'))
            flag = 1
        else:
            ser.write("4".encode('utf-8'))
            flag = 0

        # print(f"Sent: {message}")

except KeyboardInterrupt:
    print("\nExiting...")
finally:
    # Ensure the serial port is closed on exit
    ser.close()
