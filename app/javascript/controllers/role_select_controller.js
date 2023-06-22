import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    update() {
        this.element.submit()
    }
}
