class Classroom < ApplicationRecord
  SUPPORTED_TEMPLATES = ['ruby', 'python', 'java']

  TEMPLATES = {
    'ruby' => {
      'makefile' => "run:\n\t@ruby code.rb",
      'code.rb' => "puts 'Hello, world! '\n", 
    }, 
    'python' => {
      'makefile' => "run:\n\t@python3 code.py",
      'code.py' => "print('Hello, world! ')\n", 
    }, 
    'java' => {
      'makefile' =>"run:\n\t@javac Code.java\n\t@java Code", 
      'code.java' => <<-eos
public class Code {
    public static void main(String args[]) {
        System.out.println("Hello, world! ");
    }
}
      eos
    }
  }

  has_many :parchments

  validates :name, presence: true, length: {minimum: 1, maximum: 100}

  def build_template!(template)
    raise ArgumentError, "Invalid template `#{template}. " unless TEMPLATES[template]
    TEMPLATES[template].each do |k, v|
      self.parchments.create!(path: k, content: v)
    end
  end 

  def main_parchment
    parchments.select { |p| p.path.downcase != 'makefile' }.first
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
end
