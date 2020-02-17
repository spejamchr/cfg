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

const genSeeds = () => {
  const width = 1440;
  const height = 880;
  const overlap = 0.1;

  const SX = width * (1 + 2 * overlap);
  const SY = height * (1 + 2 * overlap);
  const N = 256;

  const seeds = [];
  while (seeds.length < N) {
    seeds.push({
      x: Math.random() * SX - width * overlap,
      y: Math.random() * SY - height * overlap,
      a: Math.PI * Math.random(),
      // a: Math.random() * 0.2 + 0.3 + (Math.random() > 0.5 ? 0 : Math.PI / 2),
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

  return seeds;
};

export const render = prepare("gilbert", ({ colors }) => {
  const bodyStyle = {
    backgroundColor: colors.Black,
    height: "100%",
    width: "100%"
  };

  const randColor = genRandColor(colors);

  return (
    <div style={bodyStyle}>
      <svg width="100%" height="100%" xmlns="http://www.w3.org/2000/svg">
        <g strokeWidth={2} strokeLinecap="round" fill="none">
          {genSeeds().map(s => (
            <line
              key={`${s.x},${s.y}`}
              x1={s.x + s.l[0] * Math.cos(s.a)}
              y1={s.y + s.l[0] * Math.sin(s.a)}
              x2={s.x + s.l[1] * Math.cos(s.a + Math.PI)}
              y2={s.y + s.l[1] * Math.sin(s.a + Math.PI)}
              stroke={randColor()}
            />
          ))}
          <line x1={0} y1={1} x2={2000} y2={1} stroke={colors.BrightBlack} />
        </g>
      </svg>
    </div>
  );
});
