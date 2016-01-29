class Parchment < ApplicationRecord
  belongs_to :classroom

  validates :path, format: {with: /\A[a-z0-9._\-\/]*\z/i, message: 'can only contain alphanumerical characters, underscores, dots, and slashes. '}

  def apply_patch(patchText)
    self.with_lock do
      dmp = DiffMatchPatch.new
      patches = dmp.patch_fromText(patchText)
      new_content, success = dmp.patch_apply(patches, self.content)

      if success.all?
        self.content = new_content
        self.save!
      end

      return success.all?
    end
  end
end
