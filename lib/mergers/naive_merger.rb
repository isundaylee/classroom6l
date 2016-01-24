class NaiveMerger < Merger
  def merge(ancestor, a, b)
    return b if ancestor == a
    return a if ancestor == b
    raise CannotMergeException
  end
end
