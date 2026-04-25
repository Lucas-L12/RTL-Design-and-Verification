# Receiver

## Description
UART receiver implemented using a finite state machine (FSM).

## States
- Idle: waits for start bit
- Start: validates start bit
- Data: receives 8 bits
- Stop: checks stop bit

## Inputs
- `rx`: serial input
- `s_tick`: sampling tick

## Outputs
- `dout`: received byte
- `rx_done_tick`: indicates reception complete

## How it works
The receiver samples the signal in the middle of each bit using 16x oversampling.
