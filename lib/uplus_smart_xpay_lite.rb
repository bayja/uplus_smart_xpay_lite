require "uplus_smart_xpay_lite/version"
require 'uplus_smart_xpay_lite/configuration'
require 'uplus_smart_xpay_lite/uplus_order'
require 'uplus_smart_xpay_lite/return'

module UplusSmartXpayLite
  def self.configure
    yield Configuration
  end

  def self.uplus_js_host
    # TODO: ssh 접속 처리 추가할 것!
    UplusSmartXpay.cst_platform == 'service' ? "http://xpay.uplus.co.kr" : "http://xpay.uplus.co.kr:7080"
  end

  def self.cst_platform
    Configuration.cst_platform
  end

  def self.cst_mid
    Configuration.cst_mid
  end

  def self.server_id
    Configuration.server_id
  end

  def self.lgd_mid
    Configuration.lgd_mid
  end

  def self.lgd_mertkey
    Configuration.lgd_mertkey
  end

  def self.time_out
    Configuration.time_out
  end

  def self.urls
    Configuration.urls
  end

  def self.mertkeys
    Configuration.mertkeys
  end

  def self.casnoteurl
    Configuration.casnoteurl
  end
end
