import { React } from "uebersicht";
import Item from "./item.jsx";

// Uebersicht needs this to be imported
React;

const Battery = ({ power, colors }) => {
  const text = `${power.plugged ? "" : " "} ${power.battery}`;

  return (
    <Item
      color={power.plugged ? colors.Yellow : colors.Magenta}
      text={text}
      bg={colors.Black}
    />
  );
};

export default Battery;
