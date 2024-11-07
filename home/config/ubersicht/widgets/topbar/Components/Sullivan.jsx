// Set a Desktop Background using Base16 colors
//
// Looks nicer with a clean desktop:
//
//   defaults write com.apple.finder CreateDesktop -bool FALSE;killall Finder
//
// If you need to re-enable the desktop at some point:
//
//   defaults delete com.apple.finder CreateDesktop;killall Finder
//
// (From https://github.com/blahsd/supernerd.widget#usage)

import { React } from "uebersicht";
import { sample } from "../Utils/GenRandColor.jsx";
import prepare from "../Utils/Prepare.jsx";

export const refreshFrequency = 1000 * 60 * 60 * 24;

export const command = `./topbar/command`;

export const className = {
  width: "100%",
  height: "100%",
  zIndex: 0,
};

const rand = Math.random;

const calcIntersection = (si, sj) => {
  const dxi = Math.cos(si.a);
  const dyi = Math.sin(si.a);
  const dxj = Math.cos(sj.a);
  const dyj = Math.sin(sj.a);
  const de = dxi * dyj - dyi * dxj;
  if (Math.abs(de) < 1e-8) {
    return { intersects: false };
  }

  const ti = (-si.x * dyj + sj.x * dyj + dxj * si.y - dxj * sj.y) / de;
  const tj = (dxi * si.y - dxi * sj.y - dyi * si.x + dyi * sj.x) / de;
  const intersects =
    ti < si.l[0] && ti > -si.l[1] && tj < sj.l[0] && tj > -sj.l[1];

  return { intersects, ti, tj };
};

const genSeeds = ({ minX, maxX, minY, maxY }) => {
  const N = 5000;

  const SX = maxX - minX;
  const SY = maxY - minY;

  const seeds = [];
  while (seeds.length < N) {
    seeds.push({
      x: rand() * SX + minX,
      y: rand() * rand() * SY + minY,
      a: -1.1,
      l: [50, 50],
    });
  }

  // Boundaries/page clipping
  seeds.forEach((s) => {
    const top = minY;
    const dirSeeds = [
      { x: minX, y: top, a: 0, l: [SX, 0] }, // top
      { x: minX, y: maxY, a: 0, l: [SX, 0] }, // bottom
      { x: minX, y: top, a: Math.PI / 2, l: [SY, 0] }, // left
      { x: maxX, y: top, a: Math.PI / 2, l: [SY, 0] }, // right
    ];
    dirSeeds.forEach((dir) => {
      const { intersects, ti } = calcIntersection(s, dir);
      if (intersects) {
        if (ti > 0) {
          s.l[0] = ti;
        } else {
          s.l[1] = -ti;
        }
      }
    });
  });

  return seeds;
};

export const render = prepare("sullivan", ({ displays, colors }) => {
  const bodyStyle = {
    backgroundColor: colors.Black,
    height: "100%",
    width: "100%",
  };

  // Try to use the frame provided by yabai, since it's exact, but otherwise
  // fall back to the frame on my 13" screen. The SVG will be scaled so it'll
  // look nice either way.
  const display = displays[0] || { frame: { x: 0, w: 1440, y: 0, h: 900 } };
  const { x: dfx, y: dfy, w: dfw, h: dfh } = display.frame;
  const border = 40;
  const minX = dfx;
  const maxX = dfw;
  const minY = dfy + border;
  const maxY = dfh;

  const color = (x) => {
    if (rand() < 0.05) {
      return sample([
        colors.White,
        colors.BrightBlack,
      ])
    }
    const scaledX = -15 * ((x - minX) / (maxX - minX) - 0.5);
    const sigmoidX = 1 / (1 + Math.exp(scaledX));
    if (sigmoidX < rand()) {
      return sample([
        colors.Red,
        colors.Magenta,
        colors.Yellow,
      ])
    } else {
      return sample([
        colors.Blue,
        colors.Green,
        colors.Cyan,
      ])
    }
  }

  return (
    <div style={bodyStyle}>
      <svg
        viewBox={`${dfx} ${dfy} ${dfw} ${dfh}`}
        preserveAspectRatio="none"
        width="100%"
        height="100%"
        xmlns="http://www.w3.org/2000/svg"
      >
        <g strokeWidth={2} strokeLinecap="round" fill="none">

          {genSeeds({ minX, maxX, minY, maxY }).map((s) => (
            <line
              strokeWidth={(0.7 * (maxY - s.y)) / maxY + 1.3}
              key={`${s.x},${s.y}`}
              x1={(s.x + s.l[0] * Math.cos(s.a))}
              y1={(s.y + s.l[0] * Math.sin(s.a))}
              x2={(s.x + s.l[1] * Math.cos(s.a + Math.PI))}
              y2={(s.y + s.l[1] * Math.sin(s.a + Math.PI))}
              stroke={color(s.x)}
            />
          ))}

        </g>
      </svg>
    </div>
  );
});
