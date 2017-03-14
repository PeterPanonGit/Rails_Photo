class Comment < ActiveRecord::Base
  belongs_to :commentable, polymorphic: true
  belongs_to :client
  validates :body, presence: true

end
