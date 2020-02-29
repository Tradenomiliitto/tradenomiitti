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
import initMemberbar from './memberbar';
import translations, { source } from './translations';

let profileRemoved = false;
if (document.location.search.indexOf('profile-removed') !== -1) {
  profileRemoved = true;
}

const app = Elm.Main.init({
  node: document.getElementById('app'),
  flags: { translations, timeZoneOffset: -new Date().getTimezoneOffset() },
});

initAnimation(app.ports.animation);
initScrollingToTop(app.ports.scrollTop);
initHomeScrolling(app.ports.scrollHomeBelowFold);
initGoogleAnalytics(app.ports.sendGaPageView);
initImageUpload(app.ports.imageUpload, app.ports.imageSave);
initFooterVisibleListener(app.ports.footerAppeared);
initCloseMobileMenu(app.ports.closeMenu);
initShowAlerts(app.ports.showAlert);
initTypeahead(app.ports.typeahead, app.ports.typeaheadResult);
initMemberbar();

if (profileRemoved) {
  var container = document.getElementById('error-messages');
  container.innerHTML += `
<div class="alert alert-success" role="alert">
  <button type="button" class="close" data-dismiss="alert" aria-label="Close">
    <i class="fa fa-close" aria-hidden="true"></i>
  </button>
  <p>${source.profile.removeProfile.success}</p>
</div>
`;
}
