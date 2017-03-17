/* global Elm */
import initAnimation from './animation';
import initScrolling from './scrolling';

const app = Elm.Main.fullscreen();

initAnimation(app.ports.animation);

initScrolling(app.ports.scrollTop);
