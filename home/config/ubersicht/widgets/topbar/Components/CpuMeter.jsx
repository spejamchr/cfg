import { css, React } from "uebersicht";
import Item from "./item.jsx";

const CpuMeter = ({ percentCpu, cpus, colors }) => {
  const cpu = (percentCpu / cpus).toFixed(0).toString();

  const meter = css({
    height: "5px",
    width: "3em",
    position: "relative",
    display: "inline-block",
    background: colors.BrightBlack,
    borderRadius: "25px",
    padding: "1px"
  });

  const barColor =
    cpu < 30
      ? colors.Blue
      : cpu < 60
      ? colors.Green
      : cpu < 80
      ? colors.Yellow
      : colors.Red;

  const fill = css({
    width: `${cpu}%`,
    display: "block",
    height: "100%",
    borderTopRightRadius: 0,
    borderBottomRightRadius: 0,
    borderTopLeftRadius: 20,
    borderBottomLeftRadius: 20,
    backgroundColor: barColor,
    position: "relative",
    overflow: "hidden"
  });

  return (
    <Item
      text={
        <div className={meter}>
          <span className={fill} />
        </div>
      }
    />
  );
};

export default CpuMeter;
