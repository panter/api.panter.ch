class LocalRepository::Frameworks < LocalRepository::Base
  def absolute_values
    valid_directories
      .map do |directory|
        # don't bail on broken repositores
        Technologist::Repository.new(directory).frameworks rescue []
      end
      .flatten
      .inject(Hash.new(0)) { |hash, value| hash[value] += 1; hash }
      .sort_by { |key, value| value }
      .reverse
      .to_h
  end
end
