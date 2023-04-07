import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input"]

    copy() {
        if (location.protocol === "https:") {
            navigator.clipboard.writeText(this.inputTarget.value).then(() => {
                alert("Contact number copied to clipboard.")
            }, (e) => {
                alert("There was a problem copying to the clipboard.")
                console.error('Could not copy text: ', e);
            })
        } else {
            alert("You must be on https to be able to copy.")
        }
    }
}
