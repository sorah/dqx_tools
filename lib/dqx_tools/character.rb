# coding: utf-8
require 'open-uri'
require 'nokogiri'
require_relative './equipments'
require_relative './parameter'

module DQXTools
  class Character
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

    attr_reader :url, :name, :message, :cid,
                :server, :field,
                :image, :equipments, :parameter, :skills,
                :support_message, :skill_point, :spells, :specials,
                :id, :species, :gender, :job, :level
    attr_accessor :detail

    def supportable?; !@support_message.nil?; end

    def inspect
      "#<#{self.class.name}:#{id} #{name} Lv#{level}>"
    end

    def update(detail=@detail)
      n = Nokogiri::HTML(open(@url))

      @id, @species, @gender, @job, @level = n.search("#myCharacterStatusList dd").map(&:inner_text)
      @id.gsub!(/^：/,'')
      @level = @level.to_i

      @name = n.at("#cttTitle").inner_text
      @message = n.at("div.message p").inner_text

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

      return self unless @detail

      n = Nokogiri::HTML(open(@status_url))

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
