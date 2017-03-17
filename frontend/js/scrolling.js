import { polyfill } from 'smoothscroll-polyfill';

polyfill();

export default function initScrolling(port) {
  port.subscribe(shouldScroll => {
    if (shouldScroll) {
      window.scroll({
        top: 0,
        behavior: 'smooth'
      });
    }
  });
}
