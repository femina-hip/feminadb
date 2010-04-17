class BulkOrderController < ApplicationController
  require_role 'edit-orders'

  def prepare
    @customers = customers(params)
    @creation_type = creation_type(params)
    @bulk_order = OpenStruct.new(params.dup)
    if @creation_type == :publication
      @from_publication = Publication.find(params[:from_publication_id])
    elsif @creation_type == :issue
      @from_issue = Issue.find(params[:from_issue_id])
    end
  end

  def run
    options = {}

    bulk_order_in = params[:bulk_order] || {}

    options[:issue_id] = bulk_order_in[:issue_id]
    options[:q] = bulk_order_in[:q]
    options[:from_issue_id] = bulk_order_in[:from_issue_id] if bulk_order_in[:from_issue_id]
    options[:from_publication_id] = bulk_order_in[:from_publication_id] if bulk_order_in[:from_publication_id]
    options[:num_copies] = bulk_order_in[:num_copies].to_i if bulk_order_in[:enable_num_copies] == 'true'
    options[:delivery_method_id] = bulk_order_in[:delivery_method_id] if bulk_order_in[:delivery_method_id].to_i > 0
    options[:comments] = bulk_order_in[:comments] unless bulk_order_in[:comments].to_s.strip.empty?
    options[:recipients] = [ current_user.email ]

    Rails.logger.info("Creating bulk orders with options: #{options.inspect}")

    validated = true
    if !options[:from_issue_id] && !options[:from_publication_id] && options[:num_copies].to_i <= 0
      flash[:notice] = 'Please enter a number of copies'
      validated = false
    end
    if options[:issue_id].to_i <= 0
      flash[:notice] = 'Please enter an Issue'
      validated = false
    end
    if options[:enable_num_copies] == 'true' and options[:num_copies].to_i <= 0
      flash[:notice] = 'Please enter a number of copies'
      validated = false
    end

    unless validated
      prepare
      render :action => :prepare
      return
    end

    if args[:from_issue_id]
      logger.info "Copying from past issue"
      BulkOrderCreator.new.send_later(:do_copy_from_issue, args)
    elsif args[:from_publication_id]
      logger.info "Copying from past publication"
      BulkOrderCreator.new.send_later(:do_copy_from_publication, args)
    else
      logger.info "Copying from customers query"
      BulkOrderCreator.new.send_later(:do_copy_from_customers, args)
    end

    redirect_to(publications_url)
  end

  private

  def creation_type(hash)
    if hash[:from_publication_id]
      :publication
    elsif hash[:from_issue_id]
      :issue
    else
      :customers
    end
  end

  def customers(hash)
    case creation_type(hash)
    when :publication then BulkOrderCreator.find_customers_from_publication_id(hash[:from_publication_id].to_i, hash[:q])
    when :issue then BulkOrderCreator.find_customers_from_issue_id(hash[:from_issue_id].to_i, hash[:q])
    when :customers then BulkOrderCreator.find_customers(hash[:q])
    end
  end
end
