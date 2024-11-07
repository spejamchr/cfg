export const sample = array =>
  array[Math.floor(Math.random() * array.length)];

export const randSelection = array => () => sample(array);

export default colors =>
  randSelection([
    colors.Red,
    colors.Blue,
    colors.Green,
    colors.Magenta,
    colors.Cyan,
    colors.Yellow,
    colors.BrightBlack,
    colors.White
  ]);
