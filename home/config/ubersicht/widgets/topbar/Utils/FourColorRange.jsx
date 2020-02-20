export default ({ min, med, max }) => (colors, rule) =>
  rule > min
    ? rule > med
      ? rule > max
        ? colors.Red
        : colors.Yellow
      : colors.Green
    : colors.Blue;
