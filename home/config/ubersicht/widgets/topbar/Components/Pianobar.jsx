import { React } from "uebersicht";
import Item from "./item.jsx";

const Pianobar = ({ pianobar, colors }) => {
  const maxLength = 80;
  const song =
    pianobar.song.length > maxLength
      ? pianobar.song.substring(0, maxLength - 3) + "..."
      : pianobar.song;

  return <Item text={song || "音楽を始める..."} hide={!pianobar.on} bg={colors.Black} />;
};

export default Pianobar;
