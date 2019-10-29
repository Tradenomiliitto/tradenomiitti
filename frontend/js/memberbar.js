/* global $ */
import { makeAnimation, allAnimationIdsToReinit } from './animation';
import getStyleValues from './style-values';

const { navbarHeight } = getStyleValues();

export default function initMemberbar() {
  if (window.XMLHttpRequest) {
    const memberbarRequest = new XMLHttpRequest();
    memberbarRequest.open('GET', 'https://www.tradenomi.fi/memberbar/memberbar.php');
    memberbarRequest.onreadystatechange = function readyStateChanged() {
      if (memberbarRequest.readyState === 4) {
        const parentNode = document.getElementById('tral-memberbar');
        const newNode = document.createElement('div');
        newNode.innerHTML = this.responseText;
        parentNode.insertBefore(newNode, parentNode.firstChild);
        const memberbarToggle = document.getElementById('memberbar__toggle');
        const memberbarList = document.getElementById('memberbar__list');

        memberbarToggle.addEventListener('click', () => {
          memberbarToggle.classList.toggle('memberbar__toggle--open');
          memberbarList.classList.toggle('memberbar__list--open');
        });
        const renderedHeight = $('#tral-memberbar').height();
        const style = document.createElement('style');
        style.type = 'text/css';
        let css = `
.navbar-fixed-top {
position: sticky;
position: -webkit-sticky;
}
.navbar {
margin-bottom: 0;
}
.profile__top-row {
position: sticky;
position: -webkit-sticky;
}
.app-content {
padding-top: 0;
}
.home__intro-canvas {
height: calc(100vh - ${renderedHeight + navbarHeight}px);
}
.home__intro-screen {
height: calc(100vh - ${renderedHeight + navbarHeight}px);
}
.home__introbox-check-more {
top: calc(100vh - ${renderedHeight}px);
}
.login-needed__animation {
height: calc(100vh - ${renderedHeight + navbarHeight}px);
}
.login-needed__container {
height: calc(100vh - ${renderedHeight + navbarHeight}px);
}
`;
        if (/MSIE \d|Trident.*rv:/.test(navigator.userAgent)) {
          css += `
#tral-memberbar {
position: fixed;
left: 0;
right: 0;
background: #fff;
z-index: 12000;
}
.navbar-fixed-top {
top: ${renderedHeight}px;
}
.home__intro-canvas {
top: 0;
}
.login-needed__animation {
top: 0;
}
.profile__top-row {
top: ${renderedHeight + navbarHeight}px;
}
#app {
padding-top: ${renderedHeight + navbarHeight}px;
}
.home__introbox-check-more {
top: calc(100vh - ${renderedHeight + navbarHeight}px);
}
`;
        }
        style.appendChild(document.createTextNode(css));
        document.head.appendChild(style);
        allAnimationIdsToReinit.forEach(id => makeAnimation([ id, false ]));
      }
    };
    memberbarRequest.send();
  }
}
