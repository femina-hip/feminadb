class FeminaConfig
  def initialize
    @default = YAML::load_file(path('DEFAULT'))
    begin
      @env = YAML::load_file(path(RAILS_ENV))
    rescue Errno::ENOENT
      RAILS_DEFAULT_LOGGER.warn "Please create the configuration file '#{path(RAILS_ENV)}'."
      RAILS_DEFAULT_LOGGER.warn "Defaults will be used instead."
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
      "#{RAILS_ROOT}/config/feminadb.#{env}.yml"
    end
end
