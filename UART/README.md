# UART in Verilog

## 🧠 Architecture

![UART Diagram](docs/Uart_chart)

---

## 🔗 Blocks Description

### RX Path
- [Baud Rate Generator](docs/baudrate.md)
- [Receiver](docs/receiver.md)
- [Interface RX](docs/interface_rx.md)

### TX Path
- [Interface TX](docs/interface_tx.md)
- [Transmitter](docs/transmitter.md)

---

## 🔁 Data Flow

RX:
rx → receiver → interface → r_data

TX:
w_data → interface → transmitter → tx
