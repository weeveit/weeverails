class SitemapController < ApplicationController
  layout nil

  # sitemap for SEO
  def index
    headers['Content-Type'] = 'application/xml'

    respond_to do |format|
      format.xml {}
    end
  end
end