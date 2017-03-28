import { polyfill } from 'smoothscroll-polyfill';

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
    if (shouldScroll) {
      previousScrolls[path] = 0;
      window.scroll({
        top: 0,
        behavior: 'smooth'
      });
    } else {
      setTimeout(() => {
        window.scroll({
          top: previousScrolls[path]
        });
      }, 0)
    }
  });
}
