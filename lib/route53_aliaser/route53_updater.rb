# AWS::Route53 API docs:
# http://docs.aws.amazon.com/AWSRubySDK/latest/AWS/Route53.html
module Route53Aliaser
  class Route53Updater
    attr_reader :config
    def initialize(config)
      @config = config
    end

    def update_target(target_record, ips, zone_id)
      change = {
        action: "UPSERT",
        resource_record_set: {
          name: target_record,
          type: "A",
          ttl: 60,
          resource_records: ips.collect{ |ip| { value: ip } }
        }
      }
      change_batch = {
        comment: "auto updated",
        changes: [change]
      }
      options = {
        hosted_zone_id: zone_id,
        change_batch: change_batch
      }

      rt53 = get_configured_aws_client

      res = rt53.client.change_resource_record_sets(options)

      res && res.successful?
    end

    private
    def get_configured_aws_client
      if(config.aws_access_key_id && config.aws_secret_access_key)
        AWS::Route53.new(access_key_id:     config.aws_access_key_id,
                         secret_access_key: config.aws_secret_access_key)
      else
        # Use the config set at the AWS module level (probably set for something else)
        AWS::Route53.new
      end
    end
  end
end
