class User < ActiveRecord::Base
  has_many :roles

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  scope :excluding_archived, lambda { where(archived_at: nil) }

  def generate_api_key
    self.update_column(:api_key, SecureRandom.hex(16))
  end

  def to_s
    "#{email} (#{admin? ? "Admin" : "User"})"
  end

  def archive
    update(archived_at: Time.now)
  end

  # Extend devise to disallow authentication for users with the archived column
  # set.
  def active_for_authentication?
    super && archived_at.nil?
  end

  # The message to display when devise authentication fails, extended with
  # support for user archiving.
  #
  # Note, the addition of :archived requires an error message be added to the
  # file config/locales/devise.en.yml
  def inactive_message
    archived_at.nil? ? super : :archived
  end

  def role_on(project)
    roles.find_by(project_id: project).try(:name)
  end
end
