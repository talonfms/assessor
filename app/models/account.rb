class Account < ApplicationRecord
  has_prefix_id :acct

  include Billing
  include Domains
  include Transfer

  belongs_to :owner, class_name: "User"
  belongs_to :parent_account, class_name: "Account", optional: true
  has_many :child_accounts, class_name: "Account", foreign_key: "parent_account_id", dependent: :nullify
  has_many :account_invitations, dependent: :destroy
  has_many :account_users, dependent: :destroy
  has_many :notification_mentions, as: :record, dependent: :destroy, class_name: "Noticed::Event"
  has_many :account_notifications, dependent: :destroy, class_name: "Noticed::Event"
  has_many :users, through: :account_users
  has_many :assessments, dependent: :destroy
  has_many :survey_templates, dependent: :destroy
  has_many :template_versions, through: :survey_templates

  scope :personal, -> { where(personal: true) }
  scope :team, -> { where(personal: false) }
  scope :sorted, -> { order(personal: :desc, name: :asc) }

  has_one_attached :avatar

  validates :avatar, resizable_image: true
  validates :name, presence: true
  validate :is_parent_must_be_truthy, if: :parent_account_id_changed?

  def child_account?
    parent_account_id.present?
  end

  def team?
    !personal?
  end

  def personal_account_for?(user)
    personal? && owner?(user)
  end

  def owner?(user)
    owner_id == user.id
  end

  def members
    account_users.select { |account_user| account_user.roles.try(:[], "member") == true }
  end

  def is_parent_must_be_truthy
    if parent_account_id.present? && !parent_account.is_parent?
      errors.add(:parent_account_id, t("activerecord.errors.models.account.attributes.parent_account.is_parent"))
    end
  end
end
