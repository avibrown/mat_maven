import serial

# Configure the serial port
ser = serial.Serial('/dev/ttyUSB0', 115200)

try:
    while True:
        # Check for incoming bytes
        if ser.in_waiting > 0:
            incoming_bytes = ser.read(ser.in_waiting)
            try:
                # Attempt to decode as UTF-8
                incoming_text = incoming_bytes.decode('utf-8')
                print(f"Received: {incoming_text}")
            except UnicodeDecodeError:
                # Handle bytes that can't be decoded
                print("Received raw bytes:", incoming_bytes.hex())

        # # Prompt for user input
        # message = input("Enter message to send: ")
        
        # # Send the message
        # ser.write(message.encode('utf-8'))
        # print(f"Sent: {message}")

except KeyboardInterrupt:
    print("\nExiting...")
finally:
    # Ensure the serial port is closed on exit
    ser.close()
