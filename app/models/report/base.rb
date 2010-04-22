class Report::Base
  # Returns an Array of Arrays.
  #
  # Each Array is a row of data. Each cell within that row is of the type
  # which is specified by columns.
  def data
    raise NotImplementedError
  end

  def id
    self.class.name.demodulize.underscore
  end

  alias_method :to_param, :id

  def params
    {}
  end

  # Returns a String for <h2>, etc.
  def subtitle
    ''
  end

  # Returns an Array of Hashes describing the "schema" of data's return
  # value.
  #
  # Each Hash must have the following keys:
  # - :key: A unique identifier for the column. This will be useful, for
  #         example, for making a <td class=":key">.
  # - :title: What to show in column headings
  # - :class: The class of the Objects in data's returned Arrays.
  def columns
    raise NotImplementedError
  end

  def show_map?
    false
  end

  class << self
    # Returns a String for <h1>, etc.
    def title
      raise NotImplementedError
    end

    # Returns an Array of Hashes describing parameters which must be
    # supplied to the constructor.
    #
    # Each hash must have the following keys:
    # - :title: The title of the parameter.
    # - :key: What to name the <form> input. ActiveRecord objects should
    #         have a key ending in '_id'.
    # - :class: The class of the parameter. ActiveRecord objects will be
    #           found using find automatically.
    def parameters
      []
    end

    def inherited(klass)
      super
    ensure
      (@all_reports ||= []) << klass
    end

    # Returns an Array of Strings for describing the Report.
    #
    # The Strings will explain how to read the data from the Report.
    def description
      []
    end

    # Returns a String describing how to render the Report as a graph.
    #
    # There must be a file at app/views/report_graphs/X.html.erb with the
    # actual rendering code.
    def graph_view
      'sidebar'
    end

    # Returns an Array of Report classes.
    #
    # To create a new Report, simply create its file in app/models/reports.
    #
    # The Reports returned will be sorted by title.
    def all_reports
      # Auto-load each report, so self.inherited() gets called
      Dir.glob(File.join(File.dirname(__FILE__), "*.rb")).each do |filename|
        base_name = File.basename(filename)[0..-4]
        Report.const_get base_name.classify
      end
      (@all_reports ||= []).sort{|a,b| a.title <=> b.title}
    end
  end
end
