export default function initAnimation(port) {
  port.subscribe(id => {
    console.log(id);
  })
}
