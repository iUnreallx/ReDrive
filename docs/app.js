(() => {
  const root = document.documentElement;
  const $$ = (s) => [...document.querySelectorAll(s)];
  const reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;
  const store = {
    get: (k) => { try { return localStorage.getItem(k); } catch (e) { return null; } },
    set: (k, v) => { try { localStorage.setItem(k, v); } catch (e) {} },
  };

  const TITLE = { en: 'ReDrive · your car, in numbers', ru: 'ReDrive · машина в цифрах' };
  const setLang = (l) => {
    root.dataset.lang = l; root.lang = l; document.title = TITLE[l];
    $$('[data-set]').forEach((b) => b.classList.toggle('on', b.dataset.set === l));
    store.set('rd-lang', l);
  };
  setLang(root.dataset.lang);
  $$('[data-set]').forEach((b) => b.addEventListener('click', () => setLang(b.dataset.set)));

  const nav = document.getElementById('nav');
  const onScroll = () => nav.classList.toggle('stuck', scrollY > 20);
  onScroll(); addEventListener('scroll', onScroll, { passive: true });

  const io = new IntersectionObserver((es) => es.forEach((e) => {
    if (!e.isIntersecting) return;
    e.target.classList.add('in'); io.unobserve(e.target);
  }), { rootMargin: '0px 0px -6% 0px' });
  $$('.reveal').forEach((el) => {
    const sibs = [...el.parentElement.children].filter((c) => c.classList.contains('reveal'));
    el.style.setProperty('--d', `${Math.min(sibs.indexOf(el), 4) * 0.07}s`);
    io.observe(el);
  });

  const MODES = {
    idle:    { rpm: 820,  speed: 0,   temp: 88, volt: 14.3, wob: 40 },
    city:    { rpm: 2300, speed: 48,  temp: 91, volt: 14.1, wob: 520 },
    highway: { rpm: 3100, speed: 112, temp: 93, volt: 14.0, wob: 180 },
    redline: { rpm: 7100, speed: 168, temp: 98, volt: 13.8, wob: 260 },
  };
  let mode = 'city';
  const cur = { ...MODES.city };
  const setMode = (m) => {
    mode = m;
    $$('[data-mode]').forEach((b) => {
      const on = b.dataset.mode === m;
      b.classList.toggle('on', on);
      b.setAttribute('aria-pressed', on ? 'true' : 'false');
    });
  };
  setMode(mode);

  const TOUR = [['city', 6], ['highway', 6], ['redline', 2.2], ['city', 5], ['idle', 3]];
  let tourAt = 0, tourTimer = 0, touring = !reduce;
  const tourNext = () => {
    if (!touring) return;
    tourAt = (tourAt + 1) % TOUR.length;
    setMode(TOUR[tourAt][0]);
    tourTimer = setTimeout(tourNext, TOUR[tourAt][1] * 1000);
  };
  if (touring) tourTimer = setTimeout(tourNext, TOUR[0][1] * 1000);
  $$('[data-mode]').forEach((b) => b.addEventListener('click', () => {
    touring = false; clearTimeout(tourTimer);
    setMode(b.dataset.mode);
  }));

  const fmt = (n) => Math.round(n).toLocaleString(root.lang === 'ru' ? 'ru-RU' : 'en-US');
  const spark = document.querySelector('[data-spark]'), sparkFill = document.querySelector('[data-spark-fill]');
  const loEl = document.querySelector('[data-lo]'), hiEl = document.querySelector('[data-hi]');
  const liveEls = $$('[data-live]');

  const wobble = (m, t) => m.wob * (Math.sin(t * 1.3) * .6 + Math.sin(t * 3.1) * .4);
  const history = [];
  for (let i = 59; i >= 0; i--) history.push(MODES.city.rpm + wobble(MODES.city, performance.now() / 1000 - i * .25));

  let tick = () => {
    const t = performance.now() / 1000, m = MODES[mode];
    const wob = wobble(m, t);
    for (const k of ['rpm', 'speed', 'temp', 'volt']) {
      const target = k === 'rpm' ? m.rpm + wob : k === 'speed' ? Math.max(0, m.speed + wob / 60) : m[k];
      cur[k] += (target - cur[k]) * (k === 'temp' ? .04 : .22);
    }
    liveEls.forEach((el) => {
      if (el._zone && el._zone.classList.contains('idle')) return;
      const k = el.dataset.live;
      const v = k === 'volt' ? cur.volt.toFixed(1) : fmt(cur[k]);
      if (el._v !== v) { el._v = v; el.textContent = v; }
    });

    history.push(cur.rpm);
    if (history.length > 60) history.shift();
    if (spark && !spark.closest('section').classList.contains('idle')) {

      let lo = Math.min(...history) - 300, hi = Math.max(...history) + 300;
      if (hi - lo < 1500) { const mid = (hi + lo) / 2; lo = mid - 750; hi = mid + 750; }
      lo = Math.max(0, lo);
      const step = 300 / 59;
      const y = (v) => (84 - (v - lo) / (hi - lo) * 76).toFixed(1);
      const pts = history.map((v, i) => `${(i * step).toFixed(1)},${y(v)}`);
      spark.setAttribute('d', 'M' + pts.join(' L'));
      sparkFill.setAttribute('d', 'M' + pts.join(' L') + ' L300,90 L0,90 Z');
      if (loEl) { loEl.textContent = fmt(lo); hiEl.textContent = fmt(hi); }
    }
    if (framesEl && !framesEl.closest('.frames').classList.contains('idle')) frameTick();
  };

  const framesEl = document.querySelector('[data-frames]');
  const hex = (n) => Math.max(0, Math.min(255, Math.round(n))).toString(16).toUpperCase().padStart(2, '0');
  const makeFrames = () => {
    const r = Math.round(cur.rpm * 4), s = Math.round(cur.speed), tc = Math.round(cur.temp);
    const vv = Math.round(cur.volt * 1000);
    const ru = root.lang === 'ru';
    return [
      ['010C', `41 0C ${hex(r >> 8)} ${hex(r & 255)}`, `${fmt(cur.rpm)} ${ru ? 'об/мин' : 'rpm'}`],
      ['010D', `41 0D ${hex(s)}`, `${s} ${ru ? 'км/ч' : 'km/h'}`],
      ['0105', `41 05 ${hex(tc + 40)}`, `${tc} °C`],
      ['0142', `41 42 ${hex(vv >> 8)} ${hex(vv & 255)}`, `${cur.volt.toFixed(2)} ${ru ? 'В' : 'V'}`],
      ['0111', `41 11 ${hex(20 * 2.55 + cur.rpm / 160)}`, `${Math.round(20 + cur.rpm / 410)} % ${ru ? 'дроссель' : 'throttle'}`],
    ];
  };
  let framesBuilt = false, lastFrames = 0;
  function frameTick() {
    if (!framesEl) return;
    const now = performance.now();
    if (framesBuilt && now - lastFrames < 1000) return;
    lastFrames = now;
    const list = makeFrames();
    const html = list.map(([q, a, m]) => `<span><i>${q}</i> → ${a} <em>= ${m}</em></span>`).join('');
    if (!framesBuilt) { framesEl.innerHTML = html + html; framesBuilt = true; return; }

    const spans = framesEl.children;
    for (let i = 0; i < spans.length; i++) {
      const [q, a, m] = list[i % list.length];
      spans[i].innerHTML = `<i>${q}</i> → ${a} <em>= ${m}</em>`;
    }
  }

  const zones = $$('.hero, .frames, main > section, .final');
  const visible = new Set();
  const zio = new IntersectionObserver((es) => es.forEach((e) => {
    e.target.classList.toggle('idle', !e.isIntersecting);
    if (e.isIntersecting) visible.add(e.target); else visible.delete(e.target);
  }), { rootMargin: '120px 0px' });
  zones.forEach((z) => { visible.add(z); zio.observe(z); });
  liveEls.forEach((el) => { el._zone = el.closest('.hero, .frames, main > section, .final'); });
  const tickRaw = tick;
  tick = () => {

    if (!visible.size) return;
    tickRaw();
  };

  tickRaw();
  let timer = 0;
  const run = () => { if (!timer && !reduce && !document.hidden) timer = setInterval(tick, 250); };
  const stop = () => { clearInterval(timer); timer = 0; };
  document.addEventListener('visibilitychange', () => (document.hidden ? stop() : run()));
  run();

  const track = document.querySelector('.road-track i'), nowStep = document.querySelector('.r.now');
  const placeTrack = () => {
    if (!track || !nowStep) return;
    const road = nowStep.parentElement.getBoundingClientRect(), r = nowStep.getBoundingClientRect();
    const vertical = matchMedia('(max-width: 1100px)').matches;
    if (vertical) { track.style.width = '100%'; track.style.height = `${r.top - road.top + 33}px`; }
    else { track.style.height = '100%'; track.style.width = `${r.left - road.left + 31}px`; }
  };
  placeTrack(); addEventListener('resize', placeTrack);

  $$('[data-switch] button:not(:disabled)').forEach((b) => b.addEventListener('click', () => {
    b.parentElement.querySelectorAll('button').forEach((x) => x.classList.toggle('on', x === b));
  }));

  const showStars = (n) => {
    if (typeof n !== 'number') return;
    $$('[data-stars]').forEach((el) => { el.textContent = n; });
    $$('[data-stars-wrap]').forEach((el) => { el.hidden = false; });
  };
  let cached = null;
  try { cached = JSON.parse(store.get('rd-gh') || 'null'); } catch (e) {}
  if (cached) showStars(cached.stars);
  if (!cached || Date.now() - cached.t > 864e5) {
    fetch('https://api.github.com/repos/iUnreallx/ReDrive')
      .then((r) => (r.ok ? r.json() : null))
      .then((r) => {
        if (!r) return;
        showStars(r.stargazers_count);
        store.set('rd-gh', JSON.stringify({ t: Date.now(), stars: r.stargazers_count }));
      })
      .catch(() => {});
  }

  $$('.faq details').forEach((d) => d.addEventListener('toggle', () => {
    if (d.open) $$('.faq details').forEach((o) => { if (o !== d) o.open = false; });
  }));
})();

