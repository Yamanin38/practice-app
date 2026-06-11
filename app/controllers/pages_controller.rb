class PagesController < ApplicationController
  def index
  end

  def gallery
    @images = Image.ordered_by_date
    @images = @images.by_date(params[:date]) if params[:date].present?
    @images = @images.page(params[:page]).per(20)
    @upload_dates = Image.all
                        .map { |img| img.created_at.in_time_zone('Tokyo').to_date }
                        .uniq
                        .sort
                        .reverse
  end

  def articles
  end

  def about
  end

  def recruitment
  end

  def rules
  end

  def users
  end

  def contact
  end
end
