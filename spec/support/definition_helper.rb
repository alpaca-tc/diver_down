# frozen_string_literal: true

module DefinitionHelper
  # fill default values
  def fill_default(hash)
    hash[:title] ||= ''
    hash[:definition_group] ||= nil
    hash[:sources] ||= []
    hash[:sources].each do |source|
      source[:dependencies] ||= []

      source[:dependencies].each do |dependency|
        dependency[:method_ids] ||= []
      end
    end

    DiverDown::Definition.from_hash(hash).to_h
  end
end
