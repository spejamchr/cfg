import { styled } from "uebersicht";

const sidePadding = 5; // px

export default colors =>
  styled.div({
    height: "100%",
    width: `calc(100% - ${sidePadding * 2}px)`,
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    whiteSpace: "nowrap",
    paddingLeft: `${sidePadding}px`,
    paddingRight: `${sidePadding}px`,
    backgroundColor: colors.Black,
    color: colors.White
  });
