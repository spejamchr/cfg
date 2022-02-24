import { React } from "uebersicht";
import Item from "./item.jsx";

const Window = ({ windows }) =>
  windows
    .filter((w) => w["has-focus"])
    .map((w) => <Item key={w.id} text={w.app} />);

export default Window;
