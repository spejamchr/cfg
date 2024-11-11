import { React } from "uebersicht";
import Item from "./item.jsx";
import { containerStyles } from "../index.jsx";

const Spaces = ({ spaces, colors }) => (
  <span style={containerStyles(colors, "fit")}>
    {spaces.map((s) => (
      <Item
        key={s.index}
        color={s['has-focus'] ? colors.BrightWhite : colors.BrightBlack}
        text={s.index.toLocaleString("ja-JP-u-nu-hanidec")}
        bg={colors.Black}
      />
    ))}
  </span>
);

export default Spaces;
