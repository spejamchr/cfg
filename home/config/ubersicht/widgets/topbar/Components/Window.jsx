import { React } from "uebersicht";
import Item from "./item.jsx";

const Window = ({ windows }) => (
  <span>
    {windows
      .filter(w => w.focused === 1)
      .map(w => (
        <Item key={w.id} text={w.app} />
      ))}
  </span>
);

export default Window;
