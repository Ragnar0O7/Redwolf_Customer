// Touch controls, photo/video capture and the gallery for ar-camera.html.
import { THREE, $, renderer, scene, camera, holder, video, START_DIST } from './ar-camera.js';

// ---------- gestures: drag = move on floor, pinch = resize, twist = rotate ----------
const ray = new THREE.Raycaster();
const floorPlane = new THREE.Plane(new THREE.Vector3(0, 1, 0), 0);
const hit = new THREE.Vector3();
const touches = new Map();
let pinch0 = null;

function floorPoint(x, y) {
  ray.setFromCamera(new THREE.Vector2((x / innerWidth) * 2 - 1, -(y / innerHeight) * 2 + 1), camera);
  return ray.ray.intersectPlane(floorPlane, hit) && hit.distanceTo(camera.position) < 15 ? hit : null;
}
function setScale(s) {
  s = Math.min(3, Math.max(0.3, s));
  holder.scale.setScalar(s);
  $('scale').textContent = `${Math.round(s * 100)}%`;
}
function twoFinger() {
  const [a, b] = [...touches.values()];
  return { dist: Math.hypot(b.x - a.x, b.y - a.y), angle: Math.atan2(b.y - a.y, b.x - a.x) };
}
function hideHint() { $('hint').style.opacity = 0; }

const gl = $('gl');
gl.addEventListener('pointerdown', (e) => {
  touches.set(e.pointerId, { x: e.clientX, y: e.clientY });
  gl.setPointerCapture(e.pointerId);
  if (touches.size === 2) pinch0 = { ...twoFinger(), scale: holder.scale.x, rot: holder.rotation.y };
  hideHint();
});
gl.addEventListener('pointermove', (e) => {
  if (!touches.has(e.pointerId)) return;
  touches.set(e.pointerId, { x: e.clientX, y: e.clientY });
  if (touches.size === 1) {
    const p = floorPoint(e.clientX, e.clientY);
    if (p) holder.position.set(p.x, 0, p.z);
  } else if (touches.size === 2 && pinch0) {
    const now = twoFinger();
    setScale(pinch0.scale * (now.dist / pinch0.dist));
    holder.rotation.y = pinch0.rot - (now.angle - pinch0.angle);
  }
});
const lift = (e) => { touches.delete(e.pointerId); if (touches.size < 2) pinch0 = null; };
gl.addEventListener('pointerup', lift);
gl.addEventListener('pointercancel', lift);

$('scale').onclick = () => setScale(1); // back to real size
$('recenter').onclick = () => {
  // put the model on the floor straight ahead of where the phone points now
  const dir = new THREE.Vector3(0, 0, -1).applyQuaternion(camera.quaternion).setY(0).normalize();
  holder.position.copy(camera.position).addScaledVector(dir, START_DIST).setY(0);
};
setTimeout(hideHint, 6000);

// ---------- frame composer: camera image + 3D layer, as the user sees it ----------
const out = document.createElement('canvas');
const ctx = out.getContext('2d');
function compose() {
  const h = Math.min(1920, Math.round(innerHeight * devicePixelRatio));
  const w = Math.round(h * (innerWidth / innerHeight));
  if (out.width !== w || out.height !== h) { out.width = w; out.height = h; }
  const vw = video.videoWidth, vh = video.videoHeight;
  if (vw) { // same crop as object-fit: cover
    const s = Math.max(w / vw, h / vh);
    ctx.drawImage(video, (w - vw * s) / 2, (h - vh * s) / 2, vw * s, vh * s);
  } else { ctx.fillStyle = '#000'; ctx.fillRect(0, 0, w, h); }
  ctx.drawImage(renderer.domElement, 0, 0, w, h);
}

let recorder = null;
renderer.setAnimationLoop(() => {
  renderer.render(scene, camera);
  if (recorder) compose(); // must follow render in the same frame (no preserveDrawingBuffer)
});

// ---------- gallery (this session; Save/Share keep files on the phone) ----------
const items = [];
function addItem(blob, kind, thumb) {
  items.unshift({ blob, kind, url: URL.createObjectURL(blob), thumb, time: new Date() });
  $('thumb').style.backgroundImage = `url(${thumb})`;
  $('thumb').innerHTML = `<span>${items.length}</span>`;
}
const fileName = (it) => `redwolf-${it.time.toISOString().slice(0, 19).replace(/[:T]/g, '-')}.${it.kind === 'photo' ? 'jpg' : (it.blob.type.includes('mp4') ? 'mp4' : 'webm')}`;

