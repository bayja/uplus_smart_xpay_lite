#encoding: utf-8

module Uplus
  class SmartXpayLiteController < ApplicationController
    skip_before_filter :verify_authenticity_token, except: :pay_req_cross_platform
    layout false

    def pay_req_cross_platform
      @uplus_order = UplusSmartXpayLite::UplusOrder.new({
        lgd_buyer: "개똥이",
        lgd_productinfo: 'test 상품 304',
        lgd_amount: '3040',
        lgd_buyeremail: 'abc@mintshop.com',
        lgd_buyerid: '1234',
        lgd_oid: "test_oid_304",
        lgd_buyerip: '2.2.1.1',
        lgd_custom_firstpay: "SC0010", #신용카드
      })

      @pay_req_map = {
        "CST_PLATFORM" =>               UplusSmartXpayLite.cst_platform,
        'CST_MID' =>                    UplusSmartXpayLite.cst_mid,
        "CST_WINDOW_TYPE" =>            "submit",
        'LGD_MID' =>                    UplusSmartXpayLite.lgd_mid,
        'LGD_OID' =>                    @uplus_order.lgd_oid,
        'LGD_BUYER' =>                  @uplus_order.lgd_buyer,
        'LGD_PRODUCTINFO' =>            @uplus_order.lgd_productinfo,
        'LGD_AMOUNT' =>                 @uplus_order.lgd_amount,
        'LGD_BUYEREMAIL' =>             @uplus_order.lgd_buyeremail,
        'LGD_CUSTOM_SKIN' =>            "blue",
        'LGD_CUSTOM_PROCESSTYPE' =>     "ONETR",
        'LGD_TIMESTAMP' =>              @uplus_order.lgd_timestamp,
        'LGD_HASHDATA' =>               @uplus_order.lgd_hashdata,
        'LGD_RETURNURL' =>              uplus_s_xpay_lite_return_url_url,
        'LGD_VERSION' =>                "JSP_SmartXPay-lite_1.0",
        'LGD_CUSTOM_FIRSTPAY' =>        @uplus_order.lgd_custom_firstpay,
        'LGD_CUSTOM_ROLLBACK' =>        "Y",

        # 결제 결과 DB 처리
        "LGD_NOTEURL" =>                uplus_s_xpay_lite_note_url_url,

        # if LGD_KVPMISPAUTOAPPYN # 비동기 ISP
        'LGD_KVPMISPAUTOAPPYN' =>       "Y",
        'LGD_KVPMISPNOTEURL' =>         uplus_s_xpay_lite_note_url_url,
        'LGD_KVPMISPWAPURL' =>          uplus_s_xpay_lite_misp_wap_url_url("LGD_OID" => @uplus_order.lgd_oid),
        'LGD_KVPMISPCANCELURL' =>       uplus_s_xpay_lite_cancel_url_url,

        # if LGD_MTRANSFERAUTOAPPYN # 비동기 계좌이체
        "LGD_MTRANSFERAUTOAPPYN" => "Y",
        "LGD_MTRANSFERNOTEURL" =>       uplus_s_xpay_lite_note_url_url,
        "LGD_MTRANSFERWAPURL" =>        uplus_s_xpay_lite_misp_wap_url_url("LGD_OID" => @uplus_order.lgd_oid),
        "LGD_MTRANSFERCANCELURL" =>     uplus_s_xpay_lite_cancel_url_url,

        # 가상계좌(무통장) 결제연동
        "LGD_CASNOTEURL" =>             uplus_s_xpay_lite_cas_note_url_url,

        # return 처리용
        "LGD_RESPCODE" =>               "",
        "LGD_RESPMSG" =>                "",
        "LGD_TID" =>                    "",
        "LGD_PAYTYPE" =>                "",
        "LGD_PAYDATE" =>                "",
        "LGD_FINANCECODE" =>            "",
        "LGD_FINANCENAME" =>            "",
        "LGD_FINANCEAUTHNU" =>          "",
        "LGD_ACCOUNTNUM" =>             "",
        "LGD_NOTEURL_RESULT" =>         "",

        # encoding UTF-8
        'LGD_ENCODING' =>               "UTF-8",
        'LGD_ENCODING_RETURNURL' =>     "UTF-8",
        'LGD_ENCODING_NOTEURL' =>       "UTF-8",
      }

      session[:pay_req_map] = @pay_req_map
    end

    def note_url
      uplus_return = ::UplusSmartXpayLite::Return.new(UplusSmartXpayLite.lgd_mid, params)

      puts "HASH 검증: #{uplus_return.valid?}"
      puts "거래 성공 체크: #{uplus_return.succeed?}"
      puts "session data: #{session[:pay_req_map]}"

      # hash data 검증
      if !uplus_return.valid?
        # return 데이터 위변호 hash값 검증 실패
        return render text: "NOT OK"
      end

      if !uplus_return.succeed?
        # return 거래 실패 처리
        return render text: "NOT OK"
      end

      # uplus_return.parsed_resp 으로 결제 성공 처리
      render text: "OK"
    end

    def return_url
      uplus_return = ::UplusSmartXpayLite::Return.new(UplusSmartXpayLite.lgd_mid, params)
      if uplus_return.valid?
        @pay_req_map = session[:pay_req_map]
        @pay_req_map["LGD_RESPCODE"] = params["LGD_RESPCODE"]
        @pay_req_map["LGD_RESPMSG"] = params["LGD_RESPMSG"]
        @pay_req_map["LGD_TID"] = params["LGD_TID"]
        @pay_req_map["LGD_OID"] = params["LGD_OID"]
        @pay_req_map["LGD_PAYTYPE"] = params["LGD_PAYTYPE"]
        @pay_req_map["LGD_PAYDATE"] = params["LGD_PAYDATE"]
        @pay_req_map["LGD_FINANCECODE"] = params["LGD_FINANCECODE"]
        @pay_req_map["LGD_FINANCENAME"] = params["LGD_FINANCENAME"]
        @pay_req_map["LGD_FINANCEAUTHNUM"] = params["LGD_FINANCEAUTHNUM"]
        @pay_req_map["LGD_ACCOUNTNUM"] = params["LGD_ACCOUNTNUM"]
        @pay_req_map["LGD_BUYER"] = params["LGD_BUYER"]
        @pay_req_map["LGD_PRODUCTINFO"] = params["LGD_PRODUCTINFO"]
        @pay_req_map["LGD_AMOUNT"] = params["LGD_AMOUNT"]
        @pay_req_map["LGD_NOTEURL_RESULT"] = params["LGD_NOTEURL_RESULT"]
      else
        render text: uplus_return.lgd_respmsg
      end
    end

    def pay_res
      uplus_return = ::UplusSmartXpayLite::Return.new(UplusSmartXpayLite.lgd_mid, params)
      if uplus_return.succeed?
        # 성공 이후 처리
      else
        # 실패 이후 처리
      end
    end

    def cas_note_url
      # 무통장 할당, 입금 통보 결과처리 페이지
      uplus_return = ::UplusSmartXpayLite::Return.new(UplusSmartXpayLite.lgd_mid, params)

      if !uplus_return.valid?
        return # 데이터 위변호 hash값 검증 실패
      end

      if !uplus_return.succeed?
        return # 거래 실패 처리
      end

      case uplus_return.cas_flag
      when "R"
        # 가상계좌 할당 처리
      when "I"
        # 가상계좌 입금확인 처리
      when "C"
        # 가상계좌 입금취소 처리
      end
    end


    def misp_wap_url
    end

    def cancel_url
    end
  end
end