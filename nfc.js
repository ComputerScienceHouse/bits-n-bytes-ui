const { SerialPort } = require('serialport');
const { Buffer } = require('buffer'); // Ensure Buffer is available

// --- Configuration ---
// Check your system for the correct port path. Common options:
// - USB Adapter: '/dev/ttyUSB0' or '/dev/ttyACM0'
// - Onboard Pi GPIO UART: '/dev/serial0' (after enabling)
const portPath = '/dev/ttyUSB1'; 
const baudRate = 9600; 
const PAYLOAD_SIZE = 7;
// The 8-byte ACK packet the Pi sends to the ESP32
const ACK_PAYLOAD = Buffer.alloc(7);
ACK_PAYLOAD[0] = 0xFF 
// --- End Configuration ---

// 1. Initialize the Serial Port
const port = new SerialPort({ 
    path: portPath, 
    baudRate: baudRate 
});

// 2. State for Manual Buffer Accumulation
let receiveBuffer = Buffer.alloc(0);

// 3. Handle connection opening
port.on('open', () => {
  console.log('Serial Port Opened Successfully.');
  console.log(`Listening for ${PAYLOAD_SIZE}-byte data chunks from ESP32 on ${portPath}...`);
  
  // Send an initial binary message to the ESP32
  port.write(ACK_PAYLOAD, (err) => {
    if (err) {
      return console.log('Error on write: ', err.message);
    }
    console.log('Pi: Initial 7-byte message sent.');
  });
});

// 4. Handle incoming data (manual fixed-length parsing)
port.on('data', (data) => {
  // Append new incoming data to the accumulator buffer
  receiveBuffer = Buffer.concat([receiveBuffer, data]);

  // While we have enough data for at least one full packet
  while (receiveBuffer.length >= PAYLOAD_SIZE) {
    // Extract the full packet (8 bytes)
    const packet = receiveBuffer.subarray(0, PAYLOAD_SIZE);
    
    // Trim the accumulator buffer, removing the processed packet
    receiveBuffer = receiveBuffer.subarray(PAYLOAD_SIZE);

    // --- Process the Received Packet ---
    
    // Read the 4-byte message counter from the buffer (starting at offset 4, Big Endian)
    // ESP32 sends DEADBEEF in bytes 0-3, and the counter in bytes 4-7
    const counter = packet.readUInt32BE(0);
    
    console.log(`\n--- Received Packet ---`);
    console.log(`Buffer (Hex): ${packet.toString('hex')}`);
    console.log(`Decoded Counter: ${counter}`);
  }
});

// 5. Handle errors
port.on('error', (err) => {
  console.error('\nSerial Port Error: ', err.message);
  console.error(`Please check the portPath variable ('${portPath}') and ensure the ESP32 is connected and powered.`);
});