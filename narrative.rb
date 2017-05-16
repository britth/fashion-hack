require 'wordsmith-ruby-sdk'

class Narrative
    Wordsmith.configure do |config|
        config.token = ENV["WS_KEY"]
    #config.url = 'https://api.automatedinsights.com/v1' #optional, this is the default value
  end

  def get_project
    project = Wordsmith::Project.find('clothing-categories')
    project.schema
   #puts projects.first
 end


 def get_content(data)
    project = Wordsmith::Project.find('clothing-categories') #project-30 #'clothing-category-descriptions'
    template = project.templates.find('clothing-categories-template') #project-30-template #'clothing-category-descriptions-template'
    data2 = data
    template.generate(data2)[:content]
  end
end
