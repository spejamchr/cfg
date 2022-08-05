import { styled } from "uebersicht";

export default (colors) =>
  styled.div({
    height: "100%",
    width: "100%",
    boxSizing: "border-box",
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    whiteSpace: "nowrap",
    padding: "0px 5px",
    color: colors.White,
  });