(() => {
  const stage = document.querySelector('[data-callouts]');
  if (!stage) return;
  const pins = [...stage.querySelectorAll('.pin')];
  const tags = [...stage.querySelectorAll('[data-for]')];
  const lines = tags.map(() => { const l = document.createElement('i'); l.className = 'lead-line'; stage.append(l); return l; });
  const place = () => {
    const W = stage.clientWidth, H = stage.clientHeight;
    pins.forEach((p) => { const [x, y] = p.dataset.at.split(',').map(Number); p.style.left = x + '%'; p.style.top = y + '%'; });
    tags.forEach((t, i) => {
      if (getComputedStyle(t).display === 'none') { lines[i].style.display = 'none'; return; }
      lines[i].style.display = '';
      const [x, y] = t.dataset.place.split(',').map(Number);
      t.style.left = x + '%'; t.style.top = y + '%';
      const pin = pins[+t.dataset.for];
      const [px, py] = pin.dataset.at.split(',').map(Number);
      const tr = t.getBoundingClientRect(), sr = stage.getBoundingClientRect();

      const tx = (tr.left - sr.left) + (px / 100 * W > (tr.left - sr.left) + tr.width / 2 ? tr.width : 0);
      const ty = (tr.top - sr.top) + tr.height / 2;
      const ex = px / 100 * W, ey = py / 100 * H;
      const len = Math.hypot(ex - tx, ey - ty), ang = Math.atan2(ey - ty, ex - tx) * 180 / Math.PI;
      Object.assign(lines[i].style, { left: tx + 'px', top: ty + 'px', width: len + 'px', transform: `rotate(${ang}deg)` });
    });
  };
  place();
  addEventListener('resize', place);
  if (document.fonts) document.fonts.ready.then(place);
})();
