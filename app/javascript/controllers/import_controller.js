import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["chooseImportFile", "importFile", "importFileForm"];

  connect() {
    console.log("ImportController connected");
    this.importFileTarget.disabled = true;
  }

  fileSelected(event) {
    console.log("File selected:", event.target.files[0]);
    if (event.target.files[0] === undefined) {
      this.importFileTarget.disabled = true;
    }

    const file = this.chooseImportFileTarget.files[0];

    if (file) {
      const form = this.chooseImportFileTarget.closest("form");

      if (form) {
        const formData = new FormData(form);

        this.chooseImportFileTarget.disabled = true;

        fetch(form.action, {
          method: form.method,
          body: formData,
          headers: {
            Accept: "text/vnd.turbo-stream.html",
            "X-Requested-With": "XMLHttpRequest",
            "X-CSRF-Token": this.csrfToken(),
          },
          credentials: "same-origin",
        })
          .then((response) =>
            response.ok ? response.text() : Promise.reject("Upload failed")
          )
          .then((html) => {
            Turbo.renderStreamMessage(html);
            this.importFileTarget.disabled = false;
          })
          .catch((error) => {
            console.error("Error:", error);
            const flashContainer = document.getElementById("flash_messages");
            if (flashContainer) {
              flashContainer.innerHTML = `<div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative" role="alert">
                <strong class="font-bold">Error!</strong>
                <span class="block sm:inline">There was a problem uploading your file.</span>
              </div>`;
            }
          })
          .finally(() => {
            this.chooseImportFileTarget.disabled = false;
          });
      }
    }
  }

  submitImportFileForm(event) {
    if (event) event.preventDefault();

    if (this.hasImportFileFormTarget) {
      if (confirm("Import the selected user?")) {
        this.importFileTarget.disabled = true;
        this.importFileFormTarget.requestSubmit();
      }
    } else {
      console.error("Import form target not found");
    }
  }

  csrfToken() {
    return document
      .querySelector('meta[name="csrf-token"]')
      .getAttribute("content");
  }
}
