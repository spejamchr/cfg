import { React } from "uebersicht";
import Item from "./item.jsx";

// Uebersicht needs this to be imported
React;

/**
 * @param {string} song
 */
const songDetails = (song, colors) => {
  if (!song) return "音楽を始めます...";

  const title = song.match("(^.*)\\[0m by \\[34m")[1];
  const by = song.match("\\[0m by \\[34m(.*)\\[0m on \\[4m")[1];
  const on = song.match("\\[0m on \\[4m([^\\[]*)")[1];
  const loveMatch = song.match(
    "\\[0m on \\[4m([^\\[]*)\\[0m\\[30m \\[31m(.*)\\[0m\\[0m$",
  );
  const loveIcon = loveMatch ? loveMatch[2] : null;

  return (
    <>
      <span style={{ color: colors.Green }}>{title}</span> by{" "}
      <span style={{ color: colors.Blue }}>{by}</span> on{" "}
      <span style={{ textDecoration: "underline" }}>{on}</span>
      <span style={{ color: colors.Red }}> {loveIcon}</span>
    </>
  );
};

/**
 * @param {{
 * pianobar: {song: string},
 * colors: {}
 * }} params
 */
const Pianobar = ({ pianobar, colors }) => {
  return (
    <Item
      text={songDetails(pianobar.song, colors)}
      hide={!pianobar.on}
      bg={colors.Black}
    />
  );
};

export default Pianobar;
