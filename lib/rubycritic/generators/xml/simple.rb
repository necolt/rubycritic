require 'rexml/document'

module Rubycritic
  module Generator
    module Xml
      class Simple
        def initialize(analysed_modules)
          @analysed_modules = analysed_modules
        end

        def render
          "".tap { |result| document.write(output: result, indent: 2) }
        end

        private

        def document
          REXML::Document.new.tap do |document|
            document << REXML::XMLDecl.new << checkstyle
          end
        end

        def checkstyle
          REXML::Element.new('checkstyle').tap do |checkstyle|
            @analysed_modules.each do |analysed_module|
              if (analysed_module.smells.size > 0)
                checkstyle << file(analysed_module.path, analysed_module.smells)
              end
            end
          end
        end

        def file(name, smells)
          REXML::Element.new('file').tap do |file|
            file.add_attribute 'name', File.realpath(name)

            smells.each do |smell|
              file << error(smell, name)
            end
          end
        end

        def error(smell, analysed_path)
          REXML::Element.new('error').tap do |error|
            error.add_attributes 'column' => 0,
              'line'     => smell_line(analysed_path, smell.locations),
              'message'  => "#{smell.message} (#{ smell_locations_string(smell.locations) })",
              'severity' => 'warning',
              'source'   => smell.type
          end
        end

        def smell_line(analysed_path, locations)
          locations.each do |location|
            return location.line if location.pathname.to_s == analysed_path
          end

          0 # Let's hope this won't happen
        end

        def smell_locations_string(locations)
          [ locations.map { |location| "#{location.pathname}:#{location.line}" } ].join(", ")
        end
      end
    end
  end
end
