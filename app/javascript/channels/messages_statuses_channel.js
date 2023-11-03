import consumer from "./consumer"

consumer.subscriptions.create("MessagesStatusesChannel", {
    received(data) {
        const READ_SVG = `<svg class="read" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="32" d="M464 128L240 384l-96-96M144 384l-96-96M368 128L232 284"/></svg>`
        const messages = document.querySelector("#messages")

        data.forEach(id => {
            let message = messages.querySelector(`.message[data-message-id='${id}'] .message-status`)
            if (message !== null) message.innerHTML = READ_SVG
        })
    }
})
