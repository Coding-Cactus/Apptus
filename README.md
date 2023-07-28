# Apptus
https://apptus.online

Hosted on [Railway](https://railway.app/), runs on Ruby `3.2.1`, Rails 7, [Supabase](https://app.supabase.com/) for Postgres database, [MailerSend](https://app.mailersend.com/) for emails, [Mailcatcher](https://mailcatcher.me/) for development. Application performance monitoring sponsored by [AppSignal](https://www.appsignal.com/).

### Development Environment Variables
| Name                   | Value/Description                    |
|:-----------------------|:-------------------------------------|
| PGUSER                 | Username of your local postgres user |
| PGPASSWORD             | Password of respective user          |
| APPTUS_EMAIL_HOST      | `apptus.online`                      |
| APPSIGNAL_PUSH_API_KEY | Secret AppSignal key                 |

### Test Environment Variables
| Name              | Value/Description                    |
|:------------------|:-------------------------------------|
| PGUSER            | Username of your local postgres user |
| PGPASSWORD        | Password of respective user          |
| APPTUS_EMAIL_HOST | `apptus.online`                      |
| RAILS_ENV         | `test`                               |


### Production Environment Variables
| Name                     | Value/Description                      |
|:-------------------------|:---------------------------------------|
| RAILS_ENV                | `production`                           |
| RAILS_MASTER_KEY         | Secret key                             |
| RAILS_SERVE_STATIC_FILES | `1`                                    |
| EMAIL_USERNAME           | SMTP username from MailerSend          |
| EMAIL_PASSWORD           | SMTP password from MailerSend          |
| DATABASE_URL             | Supabase database URL                  |
| APPTUS_HOST              | `apptus.online`                        |
| APPTUS_EMAIL_HOST        | `apptus.online`                        |
| REDIS_URL                | `${{Redis.REDIS_URL}}` (Railway thing) |
| APPSIGNAL_PUSH_API_KEY   | Secret AppSignal key                   |

### Contributing

#### Getting Started
Firstly, [fork this repo](https://github.com/Coding-Cactus/Apptus/fork) to your GitHub account.
```shell
# Replace `YOURUSERNAME` with your GitHub username
$ git clone 'https://github.com/YOURUSERNAME/Apptus.git'
$ cd Apptus

$ git checkout dev
# Replace `my-new-feature` with something more descriptive
$ git checkout -b my-new-feature

$ bundle install

# Set dev environment variables now, before next commands

# Set up database
$ rails db:setup

# Run the server (you may need to install mailcatcher first)
$ mailcatcher
$ rails s
```

### Running tests
Make sure all tests run with no errors or warnings before making a PR. Run these tests with the test environment variables listed above.

```shell
$ rails test
$ bundle exec bundler-audit --update
$ bundle exec brakeman -q -w2
$ bundle exec rubocop --parallel
```

### Deploying
[`main`](https://github.com/Coding-Cactus/Apptus/tree/main) is production. All changes should go through [`dev`](https://github.com/Coding-Cactus/Apptus/tree/dev) branch first (via a PR).
