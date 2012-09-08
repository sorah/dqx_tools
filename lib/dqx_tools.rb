require_relative "./dqx_tools/version"
require_relative "./dqx_tools/util"

module DQXTools
  class << self
    def status
      page = Util.get_page("http://hiroba.dqx.jp/sc/")
      return :maintenance if page.at("#serverStatusLabelMainte")
      return :running
    end

    def up?
      self.status == :running
    end
  end
end
