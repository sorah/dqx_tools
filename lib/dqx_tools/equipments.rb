# coding: utf-8
require_relative './struct'

module DQXTools
  class Equipments < Struct
    attributes :right_hand, :left_hand, :head, :upper_body, :lower_body,
               :arms, :legs, :face_accessory, :neck_accessory,
               :finger_accessory, :other_accessory, :expert_item
    map {|k,v| v == "そうびなし" ? nil : v.gsub(/[\r\n\t]/,'') }
  end
end
