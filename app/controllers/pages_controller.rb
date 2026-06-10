class PagesController < ApplicationController
  def index
  end

  def gallery
    @images = Image.ordered_by_date
    @images = @images.by_date(params[:date]) if params[:date].present?
    @upload_dates = Image.pluck(Arel.sql("DISTINCT DATE(created_at)"))
                         .map { |d| Date.parse(d) }
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
