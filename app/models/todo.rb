class Todo < ActiveRecord::Base

  def self.area_types?
    Setting.area_types.present?
  end

  def self.description?
    Setting.description.present?
  end

  def self.social_media?
    Setting.social_medias.map(&:value).reject(&:empty?).present?
  end

  def self.more_than_one_category?
    Category.count > 1
  end

  def self.mapbox_ready?
    Maptile.mapbox.api_key.present?
  end

  def self.mapquest_ready?
    Maptile.mapquest.api_key.present?
  end

end
