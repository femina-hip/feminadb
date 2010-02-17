class ModificationsController < ApplicationController
  def index
    @start_time = if params.include? :start_time
      DateTime.parse(params[:start_time]).to_time
    else
      Time.now - 3.days
    end

    @modifications = Modification.find_all_modifications(@start_time)
  end

  def show
    @klass = Kernel.const_get(params[:klass])
    @object_id = params[:object_id].to_i
    @start_time = DateTime.parse(params[:start_time]).to_time

    o = @klass.send('find_with_deleted', @object_id)
    @modification = Modification.new(o, @start_time)

    render :action => "show_#{@modification.type.to_s}"
  end
end
