import { React } from "uebersicht";
import Item from "./item.jsx";

const Pianobar = ({ pianobar }) => {
  const maxLength = 80;
  const song =
    pianobar.song.length > maxLength
      ? pianobar.song.substring(0, maxLength - 3) + "..."
      : pianobar.song;

  return <Item text={song || "Starting..."} hide={!pianobar.on} />;
};

export default Pianobar;
