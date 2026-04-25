# Receiver

## ASMD Diagram

![Receiver ASMD](Rx_ASMD.jpg)

---

## Description

The receiver is implemented as a Finite State Machine with Datapath (FSMD).

### States

- **Idle**: Waits for start bit (rx = 0)
- **Start**: Validates start bit at its midpoint
- **Data**: Receives 8 bits using oversampling
- **Stop**: Waits for stop bit and signals completion

---
The receiver takes `rx` (serial data) and `s_tick` (sampling tick from the baud rate generator) as inputs. 

It outputs `dout` (received data) and `rx_done_tick`, which acts as a flag to indicate that a new byte has been received and is ready for the RX interface.
---

## Key Features

- 16x oversampling
- Mid-bit sampling for reliability
- Shift register for data reception
