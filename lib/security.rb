module Security
  def self.hash_password(password)
    BCrypt::Password.create(password)
  end

  def self.check_password(hash, password)
    BCrypt::Password.new(hash) == password
  end

  # Devise
  def self.friendly_token(length = 20)
    rlength = (length * 3) / 4
    SecureRandom.urlsafe_base64(rlength).tr('lIO0', 'sxyz')
  end

  def self.secure_compare(a, b)
    return false if a.blank? || b.blank? || a.bytesize != b.bytesize
    l = a.unpack "C#{a.bytesize}"

    res = 0
    b.each_byte { |byte| res |= byte ^ l.shift }
    res == 0
  end
end
