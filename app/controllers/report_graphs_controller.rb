class ReportGraphsController < ApplicationController
  layout nil

  # To make caching easier, add a line like this to config/routes.rb:
  # map.graph "graph/:action/:id/image.png", :controller => "graph"
  #
  # Then reference it with the named route:
  #   image_tag graph_url(:action => 'show', :id => 42)

  def show
    report_class = Report.const_get(params[:id].classify)

    args = report_class.parameters.collect do |parameter|
      if parameter[:class].ancestors.include? ActiveRecord::Base
        parameter[:class].find params[parameter[:class].name.foreign_key]
      elsif parameter[:class] == String
        params[parameter[:class].name.underscore]
      else
        raise NotImplementedError
      end
    end

    @report = report_class.new *args
    s = render_to_string :action => report_class.graph_view
    send_data(s, :disposition => 'inline', :type => 'image/png')
  end
end
