module Repositories
  class Clojars < Base
    HAS_VERSIONS = true
    HAS_DEPENDENCIES = false
    LIBRARIAN_SUPPORT = true
    URL = 'https://clojars.org'
    COLOR = '#db5855'

    def self.package_link(name, version = nil)
      "https://clojars.org/#{name}" + (version ? "/versions/#{version}" : "")
    end

    def self.project_names
      @names ||= get("http://clojars-json.herokuapp.com/packages.json").keys
    end

    def self.recent_names
      get_html("https://clojars.org/").css('.recent-jar-title a').map(&:text)
    end

    def self.projects
      @projects ||= begin
        projs = {}
        get("http://clojars-json.herokuapp.com/feed.json").each do |k,v|
          v.each do |proj|
            group = proj['group-id']
            key = (group == k ? k : "#{group}/#{k}")
            projs[key] = proj
          end
        end
        projs
      end
    end

    def self.project(name)
      projects[name.downcase].merge(name: name)
    end

    def self.mapping(project)
      {
        :name => project[:name],
        :description => project["description"],
        :repository_url => repo_fallback(project["scm"]["url"], '')
      }
    end

    def self.versions(project)
      project['versions'].map do |v|
        {
          :number => v
        }
      end
    end
  end
end
