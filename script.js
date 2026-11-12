'use strict';
const sections = Array.from(document.querySelectorAll('.entity'));
const nav = document.querySelector('#table-nav');
const links = new Map();
sections.forEach(section => {
  const a = document.createElement('a');
  a.href = '#' + section.id;
  a.textContent = section.dataset.table;
  nav.append(a);
  links.set(section, a);
});
const normalize = text => text.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().trim();
document.querySelector('#search').addEventListener('input', event => {
  const query = normalize(event.target.value);
  let tableCount = 0;
  let columnCount = 0;
  sections.forEach(section => {
    const tableMatch = normalize(section.dataset.table).includes(query);
    let visible = 0;
    section.querySelectorAll('tbody tr').forEach(row => {
      row.hidden = !(tableMatch || normalize(row.dataset.column).includes(query));
      if (!row.hidden) visible++;
    });
    section.hidden = visible === 0;
    links.get(section).hidden = section.hidden;
    if (visible) { tableCount++; columnCount += visible; }
  });
  document.querySelector('#result-count').textContent = `${tableCount} ${tableCount === 1 ? 'tabela' : 'tabelas'} · ${columnCount} ${columnCount === 1 ? 'atributo' : 'atributos'}`;
  document.querySelector('#empty').hidden = tableCount > 0;
});
const theme = document.querySelector('#theme');
function setTheme(dark) {
  document.body.classList.toggle('dark', dark);
  theme.setAttribute('aria-pressed', String(dark));
  theme.textContent = dark ? 'Tema claro' : 'Tema escuro';
}
let savedTheme = null;
try { savedTheme = localStorage.getItem('dolly-theme'); } catch (error) { savedTheme = null; }
setTheme(savedTheme ? savedTheme === 'dark' : window.matchMedia('(prefers-color-scheme: dark)').matches);
theme.addEventListener('click', () => {
  const dark = !document.body.classList.contains('dark');
  setTheme(dark);
  try { localStorage.setItem('dolly-theme', dark ? 'dark' : 'light'); } catch (error) { /* Tema funciona sem persistência quando o armazenamento está indisponível. */ }
});
const navToggle = document.querySelector('#nav-toggle');
navToggle.addEventListener('click', () => {
  const opened = document.querySelector('#navigation').classList.toggle('open');
  navToggle.setAttribute('aria-expanded', String(opened));
});
nav.addEventListener('click', event => {
  const anchor = event.target.closest('a');
  if (!anchor) return;
  nav.querySelectorAll('a').forEach(a => a.classList.remove('active'));
  event.target.closest('a').classList.add('active');
  if (window.matchMedia('(max-width: 900px)').matches) {
    document.querySelector('#navigation').classList.remove('open');
    navToggle.setAttribute('aria-expanded', 'false');
    const target = document.getElementById(anchor.hash.slice(1));
    if (target) { target.tabIndex = -1; target.focus({ preventScroll: true }); }
  }
});
const dialog = document.querySelector('#der-modal');
const viewport = document.querySelector('#viewport');
const image = document.querySelector('#der-image');
let scale = 1;
let fitScale = 1;
let imageReady = image.complete && image.naturalWidth > 0;
let x = 0;
let y = 0;
let drag = null;
function draw() { image.style.transform = `translate(${x}px, ${y}px) scale(${scale})`; }
function reset() {
  if (!image.naturalWidth || !viewport.clientWidth) return;
  fitScale = Math.min((viewport.clientWidth - 24) / image.naturalWidth, (viewport.clientHeight - 24) / image.naturalHeight);
  scale = fitScale;
  x = (viewport.clientWidth - image.naturalWidth * scale) / 2;
  y = (viewport.clientHeight - image.naturalHeight * scale) / 2;
  draw();
}
function zoom(factor, anchorX = viewport.clientWidth / 2, anchorY = viewport.clientHeight / 2) {
  if (!imageReady || !Number.isFinite(scale) || scale <= 0) return;
  const next = Math.min(Math.max(scale * factor, fitScale * 0.25), Math.max(5, fitScale * 12));
  x = anchorX - (anchorX - x) * next / scale;
  y = anchorY - (anchorY - y) * next / scale;
  scale = next;
  draw();
}
document.querySelector('#open-der').addEventListener('click', () => {
  dialog.showModal();
  document.body.style.overflow = 'hidden';
  requestAnimationFrame(() => { reset(); viewport.focus(); });
});
document.querySelector('#close-der').addEventListener('click', () => dialog.close());
dialog.addEventListener('close', () => {
  document.body.style.overflow = '';
  drag = null;
  viewport.classList.remove('dragging');
  document.querySelector('#open-der').focus();
});
image.addEventListener('load', () => { imageReady = true; if (dialog.open) reset(); });
image.addEventListener('error', () => { imageReady = false; document.querySelector('#der-help').textContent = 'Não foi possível carregar assets/der.png. Confira o nome e o caminho do arquivo; a alternativa textual está disponível abaixo.'; });
document.querySelector('#zoom-in').addEventListener('click', () => zoom(1.25));
document.querySelector('#zoom-out').addEventListener('click', () => zoom(0.8));
document.querySelector('#zoom-reset').addEventListener('click', reset);
viewport.addEventListener('wheel', event => {
  event.preventDefault();
  const rect = viewport.getBoundingClientRect();
  zoom(Math.exp(-event.deltaY * 0.0015), event.clientX - rect.left, event.clientY - rect.top);
}, { passive: false });
viewport.addEventListener('pointerdown', event => {
  if (event.button !== 0 || drag || !imageReady) return;
  drag = { id: event.pointerId, startX: event.clientX, startY: event.clientY, x, y };
  viewport.setPointerCapture(event.pointerId);
  viewport.classList.add('dragging');
});
viewport.addEventListener('pointermove', event => {
  if (!drag || event.pointerId !== drag.id) return;
  x = drag.x + event.clientX - drag.startX;
  y = drag.y + event.clientY - drag.startY;
  draw();
});
function endDrag(event) {
  if (drag && event.pointerId === drag.id) {
    drag = null;
    viewport.classList.remove('dragging');
  }
}
viewport.addEventListener('pointerup', endDrag);
viewport.addEventListener('pointercancel', endDrag);
viewport.addEventListener('lostpointercapture', endDrag);
viewport.addEventListener('keydown', event => {
  const keys = ['+', '=', '-', '0', 'ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown'];
  if (!keys.includes(event.key)) return;
  event.preventDefault();
  if (event.key === '+' || event.key === '=') zoom(1.25);
  else if (event.key === '-') zoom(0.8);
  else if (event.key === '0') reset();
  else {
    if (event.key === 'ArrowLeft') x -= 50;
    if (event.key === 'ArrowRight') x += 50;
    if (event.key === 'ArrowUp') y -= 50;
    if (event.key === 'ArrowDown') y += 50;
    draw();
  }
});
window.addEventListener('resize', () => { if (dialog.open) reset(); });
