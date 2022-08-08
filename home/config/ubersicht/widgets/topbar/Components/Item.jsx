import { React, styled } from "uebersicht";

const HideOverflow = styled.span`
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
  color: ${(props) => props.color};
  &:before {
    content: "「 ";
  }
  &:after {
    content: " 」";
  }
`;

const Item = ({ text, hide, color }) =>
  hide ? "" : <HideOverflow color={color}>{text}</HideOverflow>;

export default Item;
