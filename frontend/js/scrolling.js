import { polyfill } from 'smoothscroll-polyfill';
import 'scroll-restoration-polyfill';

polyfill();

const previousScrolls = {};
window.history.scrollRestoration = 'manual';

window.addEventListener('scroll', (e) => {
  const path = document.location.pathname
  previousScrolls[path] = window.scrollY;
});

export default function initScrolling(port) {
  port.subscribe(shouldScroll => {
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
