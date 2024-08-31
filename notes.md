### mat maven

A dedicated matrix multiplication device project for self learning, in three phases:

1. On FPGA (Lattice ICEStick) sending packets over UART
2. On same FPGA sending packets over 100GbE with an ethernet PHY PMOD 
3. On a custom ASIC interfacing with same PMOD

---

#### Notes

*Entry 1 -- August 31, 2024*

Let's define the goal. I want to learn about hardware accelerators. A good way to learn is to build one. They come in all shapes and sized but since AI is all the rage and AI is also basically lots of matrix multiplications let's start with a mat mul device.

I don't expect my device to necessarily run faster than my CPU. This is an educational project. Maybe we can get there though :)

Let's set a scope. According to Tiny Tapeout I get around 40 bytes of memory in my ASIC tile. Let's do 2x2 matrices. Let's assume I'll need to store both so 2 * 2^2 * B where B is the size of each item --> 40 bytes / 8 = 40 bits per item. So we could do 32 bit floats. But let's keep things even simpler and make them 16 bit floats because then I could fit a whole 2*2 matrix in a single 8 bit UART packet. Once we get to ethernet we can move up in the world.

...

Let's start with uint8s and that way I can fit whole matrices in a packet as well as metadata and checksum. Once I get to 100GbE I will have at least 46 bytes which is enough to send everything as one packet.

As a basic flow for UART, the client will just send 2 consecutive packets with the following:
1. Command ID - for now just multiplication but who knows...
2. Job ID - randomized byte used to ensure job is completed
3. Matrix ID - which matrix is contained in payload
4. Payload - 2x2 uint8 matrix
5. Checksum

After the target device receives two matrices of a given job it will perform the command.

##### Packet structure:

```
╔════════╦════════╦═════════════════╦═══════════════╦══════════╗
║ byte 0 ║ byte 1 ║ byte 2          ║ byte 3-6      ║ byte 7   ║
╠════════╬════════╬═════════════════╬═══════════════╬══════════╣
║ cmd ID ║ job ID ║ mat ID (A or B) ║ 2*2 uint8 mat ║ checksum ║
╚════════╩════════╩═════════════════╩═══════════════╩══════════╝
```





