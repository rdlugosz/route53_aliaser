# Route53Aliaser

Simulate DNS ALIAS-record support for [apex
zones](https://devcenter.heroku.com/articles/apex-domains) (a.k.a. bare / naked / root
domains) via Amazon [Route 53](https://aws.amazon.com/route53/).

This is useful because Heroku doesn't support these so-called naked domains
and there are a limited number of DNS providers who support the [ALIAS
record](http://support.dnsimple.com/articles/alias-record/) type (which is
essentially a CNAME record set on the root domain, that typically must be an
A-Record).

This code will:

- Check to see if our cached lookup of the `source_record` has expired
    - if no, return immediately (noop)
    - if yes:
        - Lookup the A record for our `source_record` (e.g., CNAME to Heroku)
        - Lookup the A record for our `target_record` (probably the naked
          domain)
        - If the Target and Source addresses differ, update the `target_record`

## Installation

Add this line to your application's Gemfile:

    gem 'route53_aliaser'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install route53_aliaser

## Usage

Add an initializer that looks like this:

    # ./config/initializers/route53_aliaser.rb

    Route53Aliaser.configure do |config|
      config.target_record   = ENV['RT53_TARGET_RECORD'] #This is the one that is updated, i.e., your ALIAS
      config.source_record   = ENV['RT53_SOURCE_RECORD'] #This is what the ALIAS should be pointed to
      config.zone_id         = ENV['RT53_ZONE_ID']       #Amazon Hosted Zone ID

      # Only need to set these if you aren't already setting them for another AWS service
      # config.aws_access_key_id     = ENV['RT53_AWS_ACCESS_KEY_ID']
      # config.aws_secret_access_key = ENV['RT53_AWS_SECRET_ACCESS_KEY']
    end


Then, just call `Route53Aliaser.update_alias_if_needed` periodically.

Not sure what the best approach is for this yet, but here are a few ideas:

- Add a `cron` job executing a Rake task.
- Create a special controller action that you load every so often via a ping
  monitoring service. This controller action would act similar to a webhook in
  that it would just call `Route53Aliaser.update_alias_if_needed` and return a
  success code.
- Dropping `Thread.new { Route53Aliaser.update_alias_if_needed }` into a
  controller action  gets called relatively frequently (say, your home page).
  This is the #YOLO approach, but shouldn't be terribly harmful since: A) this
  is a very short-lived thread, and B) there are no real consequences if the
  thread were suddenly killed. Note that I would not recommend calling this in
  line (i.e., not in a separate thread) in a controller action since DNS
  lookups / AWS calls might be slow & will block the request to your page.

## Contributing

I'm using this against a limited number of configurations so patches are
*very* welcome!

1. Fork it ( https://github.com/[my-github-username]/route53_aliaser/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

### Todos

1. Add some tests! *(Yes, I feel dirty.)*
1. Extract the dependency on ActiveSupport. The only thing really in use is
   the caching mechanism.
1. Include support for other API-enabled DNS Hosts, e.g., Rackspace.

## Warranty

This software is provided “as is” and without any express or implied
warranties, including, without limitation, the implied warranties of
merchantability and fitness for a particular purpose.
