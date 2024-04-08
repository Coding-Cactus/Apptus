self.addEventListener('push', e => {
    const notification = JSON.parse(e.data.text());

    e.waitUntil(
        clients.matchAll({ type: "window", includeUncontrolled: true })
            .then(clients => clients.every(client => !client.focused))
            .then(isNotFocused => {
                if (isNotFocused) {
                    self.registration.showNotification(
                        notification.title,
                        {
                            title: notification.title,
                            body: notification.body,
                            icon: notification.icon,
                            data: notification.data
                        }
                    );
                }
            })
    )
});

self.addEventListener("notificationclick", e => {
    e.notification.close();

    e.waitUntil(
        clients.matchAll({ type: "window", includeUncontrolled: true })
            .then(clientList => {
                for (const client of clientList) {
                    clients.claim();
                    client.focus();
                    if ("navigate" in client) client.navigate(e.notification.data.url);
                    return;
                }

                // Open new window if no clients are open
                clients.openWindow(e.notification.data.url);
            })
    );
});

self.addEventListener('pushsubscriptionchange', e => {
    e.waitUntil(
        fetch('/push_notifications/subscription-change', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                endpoint: e.newSubscription?.endpoint,
                p256dh:   e.newSubscription?.toJSON().keys.p256dh,
                auth:     e.newSubscription?.toJSON().keys.auth
            })
        })
    );
});
