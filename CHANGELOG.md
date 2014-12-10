# Route53Aliaser 0.0.4
- Add TXT record alongside A-Record indicating that this is an ALIAS (#4)
- Raise error if the Rails Engine is called with a `request.host` that matches
  the `target_record`. This avoids a chicken-and-egg problem.

# Route53Aliaser 0.0.3
- increase log verbosity on NOOP and Matches (helps to provide assurance that
  we're doing *something*)
- improve documentation

# Route53Aliaser 0.0.2
- add Rails Engine support
- use Rails.cache when Rails is defined

# Route53Aliaser 0.0.1
- initial release
