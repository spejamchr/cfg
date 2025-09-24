import { React } from "uebersicht";
import { containerStyles } from "../index.jsx";
import { monitorId } from "../Utils/Monitor.jsx";
import Item from "./item.jsx";

// Uebersicht needs this to be imported
React;

const Spaces = ({ spaces, colors }) => {
  const displayId = monitorId === "1" ? 1 : 2;

  const spacesOnMonitor = spaces.filter((s) => s["display"] === displayId);

  const currentSpace = spacesOnMonitor.find(
    (s) => s["has-focus"] || s["is-visible"],
  );

  const currentSpaceNumber =
    currentSpace?.index.toLocaleString("ja-JP-u-nu-hanidec");

  const totalSpaces =
    spacesOnMonitor.length.toLocaleString("ja-JP-u-nu-hanidec");

  const text = `${currentSpaceNumber} / ${totalSpaces}`;

  return (
    <span
      style={{ ...containerStyles(colors, "auto"), minWidth: "fit-content" }}
    >
      <Item
        color={
          currentSpace?.["has-focus"]
            ? colors.Cyan
            : currentSpace?.["is-visible"]
              ? colors.White
              : colors.BrightBlack
        }
        text={text}
        bg={colors.Black}
        style={{ minWidth: "fit-content" }}
      />
    </span>
  );
};

export default Spaces;
