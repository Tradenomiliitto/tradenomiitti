/* global Elm */
import 'babel-polyfill';

import initAnimation from './animation';
import { initScrollingToTop, initHomeScrolling } from './scrolling';
import initGoogleAnalytics from './google-analytics';
import initImageUpload from './image-upload';
import initFooterVisibleListener from './footer-visible';
import initCloseMobileMenu from './mobile-menu';
import initShowAlerts from './show-alerts';
import initTypeahead from './typeahead';
import translations from './translations';


const app = Elm.Main.embed(document.getElementById('app'), { translations });

initAnimation(app.ports.animation);
initScrollingToTop(app.ports.scrollTop);
initHomeScrolling(app.ports.scrollHomeBelowFold);
initGoogleAnalytics(app.ports.sendGaPageView);
initImageUpload(app.ports.imageUpload, app.ports.imageSave);
initFooterVisibleListener(app.ports.footerAppeared);
initCloseMobileMenu(app.ports.closeMenu);
initShowAlerts(app.ports.showAlert);
initTypeahead(app.ports.typeahead, app.ports.typeaheadResult);
