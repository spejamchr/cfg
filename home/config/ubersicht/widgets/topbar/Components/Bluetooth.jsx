import { React } from "uebersicht";
import Item from "./item.jsx";

const Bluetooth = ({ bluetooth, colors }) => {
  const string = bluetooth.connected ? " Paired" : " On";

  const bluetoothColor = bluetooth.connected ? colors.Blue : colors.Green;

  return <Item hide={!bluetooth.on} color={bluetoothColor} text={string} />;
};

export default Bluetooth;
