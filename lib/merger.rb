class Merger
  class CannotMergeException < Exception; end

  def merge(ancestor, a, b)
    raise NotImplementedError
  end
end