function openGallery() {
  $('grid').innerHTML = items.length ? '' : '<p class="empty">Photos and videos you take appear here.</p>';
  items.forEach((it) => {
    const b = document.createElement('button');
    b.style.backgroundImage = `url(${it.thumb})`;
    if (it.kind === 'video') b.innerHTML = '<em>▶ video</em>';
    b.onclick = () => openViewer(it);
    $('grid').append(b);
  });
  $('gallery').style.display = 'flex';
}
function openViewer(it) {
  $('vTitle').textContent = it.kind === 'photo' ? 'Photo' : 'Video';
  $('vBody').innerHTML = it.kind === 'photo'
    ? `<img src="${it.url}" alt="Captured photo">`
    : `<video src="${it.url}" controls playsinline autoplay loop></video>`;
  $('vShare').onclick = async () => {
    const file = new File([it.blob], fileName(it), { type: it.blob.type });
    if (navigator.canShare && navigator.canShare({ files: [file] })) {
      try { await navigator.share({ files: [file], title: document.title }); } catch (_) {}
    } else { save(it); }
  };
  $('vSave').onclick = () => save(it);
  $('vDel').onclick = () => {
    items.splice(items.indexOf(it), 1);
    URL.revokeObjectURL(it.url);
    $('thumb').style.backgroundImage = items[0] ? `url(${items[0].thumb})` : '';
    $('thumb').innerHTML = items.length ? `<span>${items.length}</span>` : '';
    $('viewer').style.display = 'none';
    openGallery();
  };
  $('viewer').style.display = 'flex';
}
function save(it) {
  const a = document.createElement('a');
  a.href = it.url; a.download = fileName(it); a.click();
}
$('thumb').onclick = openGallery;
$('gClose').onclick = () => { $('gallery').style.display = 'none'; };
$('vClose').onclick = () => { $('viewer').style.display = 'none'; $('vBody').innerHTML = ''; };

// ---------- capture ----------
let mode = 'photo';
function setMode(m) {
  if (recorder) return;
  mode = m;
  $('mPhoto').classList.toggle('on', m === 'photo');
  $('mVideo').classList.toggle('on', m === 'video');
  $('shutter').classList.toggle('video', m === 'video');
  $('shutter').setAttribute('aria-label', m === 'photo' ? 'Take photo' : 'Start recording');
}
$('mPhoto').onclick = () => setMode('photo');
$('mVideo').onclick = () => setMode('video');

function takePhoto() {
  renderer.render(scene, camera);
  compose();
  const thumb = out.toDataURL('image/jpeg', 0.5);
  out.toBlob((blob) => blob && addItem(blob, 'photo', thumb), 'image/jpeg', 0.92);
  $('flash').style.opacity = 0.8;
  setTimeout(() => { $('flash').style.opacity = 0; }, 120);
}

let timerId = 0;
function startRecording() {
  if (!window.MediaRecorder || !out.captureStream) { alert('Video recording is not supported in this browser.'); return; }
  renderer.render(scene, camera);
  compose();
  const thumb = out.toDataURL('image/jpeg', 0.5);
  const type = ['video/mp4;codecs=avc1', 'video/mp4', 'video/webm;codecs=vp9', 'video/webm']
    .find((t) => MediaRecorder.isTypeSupported(t)) || '';
  const chunks = [];
  const rec = new MediaRecorder(out.captureStream(30), type ? { mimeType: type, videoBitsPerSecond: 6e6 } : {});
  rec.ondataavailable = (e) => e.data.size && chunks.push(e.data);
  rec.onstop = () => addItem(new Blob(chunks, { type: rec.mimeType || 'video/webm' }), 'video', thumb);
  rec.start(500);
  recorder = rec;
  const t0 = Date.now();
  $('shutter').classList.add('rec');
  $('shutter').setAttribute('aria-label', 'Stop recording');
  $('timer').style.display = 'block';
  const tick = () => {
    const s = Math.floor((Date.now() - t0) / 1000);
    $('timer').textContent = `● ${String(Math.floor(s / 60)).padStart(2, '0')}:${String(s % 60).padStart(2, '0')}`;
  };
  tick();
  timerId = setInterval(tick, 500);
}
function stopRecording() {
  recorder.stop();
  recorder = null;
  clearInterval(timerId);
  $('timer').style.display = 'none';
  $('shutter').classList.remove('rec');
  $('shutter').setAttribute('aria-label', 'Start recording');
}
$('shutter').onclick = () => {
  if (mode === 'photo') takePhoto();
  else if (recorder) stopRecording();
  else startRecording();
};
