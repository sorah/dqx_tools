# coding: utf-8
require 'open-uri'
require 'nokogiri'
require_relative './equipments'
require_relative './util'
require_relative './parameter'

module DQXTools
  class Character
    class UnauthorizedError < StandardError; end

    def initialize(cid_or_url, options={})
      case cid_or_url
      when Integer
        @cid = cid_or_url.to_s
      when /^\d+$/
        @cid = cid_or_url
      when %r|^http://hiroba.dqx.jp/sc/character/(\d+?)/?$|
        @cid = $1
      else
        raise ArgumentError, "seems cid_or_url is not cid or character page url"
      end

      @url = "http://hiroba.dqx.jp/sc/character/#{@cid}/"
      @status_url = "#{@url}status"
      @detail = options[:detail]
      @agent = options[:agent]
      update
    end

    attr_reader :url, :name, :message, :cid, :title,
                :server, :field, :employer_name,
                :image, :equipments, :parameter, :skills,
                :support_message, :skill_point, :spells, :specials,
                :id, :species, :gender, :job, :level, :charge, :team,
                :exp_by_support, :gold_by_support, :reputation_by_support,
                :required_exp, :gold
    attr_accessor :detail

    def supportable?; !@support_message.nil?; end
    def employer; @employer ? Character.new(@employer, agent: @agent) : nil; end

    def inspect
      "#<#{self.class.name}:#{id} #{name} Lv#{level}>"
    end

    def update(detail=@detail)
      n = Util.get_page(@url, agent: @agent)

      error = n.at(".error_common")
      if error && error.inner_text.include?("このページは非公開に設定されています。")
        raise UnauthorizedError, "can't see this character"
      end

      @id, @species, @gender, @job, @level, @required_exp, @gold, @charge = n.search("#myCharacterStatusList dd").map{|x| x.inner_text.gsub!(/^： ?/,'') }
      @level = @level.to_i
      @charge = @charge.to_i if @charge
      @charge = @required_exp.to_i if @required_exp
      @charge = @gold.to_i if @gold

      @team = n.at("#myTeamStatusList dd a").inner_text
      @team_id = n.at("#myTeamStatusList dd a")['href'].match(%r|/sc/team/(\d+)/top/?$|)[1]

      @name = n.at("#cttTitle").inner_text
      @message = n.at("div.message p").inner_text

      @title = n.at("p#myCharacterTitle").inner_text

      @server, @field = n.search("div.where dd").map(&:inner_text)
      @server = nil if @server == "--"

      @image = n.at("p.img_character img")['src']
      support = n.at("#welcomeFriend .radiusFrameStrong1 dd")
      if support
        @support = support.inner_text.gsub(/　+$/,'')
      else
        @support = nil
      end

      @equipments = Equipments.new(n.search("div.equipment table td").map(&:inner_text))

      employer = n.at("table#employer")
      if employer
        @employer = n.at("table#employer a")['href'].match(%r|/sc/character/(\d+)/?$|)[1]
        @employer_name = n.at("table#employer a").inner_text
      end
      @exp_by_support, @gold_by_support, @reputation_by_support = n.search(".support .value dd").map {|x| x.inner_text.gsub(/[^\d]/,'').to_i }

      return self unless @detail

      n = Util.get_page(@status_url, agent: @agent)

      @parameter = Parameter.new(n.search("div.parameter td").map(&:inner_text))
      @skill_points = Hash[n.search("div.skill tr").map{|x| [x.children[0].inner_text, x.children[2].inner_text.to_i] }]

      spells = n.search("div.spell td")
      @spells = spells.map(&:inner_text).map{|x| x.gsub(/[\r\n\t]/,'') }
      @spells = [] if @spells == ["---"]

      skills = n.search("div.skillEffect tr")
      if skills.to_s.start_with?("<td>---</td>")
        @skills = []
      else
        @skills = Hash[skills.map{|x| [x.at("th").inner_text, x.at("td").search("a").map{|s| s.children[0].inner_text }]}]
      end

      specials = n.search("div.specialSkill tr")
      if specials.to_s.start_with?("<tr>\n<td>---</td>")
        @specials = []
      else
        @specials = Hash[specials.map{|x| [x.at("th").inner_text, x.at("td").search("a").map{|s| s.children[0].inner_text }]}]
      end

      self
    end
  end
end
