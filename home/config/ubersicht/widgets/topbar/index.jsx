import { styled } from "uebersicht";
import Battery from "./Components/Battery.jsx";
import Bluetooth from "./Components/Bluetooth.jsx";
import CpuMeter from "./Components/CpuMeter.jsx";
import DateTime from "./Components/DateTime.jsx";
import LoadAvg from "./Components/LoadAvg.jsx";
import Pianobar from "./Components/Pianobar.jsx";
import Spaces from "./Components/Spaces.jsx";
import Window from "./Components/Window.jsx";
import prepare from "./Utils/Prepare.jsx";
import Item from "./Components/Item.jsx";

export const refreshFrequency = 1000;

export const command = `./topbar/command`;

export const className = {
  width: "100%",
  height: "35px",
  color: "white",
  fontFamily: "FiraCode Nerd Font",
  fontSize: "12px",
  userSelect: "none",
  cursor: "default",
  whitespace: "nowrap",
  zIndex: 1,
};

const containerStyles = (colors, width) => ({
  height: "100%",
  width: width,
  maxWidth: width,
  boxSizing: "border-box",
  display: "flex",
  justifyContent: "space-between",
  alignItems: "center",
  whiteSpace: "nowrap",
  padding: "0px 5px",
  color: colors.White,
  overflow: "hidden",
});

export const render = prepare(
  "topbar",
  ({
    bluetooth,
    colors,
    cpus,
    dateTime,
    loadavg,
    percentCpu,
    pianobar,
    power,
    spaces,
    windows,
  }) => {
    const OuterContainer = styled.div(containerStyles(colors, "100%"));
    const InnerContainerLeft = styled.div(containerStyles(colors, "1700px"));
    const InnerContainerRight = styled.div({
      ...containerStyles(colors, "1700px"),
      flexDirection: "row-reverse",
    });
    const M1Notch = styled.div({ width: "400px" });
    const OverflowTester = styled.div({
      overflow: "hidden",
      whiteSpace: "nowrap",
      textOverflow: "ellipsis",
    });

    return (
      <OuterContainer>
        <InnerContainerLeft>
          <Spaces spaces={spaces} colors={colors} />
          <Pianobar pianobar={pianobar} />
        </InnerContainerLeft>
        <M1Notch />
        <InnerContainerRight>
          <span>
            <LoadAvg loadavg={loadavg} cpus={cpus} colors={colors} />
            <CpuMeter percentCpu={percentCpu} cpus={cpus} colors={colors} />
            <Bluetooth bluetooth={bluetooth} colors={colors} />
            <Battery power={power} colors={colors} />
            <DateTime dateTime={dateTime} />
          </span>
          <Window windows={windows} colors={colors} />
        </InnerContainerRight>
      </OuterContainer>
    );
  }
);
