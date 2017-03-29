export default function initFooterVisibleListener(js2elm) {

  let footerVisible = undefined;

  function scrollListener() {
    const footerTop = document.querySelector('.footer').getBoundingClientRect().top;
    const newFooterVisible = footerTop <= window.innerHeight;
    if (footerTop <= window.innerHeight &&
        newFooterVisible &&
        footerVisible !== newFooterVisible) {
      js2elm.send(true);
    }
    footerVisible = newFooterVisible;
  }

  window.addEventListener('scroll', scrollListener);
}
