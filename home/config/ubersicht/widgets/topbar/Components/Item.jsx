import { React } from "uebersicht";

const Item = ({ text, hide, color }) =>
  hide ? (
    ""
  ) : (
    <span>
      「 <span style={color ? { color } : {}}>{text}</span> 」
    </span>
  );

export default Item;
