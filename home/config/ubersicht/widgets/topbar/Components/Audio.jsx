import { React } from "uebersicht";
import Item from "./item.jsx";

// Uebersicht needs this to be imported
React;

/**
 * @param {{
 *  audio: {
 *  out: { name: string, type: string, id: string, uid: string },
 *  in: { name: string, type: string, id: string, uid: string },
 *  },
 *  colors: {
 *  Black: string,
 *  BrightBlack: string,
 *  White: string,
 *  BrightWhite: string,
 *  Red: string,
 *  Orange: string,
 *  Yellow: string,
 *  Green: string,
 *  Cyan: string,
 *  Blue: string,
 *  Magenta: string,
 *  Brown: string,
 *  }
 * }} params
 */
const Audio = ({ audio, colors }) => (
  <Item
    text={<span>󰋋</span>}
    hide={audio.out.uid === "BuiltInSpeakerDevice"}
    color={colors.Yellow}
    bg={colors.Black}
  />
);

export default Audio;
