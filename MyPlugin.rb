require 'sketchup.rb'

module MyPlugin
  ROOT = File.dirname(__FILE__).freeze

  unless file_loaded?(__FILE__)
    require File.join(ROOT, 'MyPlugin', 'main')
    file_loaded(__FILE__)
  end
end
