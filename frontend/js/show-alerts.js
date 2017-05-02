
const container = document.getElementById('error-messages');

export default function initShowAlerts(elm2js) {
  elm2js.subscribe(text => {
    const node = document.createElement('p');
    const textNode = document.createTextNode(text);
    node.appendChild(textNode);
    const cleanText = node.innerHTML;
    container.innerHTML += `
<div class="alert alert-danger" role="alert">
  <button type="button" class="close" data-dismiss="alert" aria-label="Close">
    <i class="fa fa-close" aria-hidden="true"></i>
  </button>
  <p>${cleanText}</p>
</div>
`;
    console.log(text);
  })
}
