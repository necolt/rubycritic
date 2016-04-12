require 'rubycritic/core/analysed_modules_collection'
require 'rubycritic/analysers/smells/flay'
require 'rubycritic/analysers/smells/flog'
require 'rubycritic/analysers/smells/reek'
require 'rubycritic/analysers/complexity'
require 'rubycritic/analysers/churn'
require 'rubycritic/analysers/attributes'

module Rubycritic
  class AnalysersRunner
    ANALYSERS = [
      Analyser::FlaySmells,
      Analyser::FlogSmells,
      Analyser::ReekSmells,
      Analyser::Complexity,
      Analyser::Attributes,
      Analyser::Churn
    ].freeze

    ANALYSER_MAP = {
      'flay' => Analyser::FlaySmells,
      'flog' => Analyser::FlogSmells,
      'reek' => Analyser::ReekSmells,
      'complexity' => Analyser::Complexity,
      'attributes' => Analyser::Attributes,
      'churn' => Analyser::Churn
    }.freeze

    def initialize(paths)
      @paths = paths
    end

    def run
      chosen_analysers.each do |analyser_class|
        analyser_instance = analyser_class.new(analysed_modules)
        puts "running #{analyser_instance}"
        analyser_instance.run
      end
      analysed_modules
    end

    def analysed_modules
      @analysed_modules ||= AnalysedModulesCollection.new(@paths)
    end

    private

    def chosen_analysers
      Config.analysers.map do |analyser|
        ANALYSER_MAP[analyser].tap do |analyser_class|
          raise 'Unknown analiser!' if analyser_class.nil?
        end
      end
    end
  end
end
