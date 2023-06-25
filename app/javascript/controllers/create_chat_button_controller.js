import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    click() {
        document.querySelector(".selected")?.classList.remove("selected")
        document.querySelector(".rounded-top")?.classList.remove("rounded-top")
        document.querySelector(".rounded-bottom")?.classList.remove("rounded-bottom")
    }
}
