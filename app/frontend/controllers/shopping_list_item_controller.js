import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
    static values = {
        url: String,
        checked: Boolean
    }
    static outlets = ['shopping-list']
    checkedValueChanged() {
        const classes = [
            'order-last',
            'bg-gray-600!',
            'text-gray-200',
            'opacity-80',
            'py-0!',
            'scale-90',
        ]
        classes.forEach((c) => this.element.classList.toggle(c, this.checkedValue))
    }

    connect() {
    }

    edit(event) {
        this.shoppingListOutlet.startItemEditing();
        console.log(event)
    }

    save(event) {
        const newValue = event.target.textContent.replace(/\r?\n|\r/g, "");
        event.target.textContent = newValue;
        setTimeout(() => {
            this.shoppingListOutlet.stopItemEditing();
        }, 300)
    }

    stopPropagation(event) {
        event.stopPropagation();
    }

    toggle(event) {
        if (this.shoppingListOutlet.itemEditingValue) return;
        event.target.blur();
        fetch(this.urlValue, {
            method: 'PATCH',
            headers: {
                'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
            }
        })
            .then(response => {
                if (!response.ok) {

                document.getElementById('flash').dispatchEvent(new CustomEvent('flash:add', {
                    detail: {
                        type: 'error',
                        message: 'Cannot communicate with server!'
                    }
                }))
                }
            })
            .catch(error => {
            console.error('Error:', error);
            document.getElementById('flash').dispatchEvent(new CustomEvent('flash:add', {
                detail: {
                    type: 'error',
                    message: 'Something went wrong!'
                }
            }))
        });
    }
}