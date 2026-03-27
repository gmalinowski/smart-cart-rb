import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
    static targets = ['selectAllBtn', 'itemBtn']

    connect() {
        this.determineSelectAllBtnState()
    }
    toggleAll() {
        this.itemBtnTargets.forEach((item) => item.checked = this.selectAllBtnTarget.checked)
    }

    toggleItem() {
        this.determineSelectAllBtnState()
    }

    determineSelectAllBtnState() {
        const everyChecked = this.itemBtnTargets.every((item) => item.checked)
        const someChecked = this.itemBtnTargets.some((item) => item.checked)
        this.selectAllBtnTarget.checked = everyChecked
        this.selectAllBtnTarget.indeterminate = someChecked && !everyChecked
    }

}