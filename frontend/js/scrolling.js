import { polyfill } from 'smoothscroll-polyfill';
import 'scroll-restoration-polyfill';

import getStyleValues from './style-values';

polyfill();

const previousScrolls = {};
window.history.scrollRestoration = 'manual';

window.addEventListener('scroll', (e) => {
  const path = document.location.pathname
  previousScrolls[path] = window.scrollY;
});

export function initScrollingToTop(elm2js) {
  elm2js.subscribe(shouldScroll => {
    const path = document.location.pathname
    const previousScrollInPath = previousScrolls[path];
    if (shouldScroll) {
      previousScrolls[path] = 0;
      window.scroll({
        top: 0,
        behavior: 'smooth'
      });
    } else {
      setTimeout(() => {
        window.scroll({
          top: previousScrollInPath
        });
      }, 50)
    }
  });
}

export function initHomeScrolling(elm2js) {
  elm2js.subscribe(() => {
    const { navbarHeight } = getStyleValues();
    window.scroll({
      top: window.innerHeight - navbarHeight,
      behavior: 'smooth'
    });
  });
}
