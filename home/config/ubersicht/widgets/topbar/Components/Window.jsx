import { React } from "uebersicht";
import Item from "./item.jsx";

const maxLength = 39;

const Window = ({ windows, colors }) => (
  <span>
    {windows
      .filter(w => w.focused === 1)
      .map(w => {
        const title =
          w.title.length > maxLength
            ? w.title.substring(0, maxLength - 3) + "..."
            : w.title;

        return (
          <span key={w.id}>
            <Item color={colors.BrightWhite} text={w.app} />
            <Item color={colors.BrightWhite} text={title} />
          </span>
        );
      })}
  </span>
);

export default Window;
