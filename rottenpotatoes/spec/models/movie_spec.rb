require 'rails_helper'

RSpec.describe Movie, type: :model do
  before(:all) do
    if Movie.where(:title => "Big Hero 6").empty?
      Movie.create(:title => "Big Hero 6", 
                   :rating => "PG", :release_date => "2014-11-07")
    end
    
    # TODO(student): add more movies to use for testing
  end
  
  describe "others_by_same_director method" do
    it "returns all other movies by the same director"
      # TODO(student): implement this test
    
    it "does not return movies by other directors"
      # TODO(student): implement this test
  end
end


