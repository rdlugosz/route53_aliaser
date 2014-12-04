module Route53Aliaser
  class AliaserController < ActionController::Base
    def update
      Route53Aliaser.update_alias_if_needed
      head :ok
    end
  end
end
