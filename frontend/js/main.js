/* global Elm */
import initAnimation from './animation';
import initScrolling from './scrolling';
import initGoogleAnalytics from './google-analytics';

const app = Elm.Main.fullscreen();

initAnimation(app.ports.animation);

initScrolling(app.ports.scrollTop);

initGoogleAnalytics(app.ports.sendGaPageView);
