const genRandColor = colors => () =>
  [
    colors.Red,
    colors.Blue,
    colors.Green,
    colors.Magenta,
    colors.Cyan,
    colors.Yellow,
    colors.BrightBlack,
    colors.White
  ][(Math.random() * 7).toFixed()];

export default genRandColor;
