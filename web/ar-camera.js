// Camera-based "view in your space" for Android: the phone camera fills the
// screen and the real-size model is drawn on top. Needs no ARCore/Google app,
// so it works on phones where Scene Viewer and WebXR fail. The model is held
// in place by the gyroscope (3DoF); it does not track walking.
import * as THREE from 'three';
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';

const $ = (id) => document.getElementById(id);
const params = new URLSearchParams(location.search);
const EYE = 1.4;                                  // phone height above floor (m)
const START_DIST = 2.6;                           // model distance at start (m)
const FOV = Number(params.get('fov')) || 63;      // ponytail: rear-camera vertical FOV; tune per phone with ?fov=

// ---------- model URL (own storage, own site, Google samples only) ----------
const src = params.get('src') || '/models/model_1770555635852_model.glb';
let srcOk = false;
try {
  srcOk = ['https://zsipfgtlfnfvmnrohtdo.supabase.co', 'https://modelviewer.dev', location.origin]
    .includes(new URL(src, location.href).origin);
} catch (_) {}
if (params.get('title')) $('title').textContent = params.get('title');
$('back').onclick = () => (history.length > 1 ? history.back() : (location.href = '/'));

function showMsg(title, text, retry) {
  $('msgT').textContent = title; $('msgP').textContent = text;
  $('msgB').style.display = retry ? '' : 'none'; $('msgB').onclick = retry;
  $('msg').style.display = 'grid';
}

// ---------- camera ----------
const video = $('cam');
async function startCamera() {
  $('msg').style.display = 'none';
  try {
    video.srcObject = await navigator.mediaDevices.getUserMedia({
      audio: false,
      video: { facingMode: { ideal: 'environment' }, width: { ideal: 1920 }, height: { ideal: 1080 } },
    });
    await video.play();
  } catch (e) {
    showMsg('Camera needed', 'Allow camera access to see the product in your space. If you blocked it, tap the lock icon in the address bar → Permissions → Camera.', startCamera);
  }
}

// ---------- 3D scene ----------
const renderer = new THREE.WebGLRenderer({ canvas: $('gl'), alpha: true, antialias: true });
renderer.setPixelRatio(Math.min(devicePixelRatio, 2));
renderer.outputColorSpace = THREE.SRGBColorSpace;
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;

const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(FOV, 1, 0.05, 100);
camera.position.set(0, EYE, 0);
camera.rotation.set(THREE.MathUtils.degToRad(-22), 0, 0, 'YXZ'); // until the gyroscope reports

scene.add(new THREE.HemisphereLight(0xffffff, 0x8a8a8a, 2.2));
const sun = new THREE.DirectionalLight(0xffffff, 1.6);
sun.position.set(1.5, 4, 2);
sun.castShadow = true;
sun.shadow.mapSize.set(1024, 1024);
Object.assign(sun.shadow.camera, { left: -2, right: 2, top: 2, bottom: -2, near: 0.5, far: 10 });
scene.add(sun, sun.target);

const floor = new THREE.Mesh(new THREE.PlaneGeometry(20, 20), new THREE.ShadowMaterial({ opacity: 0.32 }));
floor.rotation.x = -Math.PI / 2;
floor.receiveShadow = true;
scene.add(floor);

const holder = new THREE.Group(); // positioned on the floor; the model sits inside with its base at y=0
holder.position.set(0, 0, -START_DIST);
scene.add(holder);

function resize() {
  renderer.setSize(innerWidth, innerHeight, false);
  camera.aspect = innerWidth / innerHeight;
  camera.updateProjectionMatrix();
}
addEventListener('resize', resize);
resize();

if (!srcOk) {
  $('loading').textContent = 'This product has no 3D model.';
} else {
  new GLTFLoader().load(new URL(src, location.href).href, (gltf) => {
    const model = gltf.scene;
    model.traverse((o) => { if (o.isMesh) { o.castShadow = true; } });
    const box = new THREE.Box3().setFromObject(model);
    const c = box.getCenter(new THREE.Vector3());
    model.position.set(-c.x, -box.min.y, -c.z); // centre on x/z, base on the floor
    holder.add(model);
    $('loading').style.display = 'none';
  }, (p) => {
    if (p.total) $('loading').textContent = `Loading 3D model… ${Math.round((p.loaded / p.total) * 100)}%`;
  }, () => {
    $('loading').textContent = 'The 3D model could not load. Check your connection and reload.';
  });
}

// ---------- gyroscope: keep the model fixed in the room while the phone turns ----------
let yaw0 = null;
const qScreen = new THREE.Quaternion(-Math.sqrt(0.5), 0, 0, Math.sqrt(0.5)); // camera looks out the back
const zAxis = new THREE.Vector3(0, 0, 1);
const euler = new THREE.Euler();
const qTmp = new THREE.Quaternion();
addEventListener('deviceorientation', (e) => {
  if (e.alpha == null) return;
  if (yaw0 === null) yaw0 = e.alpha; // the direction the phone faces at start = straight ahead
  const d = THREE.MathUtils.degToRad;
  const orient = d((screen.orientation && screen.orientation.angle) || 0);
  euler.set(d(e.beta), d(e.alpha - yaw0), -d(e.gamma), 'YXZ');
  camera.quaternion.setFromEuler(euler).multiply(qScreen).multiply(qTmp.setFromAxisAngle(zAxis, -orient));
});

export { THREE, $, renderer, scene, camera, holder, video, startCamera, showMsg, START_DIST };
import('./ar-camera-ui.js');
startCamera();
