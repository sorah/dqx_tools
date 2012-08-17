# coding: utf-8
require 'mechanize'
require_relative './character'

module DQXTools
  # 1. GET  http://hiroba.dqx.jp/sc/login/ -> redirect
  # 2. GET  https://secure.square-enix.com/account/app/svc/login?cont=... -> form
  # 3. POST https://secure.square-enix.com/account/app _pr_confData_sqexid, passwd -> redirect
  # 4. GET  http://hiroba.dqx.jp/sc/public/welcome/ -> link
  # 5. GET  http://hiroba.dqx.jp/sc/login/characterselect/ -> form
  # 6. POST http://hiroba.dqx.jp/sc/login/characterexec cid = button a[rel]

  class Session
    class LoginError < StandardError; end
    class MaintenanceError < Exception; end

    def initialize(username, password, cid=nil)
      @username, @password, @cid = username, password, cid

      @agent = Mechanize.new
      @agent.user_agent_alias = 'Mac Safari'

      @logined = false
      login
    end

    attr_reader :agent, :username, :cid
    def logined?; @logined; end

    def inspect
      "#<DQXTools::Session: #{@username}#{@cid && " (#{@cid})"}#{@logined ? ' logined' : ''}>"
    end

    def character
      Character.new(@cid, agent: self.agent)
    end

    private

    def login
      login_page = @agent.get("http://hiroba.dqx.jp/sc/login/")
      raise MaintenanceError, "seems in the maintenance" if login_page.at(".mainte_img")
      logined = login_page.form_with(action: "/account/app") do |form|
        form['_pr_confData_sqexid'] = @username
        form['_pr_confData_passwd'] = @password
        form['_event'] = "Submit"
        cushion = form.submit
        break cushion.forms[0].submit
      end
      raise LoginError, "Failed to login (Authentication failed?)" if logined.uri.to_s == "https://secure.square-enix.com/account/app"

      characterselect = @agent.get("http://hiroba.dqx.jp/sc/login/characterselect/")
      raise LoginError, "Failed to login (No Character exists or failed to get session)" if characterselect.at(".imgnochara")

      characterselect.form_with(action: "/sc/login/characterexec") do |form|
        form['cid'] = (@cid ||= characterselect.at("a.button.submitBtn.charselect.centering")['rel'])
        form.submit
      end

      mypage = @agent.get("http://hiroba.dqx.jp/sc/home/")
      raise LoginError, "Failed to login... (can't show mypage)" unless /マイページ/ === mypage.title

      @logined = true
    end
  end
end

