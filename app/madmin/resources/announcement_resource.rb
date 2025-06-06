class AnnouncementResource < Madmin::Resource
  scope :draft
  scope :published

  # Attributes
  attribute :id, form: false
  attribute :kind, :select, collection: Announcement::TYPES
  attribute :title
  attribute :published_at, index: true
  attribute :created_at, form: false
  attribute :updated_at, form: false
  attribute :description, index: false

  # Associations

  # Uncomment this to customize the display name of records in the admin area.
  # def self.display_name(record)
  #   record.name
  # end

  # Uncomment this to customize the default sort column and direction.
  # def self.default_sort_column
  #   "created_at"
  # end
  #
  # def self.default_sort_direction
  #   "desc"
  # end

  member_action do
    link_to "View", main_app.announcement_path(@record), class: "btn btn-secondary"
  end
end
