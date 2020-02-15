import { React } from "uebersicht";
import Item from "./item.jsx";

const LoadAvg = ({ loadavg, cpus, colors }) => {
  const string = Number(loadavg) > cpus ? ` ${loadavg}` : ` ${loadavg}`;

  return (
    <Item
      color={Number(loadavg) > cpus ? colors.Red : colors.Green}
      text={string}
    />
  );
};

export default LoadAvg;
