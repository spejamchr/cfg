import { React } from "uebersicht";
import genRandColor from "../Utils/GenRandColor.jsx";
import prepare from "../Utils/Prepare.jsx";

export const refreshFrequency = 1000 * 60 * 60 * 24;

export const command = `./topbar/command`;

export const className = {
  top: 20,
  width: "100%",
  height: "100%"
};

const randPoints = () => {
  const width = 2560;
  const height = 1600;
  let points = [];
  const n = 100;
  let i = 0;
  while (i < n) {
    i += 1;
    points.push([
      Math.random() * width - width * 0.3,
      Math.random() * height - height * 0.3,
      Math.random() * width - width * 0.3,
      Math.random() * height - height * 0.3
    ]);
  }
  return points;
};

export const render = prepare("body", ({ colors }) => {
  const bodyStyle = {
    backgroundColor: colors.Black,
    height: "100%",
    width: "100%"
  };

  const randColor = genRandColor(colors);

  return (
    <div style={bodyStyle}>
      <svg width="100%" height="100%" xmlns="http://www.w3.org/2000/svg">
        {randPoints().map(([x1, y1, x2, y2]) => {
          const color = randColor();
          return (
            <g key={`${x1}${y1}${x2}${y2}`}>
              <circle
                cx={x1}
                cy={y1}
                r={Math.random() * 40 + 10}
                fill={color}
              />
              <circle
                cx={x2}
                cy={y2}
                r={Math.random() * 40 + 10}
                fill={color}
              />
              <line
                x1={x1}
                x2={x2}
                y1={y1}
                y2={y2}
                strokeWidth={4}
                stroke={color}
              />
            </g>
          );
        })}
      </svg>
    </div>
  );
});
