import { Application } from "@hotwired/stimulus"
import Alpine from 'alpinejs'

window.Alpine = Alpine
Alpine.start()

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
