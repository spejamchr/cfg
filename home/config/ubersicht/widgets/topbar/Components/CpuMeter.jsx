import { css, React } from "uebersicht";
import fourColorRange from "../Utils/FourColorRange.jsx";
import Item from "./item.jsx";

// Uebersicht needs this to be imported
React;

const getColor = fourColorRange({ min: 30, med: 60, max: 80 });

const CpuMeter = ({ percentCpu, cpus, colors }) => {
  const cpu = (percentCpu / cpus).toFixed(0).toString();

  const meter = css({
    height: "5px",
    width: "3em",
    position: "relative",
    display: "inline-block",
    background: colors.BrightBlack,
    borderRadius: "25px",
    padding: "1px",
  });

  const fill = css({
    width: `${cpu}%`,
    display: "block",
    height: "100%",
    borderTopRightRadius: 0,
    borderBottomRightRadius: 0,
    borderTopLeftRadius: 20,
    borderBottomLeftRadius: 20,
    backgroundColor: getColor(colors, cpu),
    position: "relative",
    overflow: "hidden",
  });

  return (
    <Item
      text={
        <div className={meter}>
          <span className={fill} />
        </div>
      }
      bg={colors.Black}
    />
  );
};

export default CpuMeter;
