/* global Elm */
import initAnimation from './animation';
import initScrolling from './scrolling';
import initGoogleAnalytics from './google-analytics';
import initImageUpload from './image-upload';
import initFooterVisibleListener from './footer-visible';
import initCloseMobileMenu from './mobile-menu';
import initShowAlerts from './show-alerts';

const app = Elm.Main.embed(document.getElementById('app'));

initAnimation(app.ports.animation);
initScrolling(app.ports.scrollTop);
initGoogleAnalytics(app.ports.sendGaPageView);
initImageUpload(app.ports.imageUpload, app.ports.imageSave);
initFooterVisibleListener(app.ports.footerAppeared);
initCloseMobileMenu(app.ports.closeMenu);
initShowAlerts(app.ports.showAlert);
