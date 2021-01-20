import { React } from "uebersicht";
import Item from "./item.jsx";

const Spaces = ({ spaces, colors }) => (
  <span>
    {spaces.map((s) => (
      <Item
        key={s.index}
        color={s.focused === 1 ? colors.BrightWhite : colors.BrightBlack}
        text={s.index.toLocaleString("ja-JP-u-nu-hanidec")}
      />
    ))}
  </span>
);

export default Spaces;
