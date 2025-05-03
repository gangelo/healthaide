import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["componentForm", "showable"];

  show() {
    this.componentFormTarget.classList.toggle("hidden");
  }

  hide() {
    this.componentFormTarget.classList.toggle("hidden");
  }

  close() {
    this.element.remove();
  }
}
