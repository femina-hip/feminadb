class CouncilsController < ApplicationController
  def by_region_json
    render(json: Region.all.map{|r| [ r.name, r.councils ]}.to_h)
  end
end
