require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "John Doe", email: "john@doe.com",
                    password: "foobar", password_confirmation: "foobar")
  end
  test "should be valid" do
    assert @user.valid?
  end
  test "should be present" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end
  test "email should be present" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end
  test "email validation should accept valid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end
  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end
  test "email addresses should be saved as lowercase" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end
  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
  end
  test "password should have minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
  end
  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end
  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end
  test "should follow and unfollow a user" do
    emily = users(:emily)
    user_5 = users(:user_5)
    assert_not emily.following?(user_5)
    emily.follow(user_5)
    assert emily.following?(user_5)
    assert user_5.followers.include?(emily)
    emily.unfollow(user_5)
    assert_not emily.following?(user_5)
  end
  test "feed should have right posts" do
    emily = users(:emily)
    user_1 = users(:user_1)
    user_5 = users(:user_5)
    user_1.microposts.each do |post_following|
      assert emily.feed.include?(post_following)
    end
    emily.microposts.each do |post_self|
      assert emily.feed.include?(post_self)
    end
    user_5.microposts.each do |post_unfollowed|
      assert_not emily.feed.include?(post_unfollowed)
    end
  end
end
