import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
    static values = {
        toggleUrl: String,
        updateUrl: String,
        itemId: String,
        checked: Boolean
    }
    static targets = ['itemName']
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

    lock() {
        this.itemNameTarget.contentEditable = 'false'
    }
    unlock() {
        this.itemNameTarget.contentEditable = 'true'
    }

    startEditing() {
        this.shoppingListOutlet.lockAll(this);
    }

    stopEditing() {
        this.shoppingListOutlet.unlockAll();
    }

    edit(event){
        this.startEditing();
    }

    save(event) {
        let newValue = event.target.textContent.replace(/\r?\n|\r/g, "");
        if (newValue.length === 0) {
            newValue = 'No name';
            document.getElementById('flash').dispatchEvent(new CustomEvent('flash:add', {
                detail: {
                    type: 'warning',
                    message: 'Empty item name!'
                }
            }))
        }
        event.target.textContent = newValue;
        this.updateItem(newValue);
        setTimeout(() => {
            this.stopEditing();
        }, 300)
    }

    async updateItem(newValue) {
        const formData = new FormData();
        formData.append('shopping_list_item[name]', newValue);
        try {
            const response = await fetch(this.updateUrlValue, {
                method: 'PUT',
                headers: {
                    'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
                },
                body: formData
            });
            if (!response.ok) {
                throw new Error('Network response was not ok');
            } else {
                document.getElementById('flash').dispatchEvent(new CustomEvent('flash:add', {
                    detail: {
                        type: 'success',
                        message: 'Item updated successfully!'
                    }
                }))
            }
        } catch (error) {
            document.getElementById('flash').dispatchEvent(new CustomEvent('flash:add', {
                detail: {
                    type: 'error',
                    message: 'Something went wrong! Cannot communicate with server!'
                }
            }))
            console.error('Error:', error);
        }
    }

    stopPropagation(event) {
        event.stopPropagation();
    }

    toggle(event) {
        if (this.shoppingListOutlet.itemEditingValue) return;
        event.target.blur();
        fetch(this.toggleUrlValue, {
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