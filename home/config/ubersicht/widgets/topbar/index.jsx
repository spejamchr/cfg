import { styled, React } from "uebersicht";
import Battery from "./Components/Battery.jsx";
import CpuMeter from "./Components/CpuMeter.jsx";
import DateTime from "./Components/DateTime.jsx";
import LoadAvg from "./Components/LoadAvg.jsx";
import Pianobar from "./Components/Pianobar.jsx";
import Spaces from "./Components/Spaces.jsx";
import Window from "./Components/Window.jsx";
import prepare from "./Utils/Prepare.jsx";
import { monitorId } from "./Utils/Monitor.js";

export const refreshFrequency = 1000;

export const command = `./topbar/command`;

export const className = {
  width: "100%",
  height: "35px",
  color: "white",
  fontFamily: "FiraCode Nerd Font",
  fontSize: "11px",
  userSelect: "none",
  cursor: "default",
  whitespace: "nowrap",
  zIndex: 1,
};

export const containerStyles = (colors, width) => ({
  height: "100%",
  width: width,
  maxWidth: width,
  boxSizing: "border-box",
  display: "flex",
  justifyContent: "space-between",
  alignItems: "center",
  whiteSpace: "nowrap",
  color: colors.White,
  overflow: "hidden",
});

export const render = prepare(
  "topbar",
  ({
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
    const OuterContainer = styled.div({
      ...containerStyles(colors, "100%"),
      padding: "3px",
    });
    const InnerContainer = styled.div({ ...containerStyles(colors, "100%") });
    const InnerContainerLeft = styled.div({
      ...containerStyles(colors, "1700px"),
      paddingRight: "5px",
    });
    const InnerContainerRight = styled.div({
      ...containerStyles(colors, "1700px"),
      flexDirection: "row-reverse",
    });
    const M1Notch = styled.div({ width: "450px" });

    const leftSide = (
      <>
        <Spaces spaces={spaces} colors={colors} />
        <Pianobar pianobar={pianobar} colors={colors} />
      </>
    );

    const rightSide = (
      <span style={containerStyles(colors, "fit")}>
        <LoadAvg loadavg={loadavg} cpus={cpus} colors={colors} />
        <CpuMeter percentCpu={percentCpu} cpus={cpus} colors={colors} />
        <Battery power={power} colors={colors} />
        <DateTime dateTime={dateTime} colors={colors} />
        &nbsp; {/* For the orange dot on mic/camera usage */}
      </span>
    );

    const windowInfo = <Window windows={windows} colors={colors} />;

    if (monitorId == "1") {
      return (
        <OuterContainer>
          <InnerContainerLeft>{leftSide}</InnerContainerLeft>
          <M1Notch />
          <InnerContainerRight>
            {rightSide}
            {windowInfo}
          </InnerContainerRight>
        </OuterContainer>
      );
    } else {
      return (
        <OuterContainer>
          <InnerContainer>
            {leftSide}
            {windowInfo}
            {rightSide}
          </InnerContainer>
        </OuterContainer>
      );
    }
  },
);
