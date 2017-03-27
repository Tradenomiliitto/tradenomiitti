import Cropper from 'cropperjs';

export default function initImageUpload(elm2js, js2elm) {
  elm2js.subscribe(() => {
    const container = document.getElementById('image-upload');
    container.classList.add('image-upload--active')
    const imageInput =
          `<label for="image-input" class="image-upload__file-label btn btn-primary btn-lg">Lataa kuva</label>
      <input id="image-input" class="image-upload__file-input" type="file" onChange="imageUploadInit();"></input>` ;
    container.innerHTML = containerHtml(imageInput);


    window.imageUploadClose = () => {
      container.classList.remove('image-upload--active');
    };

    window.imageUploadInit = () => {
      const input = document.getElementById("image-input");
      const formData = new FormData();
      const url = '/api/profiilit/oma/kuva';
      formData.append("image", input.files[0]);
      const request = new XMLHttpRequest();
      request.onreadystatechange = () => {
        if (request.readyState === XMLHttpRequest.DONE) {
          const imgTag = `<img src="/static/images/${request.responseText}" id="image-editor-image" class="image-upload__img" />`;
          const editor = `<div>${imgTag}</div>`;
          container.innerHTML = containerHtml(editor);
          const imgElement = document.getElementById('image-editor-image')
          const cropper = new Cropper(imgElement, {
            aspectRatio: 1,
            zoomable: false,
            croppable: true,
            scalable: false,
            rotatable: false,
            crop: function(e) {
              console.log(e.detail.x);
              console.log(e.detail.y);
              console.log(e.detail.width);
              console.log(e.detail.height);
            }
          });
        }
      };
      request.open("PUT", url);
      request.send(formData);
    }
  })
}

function containerHtml(content) {
  return `
<div class="col-xs-12 col-sm-10 col-sm-offset-1 col-md-6 col-md-offset-3 image-upload__content">
<i class="image-upload__close-button fa fa-close fa-lg" onClick="imageUploadClose();"></i>
${content}
</div>
`

}
