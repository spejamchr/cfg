// Parse the output

/**
 * @param {string} name
 * @param {(params: {
 *  dateTime: { date: string, time: string },
 *  pianobar: { on: boolean, song: string },
 *  power: { plugged: boolean, battery: string },
 *  spaces: {}[],
 *  windows: {}[],
 *  displays: {}[],
 *  cpus: number,
 *  percentCpu: number,
 *  loadavg: string,
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
 * }) => JSX.Element} fn
 */
export default (name, fn) =>
  ({ error, output }) => {
    if (error !== undefined) {
      console.error(`[${name}]: `, error);
      return "";
    }

    if (output === "") {
      // First render, before the command has been run
      return "";
    }

    let parsed;
    try {
      parsed = JSON.parse(output);
    } catch (err) {
      console.error("[topbar]: ", err);
      console.log(output);
      return "Error Parsing JSON";
    }

    return fn(parsed);
  };
