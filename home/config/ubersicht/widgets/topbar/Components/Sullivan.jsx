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

// Uebersicht needs this to be imported
React;

export const refreshFrequency = 1000 * 60;

export const command = `./topbar/command`;

export const className = {
  width: "100%",
  height: "100%",
  zIndex: 0,
};

const rand = Math.random;

// In Radians
const minAngle = -1.5707963268;
const maxAngle = -1.1;

const genSeeds = ({ minX, maxX, minY, maxY, n }) => {
  const SX = maxX - minX;
  const SY = maxY - minY;

  const seeds = [];
  while (seeds.length < n) {
    seeds.push({
      x: rand() * SX + minX,
      y: rand() * rand() * SY + minY,
      a: minAngle + rand() * (maxAngle - minAngle), // random angle in [-0.9, -1.2]
      l: [50, 50],
    });
  }

  return seeds;
};

export const render = prepare("sullivan", ({ displays, colors, power }) => {
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
  const minX = dfx;
  const maxX = dfw;
  const minY = dfy;
  const maxY = dfh;

  const color = (x) => {
    if (rand() < 0.05) {
      return sample([colors.White, colors.BrightBlack]);
    }
    const scaledX = -15 * ((x - minX) / (maxX - minX) - 0.5);
    const sigmoidX = 1 / (1 + Math.exp(scaledX));
    if (sigmoidX < rand()) {
      return sample([colors.Red, colors.Magenta, colors.Yellow]);
    } else {
      return sample([colors.Blue, colors.Green, colors.Cyan]);
    }
  };

  const n = power.plugged ? 5000 : 800;

  // Fall direction per drop: along the lower half of the line (angle a).
  // The shallower extreme (-0.9 rad) produces the largest leftward drift,
  // so use it to size the seed x-range extension that fills the bottom-right corner.
  const maxAbsDx2 = 2 * (Math.cos(0.9) / Math.sin(0.9)) * dfh;

  // In seconds
  const minDuration = 4;
  const maxDuration = 100;

  const seeds = genSeeds({ minX, maxX: maxX + maxAbsDx2, minY, maxY, n }).map(
    (s, i) => {
      const dx2 = 2 * (-Math.cos(s.a) / -Math.sin(s.a)) * dfh;
      // More angled drops are faster
      const dur =
        minDuration +
        (1 - (s.a - minAngle) / (maxAngle - minAngle)) *
          (maxDuration - minDuration);
      return {
        ...s,
        dx2,
        stroke: color(Math.max(minX, Math.min(maxX, s.x + dx2 / 2))),
        dur,
        delay: -(rand() * dur), // random phase so drops are spread out
        opacity: 1 - (dur * 0.8) / maxDuration, // 0.2–1.0 - slower drops are dimmer
        keyframeName: `rainFall${i}`,
      };
    },
  );

  // One keyframe block per drop since each has a unique angle (and thus dx2).
  const keyframes = seeds
    .map(
      (s) => `@keyframes ${s.keyframeName} {
      from { transform: translate(0px, ${-dfh}px); }
      to   { transform: translate(${s.dx2}px, ${dfh}px); }
    }`,
    )
    .join("\n");

  return (
    <div style={{ ...bodyStyle, position: "relative" }}>
      <svg
        viewBox={`${dfx} ${dfy} ${dfw} ${dfh}`}
        preserveAspectRatio="none"
        width="100%"
        height="100%"
        xmlns="http://www.w3.org/2000/svg"
      >
        <style>{keyframes}</style>
        <g strokeLinecap="round" fill="none">
          {seeds.map((s, i) => (
            <g
              key={i}
              style={{
                opacity: s.opacity,
                animation:
                  parseInt(power.battery) > 25 || power.plugged
                    ? `${s.keyframeName} ${s.dur}s ${s.delay}s linear infinite`
                    : "",
                willChange: power.plugged ? "transform" : "auto",
              }}
            >
              <line
                strokeWidth={(0.7 * (maxY - s.y)) / maxY + 1.3}
                x1={s.x + s.l[0] * Math.cos(s.a)}
                y1={s.y + s.l[0] * Math.sin(s.a)}
                x2={s.x + s.l[1] * Math.cos(s.a + Math.PI)}
                y2={s.y + s.l[1] * Math.sin(s.a + Math.PI)}
                stroke={s.stroke}
              />
            </g>
          ))}
        </g>
      </svg>
      <div
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          width: "100%",
          height: "100%",
          background: `linear-gradient(to bottom, transparent 0%, ${colors.Black} 100%)`,
          pointerEvents: "none",
        }}
      />
    </div>
  );
});
