# gmailer

Send email via Gmail.

## Initialize

```sh
$ bundle install --path vendor/bundle
```

## Set config

Write authentication info in `./config/secret.yml`.
An example of `./config/secret.yml` is shown below.

```yml
email: "YOUR_EMAIL_ADDRESS"
access_token: "YOUR_ACCESS_TOKEN"
```

## Commands

### bulk_send

Bulk send emails.

```sh
$ params=/file/path template=/file/path dry_run=0 bundle exec rake bulk_send
```

A params file includes subject, destination and other parameters using to create body of mail.
A template file is a template to create body of mail.
A params file must be yaml, and a template file must be erb.

## Test

```sh
$ bundle exec rspec
```

## Requirements
- ruby 2.5.0 (See .ruby-version)
