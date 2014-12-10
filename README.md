# Route53Aliaser

Simulate DNS ALIAS-Record support for [apex
zones](https://devcenter.heroku.com/articles/apex-domains) (a.k.a. bare /
naked / root domains) via Amazon [Route 53](https://aws.amazon.com/route53/)
by looking for changes to the CNAME you'd like to point to and updating your
A-Record via the Route 53 APIs.

Just point your ping monitor at the engine URL and you're good to go! Your
A-Record will remain in sync with whatever CNAME you point it at.

This is useful because some providers (like Heroku) don't support these
so-called naked domains and there are a limited number of DNS providers who
support the [ALIAS record](http://support.dnsimple.com/articles/alias-record/)
type (which is essentially a fake CNAME record set on the root domain; fake
because you [cannot have a CNAME at the
apex](http://serverfault.com/questions/613829/why-cant-a-cname-record-be-used-at-the-apex-of-a-domain)).
Amazon Route 53 only supports ALIASes to a few specific types of records,
which doesn't solve the problem for Heroku users who require SSL.

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

#### With Rails

Add an initializer that looks like this:

    # ./config/initializers/route53_aliaser.rb

    Route53Aliaser.configure do |config|
      config.target_record   = ENV['RT53_TARGET_RECORD'] #This is the one that is updated, i.e., your ALIAS
      config.source_record   = ENV['RT53_SOURCE_RECORD'] #This is what the ALIAS should be pointed to
      config.zone_id         = ENV['RT53_ZONE_ID']       #Amazon Hosted Zone ID

      # Only need to set these if you aren't already setting them for another AWS service
      # NOTE: You'll need to use AWS IAM to add a Route 53 read/write Policy for the user/group
      # associated with these credentials!
      # config.aws_access_key_id     = ENV['RT53_AWS_ACCESS_KEY_ID']
      # config.aws_secret_access_key = ENV['RT53_AWS_SECRET_ACCESS_KEY']
    end

Next, mount the Rails Engine at a URL of your choosing:

    # ./config/routes.rb
    mount Route53Aliaser::Engine => '/route53-update'

Finally, set up something to request this URL occasionally:

    $ curl https://www.example.com/route53-update

    NOTE: This MUST be your CNAME, not the root! (for obvious reasons)

The easiest way to do this is to monitor that URL via a free service like
[Pingdom](http://www.pingdom.com/free) or [NewRelic](http://www.newrelic.com).
Since the DNS lookups are cached, most of the time requests to this URL will
return nearly instantly. Pingdom defaults to checking once per minute, which
should be within even the shortest TTLs. It appears that NewRelic checks
approximately once every [20
seconds](https://docs.newrelic.com/docs/alerts/alert-policies/downtime-alerts/availability-monitoring),
which is probably overkill but shouldn't really matter since we don't do
anything if the cache is fresh.

Heroku's [free scheduler](https://devcenter.heroku.com/articles/scheduler) has
an "every 10 minutes" option that could also be used for this. Just put the
curl command in there. Note that Heroku
[charges](https://devcenter.heroku.com/articles/usage-and-billing) dyno hours
for scheduled jobs; if you're worried about this then you may prefer to use
the "once an hour" option instead. The downside to this approach is that the
further you stretch out the update interval the more likely you are to end up
with an out of date A-Record.

Whatever you choose, be sure the URL you are pinging is the CNAME and *not*
your root domain! (Otherwise, how could this possibly work?) The code will
raise an error if you attempt to do this.

#### Without Rails

If you're not using Rails, or if you'd like to update ad-hoc, just call
`Route53Aliaser.update_alias_if_needed` periodically. You'll of course need to
do some initialization similar to what is shown above.

### Other Options

For now, hitting the engine URL is the best option. It should keep things up
to date with minimal load on your app (since it's basically a NOOP when the
cached lookups are fresh). Please open an issue with your suggestion if you
have a better idea. Here are a couple alternatives:

- Add a `cron` job executing a Rake task.
- Dropping `Thread.new { Route53Aliaser.update_alias_if_needed }` into a
  controller action that gets called relatively frequently (say, your home
  page).  This is the #YOLO approach, but shouldn't be terribly harmful since:
  A) this is a very short-lived thread, and B) there are no real consequences
  if the thread were suddenly killed. Note that calling this in line (i.e.,
  not in a separate thread) in a controller action is not recommended since
  DNS lookups / AWS calls might be slow & will block the request to your page.


### SSL vs non-SSL endpoints on Heroku

In testing, we've noticed that the Heroku SSL endpoints, which use Amazon
ELBs, tend to keep a fairly static set of IPs. However, the non-SSL routers
(e.g., `us-east-1-a.route.herokuapp.com`) tend to present a new IP address on
every DNS expiration. This isn't a problem per se; just something you should
be aware of if you think it's strange that your Rt 53 record is constantly
being updated. 

You can verify that your apps are not using the "legacy" routing system by
logging into your Heroku account and visiting
[https://legacy-routing.herokuapp.com](https://legacy-routing.herokuapp.com).


### Amazon IAM Policy for Route 53

The minimal IAM policy assigned to the user whose credentials are being used
with Route53Aliaser should look something like this:

    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "Stmt1418344622100",
          "Effect": "Allow",
          "Action": [
            "route53:ChangeResourceRecordSets"
          ],
          "Resource": [
            "arn:aws:route53:::hostedzone/ZQM9AEI9WXMW9"
          ]
        }
      ]
    }


## Contributing

So far, this is being used against a limited number of configurations so
patches are *very* welcome!

1. Fork it ( https://github.com/rdlugosz/route53_aliaser/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

### Todos

1. Add some tests
1. Extract the dependency on ActiveSupport. The only thing really in use is
   the caching mechanism.
1. Include support for other API-enabled DNS Hosts, e.g., Rackspace.

### Questions?

Feel free to use the issue tracker for questions/comments or hit me up on
Twitter [@lbwski](https://twitter.com/lbwski).
