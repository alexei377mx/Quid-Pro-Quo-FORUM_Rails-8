# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    can [ :read, :update ], Post, user_id: user.id

    if user.admin?
      can :admin, :all
      can :admin_destroy_post, Post
      can :admin_destroy_comment, Comment
      can :read, Report
      can :read, Log
      can :manage, Radio
    end
  end
end
