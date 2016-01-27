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

  has_many :codes

  validates :name, presence: true, length: {minimum: 1, maximum: 100}
  validates :language, inclusion: SUPPORTED_LANGUAGES.keys

  after_save :save_code

  def code
    if @code.present?
      return @code
    else
      return codes.any? ?
        codes.order('updated_at DESC').first.content :
        ''
    end
  end

  def code=(content)
    @code = content
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

  def apply_patch(patchText)
    self.with_lock do
      dmp = DiffMatchPatch.new
      patches = dmp.patch_fromText(patchText)
      new_code, success = dmp.patch_apply(patches, self.code)

      if success.all?
        self.code = new_code
        self.save!
      end

      return success.all?
    end
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
end
