class BlogPost < ActiveRecord::Base
  has_many :comments, as: :commentable

  def short_text
    body.split[0...50].join(' ').html_safe
  end
end
