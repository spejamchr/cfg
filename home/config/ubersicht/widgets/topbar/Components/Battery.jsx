import { React } from "uebersicht";
import Item from "./item.jsx";

const Battery = ({ power, colors }) => {
  const text = `${power.plugged ? "" : " "} ${power.battery}`;

  return (
    <Item color={power.plugged ? colors.Yellow : colors.Magenta} text={text} />
  );
};

export default Battery;
