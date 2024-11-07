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
import { randSelection } from "../Utils/GenRandColor.jsx";
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

// Knowns for parabola f(x) = ax**2 + bx + c:
//
// [1] f(1) = 1         // It intersects the point (1, 1)
// [2] f(t) = st        // It starts where the line ends off
// [3] df(t)/dx = s     // It starts with the same slope as the line
//
// @param tp [0-1] Transition Point (from linear to quadratic)
// @param fl [0-1] Fraction of points in linear section
const genRandX = (tp, fl) => {
  const t = fl;
  const s = tp/fl;
  const denom = (t - 1)**2
  const a = (1 - s) / denom;
  const b = (s * t**2 + s - 2 * t) / denom;
  const c = -(s - 1) * t**2 / denom;

  return () => {
    const x = rand();
    if (x < t) {
      return x * s;
    } else {
      return a * x**2 + b * x + c;
    }
  };
}

const randX = () => genRandX(1/4, 1/2)() * 3/4;

const genSeeds = ({ minX, maxX, minY, maxY }, s = 1) => {
  const N = 1000;

  const SX = maxX - minX;
  const SY = maxY - minY;

  const seeds = [];
  while (seeds.length < N) {
    const l = randX();

    seeds.push({
      x: l * SX + minX,
      y: rand() * rand() * SY + minY,
      a: 0 + 0.5738 * s,
      l: [100, 100],
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

  const blColor = randSelection([
    colors.Red,
    colors.Magenta,
    colors.Yellow,
  ]);

  const brColor = randSelection([
    colors.BrightBlack,
    colors.Blue,
    colors.Green,
  ]);

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

          {genSeeds({ minX, maxX, minY, maxY }, -1).map((s) => (
            <line
              strokeWidth={(2 * (maxY - s.y)) / maxY}
              key={`1:${s.x},${s.y}`}
              x1={(s.x + s.l[0] * Math.cos(s.a))}
              y1={minY + maxY - (s.y + s.l[0] * Math.sin(s.a))}
              x2={(s.x + s.l[1] * Math.cos(s.a + Math.PI))}
              y2={minY + maxY - (s.y + s.l[1] * Math.sin(s.a + Math.PI))}
              stroke={blColor()}
            />
          ))}

          {genSeeds({ minX, maxX, minY, maxY }).map((s) => (
            <line
              strokeWidth={(2 * (maxY - s.y)) / maxY}
              key={`1:${s.x},${s.y}`}
              x1={minX + maxX - (s.x + s.l[0] * Math.cos(s.a))}
              y1={minY + maxY - (s.y + s.l[0] * Math.sin(s.a))}
              x2={minX + maxX - (s.x + s.l[1] * Math.cos(s.a + Math.PI))}
              y2={minY + maxY - (s.y + s.l[1] * Math.sin(s.a + Math.PI))}
              stroke={brColor()}
            />
          ))}

        </g>
      </svg>
    </div>
  );
});
