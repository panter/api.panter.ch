class ProjectFilter
  def self.deprecated?(project)
    description = project.description.to_s

    description.include?('DEPRECATED') ||
      description.include?('MOVED')
  end
end
