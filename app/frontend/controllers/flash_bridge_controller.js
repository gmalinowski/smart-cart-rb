import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
    static values = {
        messages: Array
    }

    connect() {
        const typeMap = {
            notice: 'success',
            success: 'success',
            alert: 'error',
            error: 'error',
            warning: 'warning',
            info: 'info'
        }

        const flashEl = document.getElementById('flash')
        Object.entries(this.messagesValue).forEach(([index, [type, message]]) => {
            flashEl.dispatchEvent(new CustomEvent('flash:add', {
                detail: {
                    type: typeMap[type],
                    message: message
                }
            }))
        })
    }

}