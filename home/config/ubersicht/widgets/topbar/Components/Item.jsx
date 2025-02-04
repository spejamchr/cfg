import { React, styled } from "uebersicht";

const HideOverflow = styled.span`
  overflow: hidden;
  white-space: nowrap;
  background-color: ${(props) => props.bg};
  padding: 0.5em;
  margin-left: 0.5em;
  margin-right: 0.25em;
  border-radius: 20px;
  align-content: center;
  text-overflow: ellipsis;
  height: 100%;
  color: ${(props) => props.color};
  &:before {
    content: "「 ";
  }
  &:after {
    content: " 」";
  }
`;

const Item = ({ text, hide, color, bg, style }) =>
  hide ? (
    ""
  ) : (
    <HideOverflow color={color} bg={bg} style={style}>
      {text}
    </HideOverflow>
  );

export default Item;
