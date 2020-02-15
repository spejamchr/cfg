import { React } from "uebersicht";
import Item from "./item.jsx";

const DateTime = ({ dateTime }) => {
  const date = `${""} ${dateTime.date}`;
  const time = `${""} ${dateTime.time}`;

  return (
    <>
      <Item text={date} />
      <Item text={time} />
    </>
  );
};

export default DateTime;
