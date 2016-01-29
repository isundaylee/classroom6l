class Classroom < ApplicationRecord
  SUPPORTED_LANGUAGES = {
    'ruby' => {
      name: 'Ruby',
      extension: 'rb'
    },
    'python' => {
      name: 'Python',
      extension: 'py'
    }
  }

  DEFAULT_PARCHMENTS = {
    'ruby' => {
      '/code.rb' => "puts 'Hello, world! '\n"
    }, 
    'python' => {
      '/code.py' => "print('Hello, world! ')\n"
    }
  }

  has_many :parchments

  validates :name, presence: true, length: {minimum: 1, maximum: 100}
  validates :language, inclusion: SUPPORTED_LANGUAGES.keys

  after_save :save_code
  after_create :create_default_parchments

  def code
    parchments[0].content
  end

  def language_extension
    language_profile()[:extension]
  end

  def language_name
    language_profile()[:name]
  end

  def attendance_add(username)
    $redis.sadd(attendance_redis_key, username)
  end

  def attendance_remove(username)
    $redis.srem(attendance_redis_key, username)
  end

  def attendance_get
    $redis.smembers(attendance_redis_key)
  end

  private
    def attendance_redis_key
      "attendance_#{self.id}"
    end

    def save_code
      # Note that we DO wanna save @code even if it is an empty string.
      self.codes.create(content: @code) unless @code.nil?
    end

    def language_profile
      SUPPORTED_LANGUAGES[self.language]
    end

    def create_default_parchments
      DEFAULT_PARCHMENTS[self.language].each do |k, v|
        self.parchments.create!(path: k, content: v)
      end
    end
end
