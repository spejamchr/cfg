import { React } from "uebersicht";
import fourColorRange from "../Utils/FourColorRange.jsx";
import Item from "./item.jsx";

// Uebersicht needs this to be imported
React;

const getColor = fourColorRange({ min: 0.33, med: 0.5, max: 1 });

const LoadAvg = ({ loadavg, cpus, colors }) => {
  return (
    <Item
      color={getColor(colors, Number(loadavg) / cpus)}
      text={loadavg}
      bg={colors.Black}
    />
  );
};

export default LoadAvg;
