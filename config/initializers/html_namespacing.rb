HtmlNamespacing::Plugin::Rails.install(
  :template_formats => [], # We're okay without $NS()...
  :javascript => true,
  :javascript_root => "#{Rails.root}/app/javascripts"
)
