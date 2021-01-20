import { React } from "uebersicht";
import Item from "./item.jsx";

const DateTime = () => {
  const date = new Date();
  return (
    <>
      <Item
        text={date.toLocaleDateString("ja-JP", {
          weekday: "short",
          year: "numeric",
          month: "short",
          day: "numeric",
        })}
      />
      <Item
        text={date.toLocaleTimeString("ja-JP", {
          hour: "2-digit",
          minute: "2-digit",
          hour12: false,
        })}
      />
    </>
  );
};

export default DateTime;
