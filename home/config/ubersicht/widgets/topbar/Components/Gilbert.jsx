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
import genRandColor from "../Utils/GenRandColor.jsx";
import prepare from "../Utils/Prepare.jsx";

export const refreshFrequency = 1000 * 60 * 60 * 24;

export const command = `./topbar/command`;

export const className = {
  top: 20,
  width: "100%",
  height: "100%"
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
  const N = 500;

  const SX = maxX - minX;
  const SY = maxY - minY;

  const seeds = [];
  while (seeds.length < N) {
    const y = rand() * rand() * SY + minY;
    seeds.push({
      x: rand() * SX + minX,
      y,
      // a: Math.PI * rand(),
      // a: rand() * 0.2 + 0.3 + (rand() > 0.5 ? 0 : Math.PI / 2),
      a:
        (0.2 * (rand() - 0.5) + (rand() > 0.5 ? -0.2 : 0.2)) *
        (y / maxY) ** 1.5,
      // a: (rand() - 0.5) * 0.5,
      // a: (rand() - 0.5) * 0.6 * (y / maxY),
      l: [SX * 10, SX * 10]
    });
  }

  const inters = [];
  for (let i = 0; i < N; i++) {
    for (let j = i + 1; j < N; j++) {
      const { intersects, ti, tj } = calcIntersection(seeds[i], seeds[j]);
      if (intersects) {
        inters.push({ i, j, ti, tj });
        inters.push({ i: j, j: i, ti: tj, tj: ti });
      }
    }
  }

  inters
    .sort((a, b) => Math.abs(a.ti) - Math.abs(b.ti))
    .forEach(({ i, j, ti, tj }) => {
      if (
        ti < seeds[i].l[0] &&
        ti > -seeds[i].l[1] &&
        tj < seeds[j].l[0] &&
        tj > -seeds[j].l[1] &&
        Math.abs(ti) > Math.abs(tj)
      ) {
        if (ti > 0) {
          seeds[i].l[0] = ti;
        } else {
          seeds[i].l[1] = -ti;
        }
      }
    });

  // Boundaries/page clipping
  seeds.forEach(s => {
    const top = minY; //- rand() * 10;
    const dirSeeds = [
      { x: minX, y: top, a: 0, l: [SX, 0] }, // top
      { x: minX, y: maxY, a: 0, l: [SX, 0] }, // bottom
      { x: minX, y: top, a: Math.PI / 2, l: [SY, 0] }, // left
      { x: maxX, y: top, a: Math.PI / 2, l: [SY, 0] } // right
    ];
    dirSeeds.forEach(dir => {
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

export const render = prepare("gilbert", ({ displays, colors }) => {
  const bodyStyle = {
    backgroundColor: colors.Black,
    height: "100%",
    width: "100%"
  };

  const display = displays[0];
  const border = 100;
  const minX = display.frame.x + border;
  const maxX = display.frame.w - border;
  const minY = display.frame.y + border * 2;
  const maxY = display.frame.h - border;

  const randColor = genRandColor(colors);
  const stars = [];
  const nStars = 400;
  for (let i = 0; i < nStars; i++) {
    stars.push(i);
  }

  const starChance = 1 - (1 / nStars) ** (1 / 7);

  return (
    <div style={bodyStyle}>
      <svg width="100%" height="100%" xmlns="http://www.w3.org/2000/svg">
        <g strokeWidth={2} strokeLinecap="round" fill="none">
          {stars.map(i => (
            <circle
              key={i}
              cx={minX + rand() * (maxX - minX)}
              cy={minX + rand() * (minY - minX)}
              r={rand() * rand() * 1.4 + 0.4}
              fill={
                rand() > starChance
                  ? rand() > starChance
                    ? rand() > starChance
                      ? rand() > starChance
                        ? rand() > starChance
                          ? rand() > starChance
                            ? rand() > starChance
                              ? colors.Cyan
                              : colors.Magenta
                            : colors.Red
                          : colors.Blue
                        : colors.BrightWhite
                      : colors.Yellow
                    : colors.BrightBlack
                  : colors.White
              }
            />
          ))}
          <line
            x1={minX}
            y1={minY}
            x2={maxX}
            y2={minY}
            stroke={colors.Yellow}
          />
          {genSeeds({ minX, maxX, minY, maxY }).map(s => (
            <line
              key={`${s.x},${s.y}`}
              x1={s.x + s.l[0] * Math.cos(s.a)}
              y1={s.y + s.l[0] * Math.sin(s.a)}
              x2={s.x + s.l[1] * Math.cos(s.a + Math.PI)}
              y2={s.y + s.l[1] * Math.sin(s.a + Math.PI)}
              stroke={randColor()}
            />
          ))}
          <line
            x1={0}
            y1={1}
            x2={display.frame.w}
            y2={1}
            stroke={colors.BrightBlack}
          />
        </g>
      </svg>
    </div>
  );
});
