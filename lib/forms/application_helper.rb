module Forms::ApplicationHelper
  def region_field(object_name, method, options = {})
    collection_select(object_name, method, Region.order(:name), :id, :name, {:prompt => true}.merge(options))
  end

  def customer_type_field(object_name, method, options = {})
    collection_select(object_name, method, CustomerType.order(:name), :id, :full_name, {:prompt => true}.merge(options))
  end

  def date_field(object_name, method, options = {})
    text_field(object_name, "#{method}_string", forms_application_helper_add_class_to_options(options, 'date_field'))
  end

  def warehouse_field(object_name, method, options = {})
    select(object_name, method, Warehouse.order(:name).all.collect{|w| [w.name, w.id]}, options)
  end

  def delivery_method_field(object_name, method, options = {})
    collection_select(object_name, method, DeliveryMethod.order(:abbreviation), :id, :full_name, {:prompt => true}.merge(options))
  end

  # issue field
  #
  # Options:
  #  :conditions: extra conditions for search
  def issue_field(object_name, method, options = {})
    conditions = options.delete(:conditions) || {}

    opt_groups = IssueFieldOptGroups.new(:conditions => conditions)

    grouped_collection_select(object_name, method, opt_groups.groups, :issues, :label, :id, :full_name_for_issue_select, options, :class => 'issue_field')
  end

  private

  def forms_application_helper_add_class_to_options(options, klass)
    if options[:class]
      options.merge(:class => "#{options[:class]} #{klass}")
    elsif options['class']
      options.merge('class' => "#{options['class']} #{klass}")
    else
      options.merge(:class => klass)
    end
  end

  class IssueFieldOptGroups
    class IssueFieldOptGroup < Struct.new(:label, :issues)
    end

    def initialize(options)
      @options = options
    end

    def groups
      returning([]) do |ret|
        periodicals = issues.select{ |i| i.publication.tracks_standing_orders? }
        ret << IssueFieldOptGroup.new('Periodicals', periodicals) unless periodicals.empty?

        one_off = issues.select{ |i| p = i.publication; !p.tracks_standing_orders? && !p.pr_material? }
        ret << IssueFieldOptGroup.new('One-off publications', one_off) unless one_off.empty?

        advertising = issues.select{ |i| i.publication.pr_material? }
        ret << IssueFieldOptGroup.new('Advertising materials', advertising) unless advertising.empty?
      end
    end

    private

    def issues
      @issues ||= Issue.includes(:publication).where(@options[:conditions]).order('publications.tracks_standing_orders DESC, publications.pr_material, publications.name, issues.issue_date DESC').all
    end
  end
end
