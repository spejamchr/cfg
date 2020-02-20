const randSelection = array => () =>
  array[Math.floor(Math.random() * (array.length - 1))];

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
