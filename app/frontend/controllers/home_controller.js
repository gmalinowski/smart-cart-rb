import { Controller } from '@hotwired/stimulus'
import autoAnimate from '@formkit/auto-animate'
export default class extends Controller {
    static targets = ['bannerContainer', 'banner', 'hint', 'form', 'form_container']
    connect() {
        autoAnimate(this.element)
        autoAnimate(this.bannerContainerTarget)
        this.bannerNode = this.bannerTarget.cloneNode(true)
        this.hintNode = this.hintTarget.cloneNode(true)
        this.hintNode.classList.remove('hidden')
    }

    hideBanner() {
        this.bannerContainerTarget.replaceChildren(this.hintNode)
    }
    showBanner() {
        this.bannerContainerTarget.replaceChildren(this.bannerNode)
    }

}