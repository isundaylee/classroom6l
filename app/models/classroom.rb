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

  private
    def save_code
      # Note that we DO wanna save @code even if it is an empty string.
      self.codes.create(content: @code) unless @code.nil?
    end

    def language_profile
      SUPPORTED_LANGUAGES[self.language]
    end
end
