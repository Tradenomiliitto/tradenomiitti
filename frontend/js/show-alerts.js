
const container = document.getElementById('error-messages');

export default function initShowAlerts(elm2js) {
  elm2js.subscribe(text => {
    container.innerHTML += `
<div class="alert alert-danger" role="alert">
  <button type="button" class="close" data-dismiss="alert" aria-label="Close">
    <i class="fa fa-close" aria-hidden="true"></i>
  </button>
  <p>${text}</p>
</div>
`;
    console.log(text);
  })
}
