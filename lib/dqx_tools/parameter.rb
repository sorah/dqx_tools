require_relative './struct'

module DQXTools
  class Parameter < Struct
    attributes :max_hp, :max_mp, :attack, :defense,
               :attack_mp, :recover_mp, :strength,
               :speed, :guard, :dexterity, :charisma,
               :fashion, :weight

    map &:to_i
  end
end
