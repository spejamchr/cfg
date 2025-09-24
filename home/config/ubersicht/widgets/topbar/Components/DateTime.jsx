import { React } from "uebersicht";
import Item from "./item.jsx";

// Uebersicht needs this to be imported
React;

const DateTime = ({ colors }) => {
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
        bg={colors.Black}
      />
      <Item
        text={date.toLocaleTimeString("ja-JP", {
          hour: "2-digit",
          minute: "2-digit",
          hour12: false,
        })}
        bg={colors.Black}
      />
    </>
  );
};

export default DateTime;
