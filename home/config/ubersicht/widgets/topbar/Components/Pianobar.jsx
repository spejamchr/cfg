import { React } from "uebersicht";
import Item from "./item.jsx";

// Uebersicht needs this to be imported
React;

const Pianobar = ({ pianobar, colors }) => {
  const song = pianobar.song;

  return (
    <Item
      text={song || "音楽を始める..."}
      hide={!pianobar.on}
      bg={colors.Black}
    />
  );
};

export default Pianobar;
