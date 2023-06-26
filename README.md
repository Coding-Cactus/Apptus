# Apptus
https://apptus.online

Hosted on [Railway](https://railway.app/), runs on Ruby `3.2.1`, Rails 7, [Supabase](https://app.supabase.com/) for Postgres database, [MailerSend](https://app.mailersend.com/) for emails, [Mailcatcher](https://mailcatcher.me/) for development. Application performance monitoring sponsored by [AppSignal](https://www.appsignal.com/).

### Development Environment Variables
| Name                   | Value/Description                     |
|:-----------------------|:--------------------------------------|
| PGUSER                 | Username of your local postgres user  |
| PGPASSWORD             | Password of respective user           |
| APPTUS_EMAIL_HOST      | apptus.online                         |
| APPSIGNAL_PUSH_API_KEY | Secret AppSignal key                  |
| APP_REVISION           | Version of Apptus (major.minor.patch) |

### Production Environment Variables
| Name                     | Value/Description                     |
|:-------------------------|:--------------------------------------|
| RAILS_ENV                | production                            |
| RAILS_MASTER_KEY         | Secret key                            |
| RAILS_SERVE_STATIC_FILES | 1                                     |
| EMAIL_USERNAME           | SMTP username from MailerSend         |
| EMAIL_PASSWORD           | SMTP password from MailerSend         |
| DATABASE_URL             | Supabase database URL                 |
| APPTUS_HOST              | apptus.online                         |
| APPTUS_EMAIL_HOST        | apptus.online                         |
| REDIS_URL                | ${{Redis.REDIS_URL}} (Railway thing)  |
| APPSIGNAL_PUSH_API_KEY   | Secret AppSignal key                  |
| APP_REVISION             | Version of Apptus (major.minor.patch) |

### Running locally

#### Running the server
```shell
git clone 'https://github.com/Coding-Cactus/Apptus.git'
cd Apptus
bundle install

# Set dev ENV vars now, before next commends

rails db:setup
rails s
```

#### Running mailcatcher
```shell
mailcatcher
```

### Running tests
W.I.P

### Deploying
`main` is production. All changes should go through `dev` branch first.
