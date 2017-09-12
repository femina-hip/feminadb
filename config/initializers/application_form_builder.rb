ActionView::Base.class_eval do
  def self.default_form_builder
    ::ApplicationFormBuilder
  end
end
