class Modification
  VERSIONED_CLASSES = [
    CustomerType,
    Customer,
    District,
    IssueBoxSize,
    Issue,
    Publication,
    Region,
    Order,
    StandingOrder,
    WarehouseIssueBoxSize
  ]

  attr_reader :new_o
  attr_reader :o_id

  def initialize(o, start_time)
    @old_o = o
    @o_id = o.id
    @new_o = o.clone
    @start_time = start_time
  end

  def new_version_timestamp
    new_o.deleted_at ? new_o.deleted_at : new_o.updated_at
  end

  def old_version_timestamp
    old_o ? old_o.updated_at : nil
  end

  def old_o
    until @old_o.nil? or @old_o.updated_at.to_datetime <= @start_time.to_datetime
      if @old_o.version == 1
        @old_o = nil
        next
      end

      @old_o.revert_to(@old_o.version - 1)
    end
    @old_o
  end

  def attribute_changed?(attribute)
    return false if [ 'updated_at', 'updated_by', 'version' ].include? attribute.to_s
    old_o.nil? or (old_o.send(attribute) || '') != (new_o.send(attribute) || '')
  end

  def changed_attribute_names
    @changed_attribute_names ||= new_o.attribute_names.select {|a| attribute_changed? a}
  end

  def type
    if old_o
      if not new_o.deleted_at
        :modified
      else
        :deleted
      end
    else
      if not new_o.deleted_at
        :added
      else
        :modified
      end
    end
  end

  class << self
    def find_modifications(klass, start_time, limit = 100)
      r = []
      klass.find_with_deleted(
        :all,
        :conditions => [ 'updated_at > ? OR deleted_at > ?', start_time, start_time ],
        :order => 'IFNULL(deleted_at, updated_at) DESC',
        :limit => limit
      ).each do |o|
        m = Modification.new(o, start_time)
        r << m unless m.type == :modified and m.changed_attribute_names == ['version']
      end
      r
    end

    def find_all_modifications(start_time, limit = 100)
      r = []
      VERSIONED_CLASSES.each do |klass|
        find_modifications(klass, start_time, limit).each do |m|
          r << m
        end
      end

      return r

      r.sort!{|a,b| b.new_version_timestamp <=> a.new_version_timestamp}
      r.slice!(0..(limit-1)) if limit
      r
    end
  end
end
