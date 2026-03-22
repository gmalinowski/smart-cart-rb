import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        itemEditing: Boolean
    }
    static outlets = ['shopping-list-item']
    lockAll(except) {
        this.shoppingListItemOutlets.forEach((item) => {
            if (item !== except) item.lock();
        })
        this.itemEditingValue = true;
    }
    unlockAll() {
        this.shoppingListItemOutlets.forEach((item) => item.unlock());
        this.itemEditingValue = false;
    }
}