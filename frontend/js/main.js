/* global Elm */
import initAnimation from './animation';

const app = Elm.Main.fullscreen();

initAnimation(app.ports.animation)
