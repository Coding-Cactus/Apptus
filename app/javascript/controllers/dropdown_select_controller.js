import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["dropdown", "selected", "hidden"]

    toggleOpen() {
        this.dropdownTarget.classList.toggle("open")

        if (this.dropdownTarget.classList.contains("open")) {
            const items = this.dropdownTarget.querySelectorAll("li")
            this.dropdownTarget.querySelector("ul").style.height = `${items[0].getBoundingClientRect().height * items.length}px`
        } else {
            this.dropdownTarget.querySelector("ul").style.height = ''
        }
    }

    selectOption(e) {
        this.dropdownTarget.querySelector("ul").style.height = ''
        this.dropdownTarget.classList.remove("open")

        const previous = this.selectedTarget
        const previousText = previous.innerText
        const previousId = previous.getAttribute("data-option-id")
        const previousIndex = previous.getAttribute("data-option-index")
        const previousClasses = previous.parentElement.className

        previous.innerText = e.target.innerText
        previous.parentElement.className = e.target.className
        previous.setAttribute("data-option-id", e.target.getAttribute("data-option-id"))
        previous.setAttribute("data-option-index", e.target.getAttribute("data-option-index"))

        this.hiddenTarget.value = previous.getAttribute("data-option-id")

        this.hiddenTarget.dispatchEvent(new Event('change'));

        setTimeout(() => {
            e.target.innerText = previousText
            e.target.className = previousClasses;
            e.target.setAttribute("data-option-id", previousId)
            e.target.setAttribute("data-option-index", previousIndex)

            const ul = e.target.parentElement

            Array.from(ul.children)
                .sort((a, b) => Number(a.getAttribute("data-option-index")) - Number(b.getAttribute("data-option-index")))
                .forEach(elem => ul.appendChild(elem));
        }, 300)
    }
}
