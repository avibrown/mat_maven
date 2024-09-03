import serial

# Configure the serial port
ser = serial.Serial('/dev/ttyUSB0', 115200)

try:
    while True:
        # Get user input
        message = input("Enter message to send: ")

        # Send the message
        ser.write(message.encode('utf-8'))

        print(f"Sent: {message}")

except KeyboardInterrupt:
    # Handle exit
    print("\nExiting...")
finally:
    # Close the serial port
    ser.close()
