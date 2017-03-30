export default function initCloseMobileMenu(elm2js) {
  elm2js.subscribe(() => {
    $('#navigation').collapse('hide');
  })
}
