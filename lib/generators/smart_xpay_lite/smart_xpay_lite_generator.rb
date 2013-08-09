class SmartXpayGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def generate_initializer
    copy_file "initialize_file.rb", "config/initializers/uplus_smart_xpay_lite.rb"
  end

  def generate_routes
    route <<-RUBY
  ## routes for uplus_smart_xpay
  namespace :uplus do
    post "s_xpay_lite/pay_req_cross_platform" => "smart_xpay_lite#pay_req_cross_platform"
    post "s_xpay_lite/pay_res" => "smart_xpay_lite#pay_res", as: 's_xpay_lite_pay_res'

    match 's_xpay_lite/cas_note_url' => 'smart_xpay_lite#cas_note_url', as: 's_xpay_lite_cas_note_url'
    post 's_xpay_lite/return_url' => 'smart_xpay_lite#return_url', as: 's_xpay_lite_return_url'

    post 's_xpay_lite/kvpmisp_note_url' => 'smart_xpay_lite#note_url', as: 's_xpay_lite_note_url'
    get 's_xpay_lite/kvpmisp_wap_url' => 'smart_xpay_lite#misp_wap_url', as: 's_xpay_lite_misp_wap_url'
    get 's_xpay_lite/kvpmisp_cancel_url' => 'smart_xpay_lite#cancel_url', as: 's_xpay_lite_cancel_url'
  end
RUBY
  end

  def generate_controller
    copy_file "smart_xpay_lite_controller.rb", "app/controllers/uplus/smart_xpay_lite_controller.rb"
  end

  def generate_views
    directory "views/uplus", "app/views/uplus"
  end
end
