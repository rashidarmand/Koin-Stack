class User < ActiveRecord::Base
  has_one :profile
end

class Profile < ActiveRecord::Base
  belongs_to :user
  has_many :posts
  has_many :following
  has_many :followers
end

class Post < ActiveRecord::Base
  belongs_to :profile
  has_many :post_tags
  has_many :tags, through: :post_tags
end

class Tag < ActiveRecord::Base
  has_many :post_tags
  has_many :posts, through: :post_tags
end

class PostTag < ActiveRecord::Base
  belongs_to :post
  belongs_to :tag
end

class Following < ActiveRecord::Base
  belongs_to :profile
end

class Followers < ActiveRecord::Base
  belongs_to :profile
end