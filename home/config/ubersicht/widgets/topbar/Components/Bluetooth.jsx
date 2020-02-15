import { React } from "uebersicht";
import Item from "./item.jsx";

const Bluetooth = ({ bluetooth, colors }) => {
  const string = bluetooth.on
    ? bluetooth.connected
      ? " Paired"
      : " On"
    : " Off";

  const bluetoothColor = bluetooth.on
    ? bluetooth.connected
      ? colors.Blue
      : colors.Green
    : colors.BrightBlack;

  return <Item color={bluetoothColor} text={string} />;
};

export default Bluetooth;
