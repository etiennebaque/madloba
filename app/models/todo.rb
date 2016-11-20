class Todo < ActiveRecord::Base

  def condition_met?
    Todo.send(self.condition)
  end

  def message_and_alert
    {text: I18n.t("admin.todo.#{self.description}_html").html_safe, type: self.alert}
  end

  def self.area_types?
    Area.all.any?
  end

  def self.description?
    Setting.description.present?
  end

  def self.social_media?
    Setting.social_medias.map(&:value).reject(&:empty?).present?
  end

  def self.any_category?
    Category.count > 0
  end

  def self.more_than_one_category?
    Category.count > 1
  end

  def self.mapbox_ready?
    MapTile.mapbox.api_key.present?
  end

  def self.mapquest_ready?
    MapTile.mapquest.api_key.present?
  end

end
