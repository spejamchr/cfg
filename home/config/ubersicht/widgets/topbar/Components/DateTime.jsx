import { React } from "uebersicht";
import Item from "./item.jsx";

const DateTime = ({ dateTime: { date, time } }) => {
  return (
    <>
      <Item text={date} />
      <Item text={time} />
    </>
  );
};

export default DateTime;
