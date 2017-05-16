require 'wordsmith-ruby-sdk'

class Narrative
    Wordsmith.configure do |config|
        config.token = ENV["WS_KEY"]
    #config.url = 'https://api.automatedinsights.com/v1' #optional, this is the default value
  end

  def get_project
    project = Wordsmith::Project.find('clothing-categories')
    project.schema
 end


 def get_content(data)
    project = Wordsmith::Project.find('clothing-categories')
    template = project.templates.find('clothing-categories-template')
    data2 = data
    template.generate(data2)[:content]
  end
end
