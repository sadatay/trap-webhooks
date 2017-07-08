# TrapWebhooks

## Caveat

This is just something I'm tinkering with and is not intended for any kind of public consumption as-is.  

## Description

Sinatra app to log incoming webhooks from various services.  This is based off of [TravisCI's webhook verification example](https://github.com/travis-ci/webhook-signature-verifier), but with some minor modifications.

- I'm now logging the complete payload out to console (and some other stuff)
- Although TravisCI webhooks are currently the only kind I'm trying to capture, I may have to do something similar with GitHub webhooks in the near future (and who-knows-what-else in the distant future).  Rather than have a bunch of service-specific repos laying around to capture webhooks, I made the Sinatra app modular and split the route definitions out into service-specific classes.
