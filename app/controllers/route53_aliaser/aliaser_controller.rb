module Route53Aliaser
  class AliaserController < ActionController::Base
    def update
      if request.host == Route53Aliaser.config.target_record
        raise "Route53Updater: Update requested on URL of target_zone. Please make request via source_zone."
      end
      Route53Aliaser.update_alias_if_needed
      head :ok
    end
  end
end
