import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
    static values = {
        url: String,
        checked: Boolean
    }
    checkedValueChanged() {
        const classes = [
            'order-last',
            'bg-gray-600!',
            'text-gray-200',
            'opacity-50',
            'py-0!',
            'scale-90',
        ]
        classes.forEach((c) => this.element.classList.toggle(c, this.checkedValue))
    }
    toggle(event) {
        if (event.target.closest('.dropdown')) return;
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