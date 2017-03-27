/* global Elm */
import initAnimation from './animation';
import initScrolling from './scrolling';
import initImageUpload from './image-upload';

const app = Elm.Main.embed(document.getElementById('app'));

initAnimation(app.ports.animation);
initScrolling(app.ports.scrollTop);
initImageUpload(app.ports.imageUpload, app.ports.imageSave);
