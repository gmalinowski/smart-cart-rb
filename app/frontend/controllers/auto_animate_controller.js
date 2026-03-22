import { Controller } from '@hotwired/stimulus';
import autoAnimate from '@formkit/auto-animate';
export default class extends Controller {
  connect() {
    autoAnimate(this.element);
  }
}