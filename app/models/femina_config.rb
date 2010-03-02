class FeminaConfig
  def initialize
    @default = YAML::load_file(path('DEFAULT'))
    begin
      @env = YAML::load_file(path(Rails.env))
    rescue Errno::ENOENT
      Rails.logger.warn "Please create the configuration file '#{path(RAILS_ENV)}'."
      Rails.logger.warn "Defaults will be used instead."
    end
  end

  def read(section, param)
    if @env and @env[section.to_s]
      @env[section.to_s][param.to_s] || @default[section.to_s][param.to_s]
    else
      @default[section.to_s][param.to_s]
    end
  end

  private
    def path(env)
      "#{Rails.root}/config/feminadb.#{env}.yml"
    end
end
