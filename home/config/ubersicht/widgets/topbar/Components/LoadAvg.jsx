import { React } from "uebersicht";
import fourColorRange from "../Utils/FourColorRange.jsx";
import Item from "./item.jsx";

const getColor = fourColorRange({ min: 0.33, med: 0.5, max: 1 });

const LoadAvg = ({ loadavg, cpus, colors }) => {
  return (
    <Item color={getColor(colors, Number(loadavg) / cpus)} text={loadavg} />
  );
};

export default LoadAvg;
