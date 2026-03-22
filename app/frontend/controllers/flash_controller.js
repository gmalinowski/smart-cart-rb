import { Controller } from "@hotwired/stimulus"
import autoAnimate from '@formkit/auto-animate'

export default class extends Controller {
    static values = {
        duration: { type: Number, default: 8000 }
    }

    #timer = null
    #messagesBuffer = []


    connect() {
        autoAnimate(this.element)
        this.element.addEventListener('flash:add', this.add)
    }

    disconnect() {
        this.element.removeEventListener('flash:add', this.add)
    }

    close(event) {
        this.#nextFlash()
    }

    add = ({ detail: { message, type = 'info' } }) => {
        this.#messagesBuffer.push({ message, type })
        if (this.#messagesBuffer.length === 1) {
            this.#showNext()
        }
    }

    #nextFlash() {
        clearTimeout(this.#timer)
        this.element.lastElementChild.remove()
        this.#messagesBuffer.shift()
        this.#showNext()
    }

    #showNext() {
        if (this.#messagesBuffer.length === 0) return
        const { message, type } = this.#messagesBuffer[0]
        this.element.insertAdjacentHTML('beforeend', this.#alertTemplate(type, message))
        this.#timer = setTimeout(() => {
            this.#nextFlash()
        }, this.durationValue)
    }

    #alertTemplate(type, message) {
        switch (type) {
            case 'error':
                return `<div role="alert" class="alert alert-error">
                  <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 shrink-0 stroke-current" fill="none" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  <span>${message}</span>
                </div>`
            case 'warning':
                return `<div role="alert" class="alert alert-warning">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 shrink-0 stroke-current" fill="none" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                    </svg>
                  <span>${message}</span>
                </div>`
            case 'success':
                return `<div role="alert" class="alert alert-success">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 shrink-0 stroke-current" fill="none" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                  <span>${message}</span>
                </div>`
            default:
                return `<div role="alert" class="alert alert-info">
                      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="h-6 w-6 shrink-0 stroke-current">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                      </svg>
                  <span>${message}</span>
                </div>`


        }
    }
}