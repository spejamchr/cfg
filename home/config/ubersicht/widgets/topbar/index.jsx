import { React } from "uebersicht";
import Battery from "./Components/Battery.jsx";
import Bluetooth from "./Components/Bluetooth.jsx";
import CpuMeter from "./Components/CpuMeter.jsx";
import DateTime from "./Components/DateTime.jsx";
import LoadAvg from "./Components/LoadAvg.jsx";
import Pianobar from "./Components/Pianobar.jsx";
import Spaces from "./Components/Spaces.jsx";
import Window from "./Components/Window.jsx";
import prepare from "./Utils/Prepare.jsx";
import styledContainer from "./Utils/StyledContainer.jsx";

export const refreshFrequency = 5000;

export const command = `./topbar/command`;

export const className = {
  width: "100%",
  height: "20px",
  backgroundColor: "#202020",
  color: "#a8a8a8",
  fontFamily: "FiraCode Nerd Font",
  fontSize: "11px",
  whitespace: "nowrap"
};

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
    windows
  }) => {
    const Container = styledContainer(colors);

    return (
      <Container>
        <Spaces spaces={spaces} colors={colors} />
        <Pianobar pianobar={pianobar} />
        <Window windows={windows} colors={colors} />
        <span>
          <LoadAvg loadavg={loadavg} cpus={cpus} colors={colors} />
          <CpuMeter percentCpu={percentCpu} cpus={cpus} colors={colors} />
          <Bluetooth bluetooth={bluetooth} colors={colors} />
          <Battery power={power} colors={colors} />
          <DateTime dateTime={dateTime} />
        </span>
      </Container>
    );
  }
);
