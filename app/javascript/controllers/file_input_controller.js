import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    updateLabel(e) {
        const container = e.target.parentNode
        const files = e.target.files

        if (files.length > 0) {
            let img = container.querySelector("img")

            if (!img) {
                img = document.createElement("img")
                img.alt = "Profile Picture"

                container.querySelector(".pfp").innerHTML = ""
                container.querySelector(".pfp").appendChild(img)
            }

            const fr = new FileReader()
            fr.onload = () => {
                img.src = fr.result
            }
            fr.readAsDataURL(files[0])
        }
    }
}
