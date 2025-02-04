import { React } from "uebersicht";
import Item from "./item.jsx";
import { containerStyles } from "../index.jsx";
import { monitorId } from "../Utils/Monitor.jsx";

const Spaces = ({ spaces, colors }) => {
  const displayId = monitorId === "1" ? 1 : 2;

  return (
    <span
      style={{ ...containerStyles(colors, "auto"), minWidth: "fit-content" }}
    >
      {spaces
        .filter((s) => s["display"] === displayId)
        .map((s) => (
          <Item
            key={s.index}
            color={
              s["has-focus"]
                ? colors.Cyan
                : s["is-visible"]
                  ? colors.White
                  : colors.BrightBlack
            }
            text={s.index.toLocaleString("ja-JP-u-nu-hanidec")}
            bg={colors.Black}
            style={{ minWidth: "fit-content" }}
          />
        ))}
    </span>
  );
};

export default Spaces;
