import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
    static values =  { defaultTab: String }
    connect() {
        const saved = localStorage.getItem('folder_active_tab') || this.defaultTabValue;
        this.element.querySelector(`input[value="${saved}"]`).checked = true
    }
    change(event) {
        localStorage.setItem('folder_active_tab', event.target.value);
    }
}