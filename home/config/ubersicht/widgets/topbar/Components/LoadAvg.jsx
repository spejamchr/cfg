import { React } from "uebersicht";
import Item from "./item.jsx";

const LoadAvg = ({ loadavg, cpus, colors }) => {
  return (
    <Item
      color={Number(loadavg) > cpus ? colors.Red : colors.Green}
      text={loadavg}
    />
  );
};

export default LoadAvg;
