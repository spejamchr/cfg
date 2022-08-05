import { styled } from "uebersicht";

export default (colors, width) =>
  styled.div({
    height: "100%",
    width: width,
    maxWidth: width,
    boxSizing: "border-box",
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    whiteSpace: "nowrap",
    padding: "0px 5px",
    color: colors.White,
    overflow: "hidden",
  });
