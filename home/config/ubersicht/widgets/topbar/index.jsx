import { React } from "uebersicht";
import Battery from "./Components/Battery.jsx";
import Bluetooth from "./Components/Bluetooth.jsx";
import CpuMeter from "./Components/CpuMeter.jsx";
import DateTime from "./Components/DateTime.jsx";
import LoadAvg from "./Components/LoadAvg.jsx";
import Pianobar from "./Components/Pianobar.jsx";
import Spaces from "./Components/Spaces.jsx";
import styledContainer from "./Utils/StyledContainer.jsx";

export const refreshFrequency = 1000;

export const className = {
  top: 0,
  left: 0,
  width: "100%",
  height: "20px",
  backgroundColor: "#202020",
  color: "#a8a8a8",
  fontFamily: "FiraCode Nerd Font",
  fontSize: "11px",
  whitespace: "nowrap"
};

export const render = ({ error, output }) => {
  if (error !== undefined) {
    console.error("[topbar]: ", error);
    return "";
  }

  if (output === "") {
    // First render, before the command has been run
    return "";
  }

  let parsed;
  try {
    parsed = JSON.parse(output);
  } catch (err) {
    console.error("[topbar]: ", err);
    console.dir(output);
    return "Error Parsing JSON";
  }

  const {
    bluetooth,
    colors,
    cpus,
    dateTime,
    loadavg,
    percentCpu,
    pianobar,
    power,
    spaces
  } = parsed;

  const Container = styledContainer(colors);

  return (
    <Container>
      <Spaces spaces={spaces} colors={colors} />
      <Pianobar pianobar={pianobar} />
      <span>
        <LoadAvg loadavg={loadavg} cpus={cpus} colors={colors} />
        <CpuMeter percentCpu={percentCpu} cpus={cpus} colors={colors} />
        <Bluetooth bluetooth={bluetooth} colors={colors} />
        <Battery power={power} colors={colors} />
        <DateTime dateTime={dateTime} />
      </span>
    </Container>
  );
};

export const command = `./topbar/command`;
