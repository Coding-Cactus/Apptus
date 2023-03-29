import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["container"]

    remove() {
        this.containerTarget.remove()
    }
}
