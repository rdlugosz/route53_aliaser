module Route53Aliaser
  class Route53Updater
    def self.update_target(target_zone, ips, zone_id)
      change = {
        action: "UPSERT",
        resource_record_set: {
          name: target_zone,
          type: "A",
          ttl: 60,
          resource_records: ips.collect{ |ip| { value: ip } },
        }
      }
      change_batch = {
        comment: "auto updated",
        changes: [change]
      }
      options = {
        hosted_zone_id: zone_id,
        change_batch: change_batch,
      }

      res = AWS::Route53.new.client.change_resource_record_sets(options)
      res && res.successful?
    end
  end
end
