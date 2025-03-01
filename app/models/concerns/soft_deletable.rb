module SoftDeletable
  extend ActiveSupport::Concern

  included do
    scope :kept, -> { where(deleted_at: nil) }
    scope :discarded, -> { where.not(deleted_at: nil) }
  end

  # Mark record as soft-deleted
  def soft_delete
    update(deleted_at: Time.current)
  end

  # Restore a soft-deleted record
  def restore
    update(deleted_at: nil)
  end

  # Check if record is soft-deleted
  def discarded?
    deleted_at.present?
  end

  # Check if record is not soft-deleted
  def kept?
    !discarded?
  end
end
