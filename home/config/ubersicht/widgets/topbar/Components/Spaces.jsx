import { React } from "uebersicht";
import Item from "./item.jsx";
import { containerStyles } from "../index.jsx";

const Spaces = ({ spaces, colors }) => (
  <span style={{ ...containerStyles(colors, "auto"), minWidth: "fit-content" }}>
    {spaces.map((s) => (
      <Item
        key={s.index}
        color={s['has-focus'] ? colors.BrightWhite : colors.BrightBlack}
        text={s.index.toLocaleString("ja-JP-u-nu-hanidec")}
        bg={colors.Black}
        style={{ minWidth: "fit-content" }}
      />
    ))}
  </span>
);

export default Spaces;
