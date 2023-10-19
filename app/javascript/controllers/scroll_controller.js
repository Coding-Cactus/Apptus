import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["loadedMessagesAnchor"]
    lastLoad = 0;
    lastScroll = 0;
    blockScroll = false;
    previousHeight;

    connect() {
        scrollToBottom(this.element)

        this.element.addEventListener("turbo:frame-load", () => { scrollToBottom(this.element) })
    }

    infiniteScroll() {
        if (this.blockScroll) {
            if (Date.now() - this.lastScroll > 300) {
                this.blockScroll = false;
            } else {
                this.scrollToBeforeLoad();
            }
        } else {
            const link = document.querySelector("#scroll-link")
            if (Date.now() - this.lastLoad >= 1000 && link && this.element.scrollTop < 100) {
                this.previousHeight = this.element.scrollHeight

                link.click()
                link.remove()

                this.lastLoad = Date.now()
                this.blockScroll = true;
            }
        }

        this.lastScroll = Date.now()
    }

    wheelScroll() {
        this.blockScroll = false;
    }

    loadedMessagesAnnouncerTargetConnected() {
        this.lastScroll = Date.now()
        this.scrollToBeforeLoad()
    }

    scrollToBeforeLoad() {
        this.element.scrollTop = this.element.scrollHeight - this.previousHeight
    }
}

function scrollToBottom(elem) {
    elem.scrollTop = elem.scrollHeight
}
