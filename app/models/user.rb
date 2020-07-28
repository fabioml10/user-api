class User < ApplicationRecord
  has_secure_password
  before_save :downcase_email

  validates_presence_of :email, :password, :password_confirmation
  validates_uniqueness_of :email, case_sensitive: false
  validates_format_of :email, with: /@/
  validates :password, confirmation: true

  def downcase_email
    self.email = self.email.delete(' ').downcase
  end

end
