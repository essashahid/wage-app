/*
 Generates a looping GIF (docs/gifs/stitching-3d.gif) of a stitching unit scene.
 Uses node-canvas + gifencoder. No external assets.
*/

const fs = require('fs');
const path = require('path');
const { createCanvas } = require('canvas');
const GIFEncoder = require('gifencoder');

const width = 960;
const height = 320;
const frames = 144; // 6s at 24 fps
const fps = 24;

const outDir = path.join(__dirname, '..', 'docs', 'gifs');
if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });
const outPath = path.join(outDir, 'stitching-3d.gif');

const encoder = new GIFEncoder(width, height);
encoder.createReadStream().pipe(fs.createWriteStream(outPath));
encoder.start();
encoder.setRepeat(0); // loop
encoder.setDelay(1000 / fps);
encoder.setQuality(10);

const canvas = createCanvas(width, height);
const ctx = canvas.getContext('2d');

function drawBackground(t) {
  // gradient background
  const grad = ctx.createLinearGradient(0, 0, width, height);
  grad.addColorStop(0, '#0F172A');
  grad.addColorStop(1, '#1E293B');
  ctx.fillStyle = grad;
  ctx.fillRect(0, 0, width, height);

  // flowing thread lines
  const lines = [0, 1];
  lines.forEach((i) => {
    ctx.beginPath();
    for (let x = 0; x <= width; x += 8) {
      const y = height * 0.76 + Math.sin((x * 0.02) + t * 2 + i) * 12 + i * 6;
      if (x === 0) ctx.moveTo(x, y);
      else ctx.lineTo(x, y);
    }
    ctx.strokeStyle = i === 0 ? '#6C63FF' : '#00C2FF';
    ctx.globalAlpha = i === 0 ? 0.9 : 0.6;
    ctx.lineWidth = 3;
    ctx.stroke();
    ctx.globalAlpha = 1.0;
  });
}

function drawStation(cx, cy, t, hueShift = 0) {
  // desk
  ctx.fillStyle = '#1F2937';
  roundRect(ctx, cx - 120, cy + 40, 240, 12, 6, true, false);

  // machine
  ctx.fillStyle = '#94A3B8';
  roundRect(ctx, cx - 40, cy, 120, 30, 6, true, false);
  roundRect(ctx, cx + 60, cy + 5, 14, 16, 3, true, false);
  ctx.fillStyle = '#CBD5E1';
  filledCircle(ctx, cx - 16, cy + 15, 6);

  // worker torso + head
  ctx.fillStyle = '#E2E8F0';
  filledCircle(ctx, cx + 110, cy - 8 + Math.sin(t * 2) * 2, 18); // head bob
  ctx.fillStyle = '#64748B';
  roundRect(ctx, cx + 92, cy + 10, 36, 26, 8, true, false); // torso

  // thread (bezier curve)
  const p0 = { x: cx + 10, y: cy + 10 };
  const p1 = { x: cx + 40, y: cy - 20 + Math.sin(t * 2 + hueShift) * 10 };
  const p2 = { x: cx + 80, y: cy + 6 };
  ctx.strokeStyle = lerpColor('#6C63FF', '#00C2FF', (Math.sin(t + hueShift) + 1) / 2);
  ctx.lineWidth = 2.5;
  ctx.beginPath();
  ctx.moveTo(p0.x, p0.y);
  ctx.quadraticCurveTo(p1.x, p1.y, p2.x, p2.y);
  ctx.stroke();
}

function roundRect(ctx, x, y, w, h, r, fill, stroke) {
  if (w < 2 * r) r = w / 2;
  if (h < 2 * r) r = h / 2;
  ctx.beginPath();
  ctx.moveTo(x + r, y);
  ctx.arcTo(x + w, y, x + w, y + h, r);
  ctx.arcTo(x + w, y + h, x, y + h, r);
  ctx.arcTo(x, y + h, x, y, r);
  ctx.arcTo(x, y, x + w, y, r);
  ctx.closePath();
  if (fill) ctx.fill();
  if (stroke) ctx.stroke();
}

function filledCircle(ctx, x, y, r) {
  ctx.beginPath();
  ctx.arc(x, y, r, 0, Math.PI * 2);
  ctx.fill();
}

function lerpColor(a, b, t) {
  const pa = parseInt(a.slice(1), 16);
  const pb = parseInt(b.slice(1), 16);
  const ar = (pa >> 16) & 0xff;
  const ag = (pa >> 8) & 0xff;
  const ab = pa & 0xff;
  const br = (pb >> 16) & 0xff;
  const bg = (pb >> 8) & 0xff;
  const bb = pb & 0xff;
  const rr = Math.round(ar + (br - ar) * t).toString(16).padStart(2, '0');
  const rg = Math.round(ag + (bg - ag) * t).toString(16).padStart(2, '0');
  const rb = Math.round(ab + (bb - ab) * t).toString(16).padStart(2, '0');
  return `#${rr}${rg}${rb}`;
}

for (let i = 0; i < frames; i++) {
  const t = i / fps; // seconds
  drawBackground(t);
  // three stations
  drawStation(width * 0.2, height * 0.45, t + 0.0, 0.0);
  drawStation(width * 0.5, height * 0.45, t + 0.4, 0.2);
  drawStation(width * 0.8, height * 0.45, t + 0.8, 0.4);
  encoder.addFrame(ctx);
}

encoder.finish();
console.log('GIF written to', outPath);


