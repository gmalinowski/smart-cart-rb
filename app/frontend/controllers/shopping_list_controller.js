import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        itemEditing: Boolean
    }

    startItemEditing() {
        this.itemEditingValue = true;
    }

    stopItemEditing() {
        this.itemEditingValue = false;
    }

    connect() {
    }

    lockEditing(event) {
    }
}