xml.instruct! :xml, version: '1.0'
cache 'sitemap', expires_in: 24.hours do
  xml.urlset(xmlns: 'http://www.sitemaps.org/schemas/sitemap/0.9',
             'xmlns:rs' => 'http://www.openarchives.org/rs/terms/') do
    xml.rs :md, capability: 'resourcelist', at: Time.current.utc.iso8601
    xml.url do
      xml.loc        root_url
      xml.lastmod    Time.current.utc.iso8601
      xml.changefreq 'weekly'
      xml.priority   1
    end

    @communities.each do |community|
      xml.url do
        xml.loc community_url(community)
        xml.changefreq 'weekly'
        xml.priority   1
        xml.lastmod community.updated_at
      end
    end

    @collections.each do |collection|
      xml.url do
        xml.loc community_collection_url(collection.community, collection)
        xml.changefreq 'weekly'
        xml.priority   1
        xml.lastmod collection.updated_at
      end
    end

    @items.each do |item|
      xml.url do
        xml.loc item_url(item)
        xml.changefreq 'weekly'
        xml.priority   1
        xml.lastmod item.updated_at
        xml.rs :md, type: 'text/html'
        item.file_sets.each do |file_set|
          xml.rs :ln, rel: 'builder'
          xml << "\t#{file_set.sitemap_link}\n"
        end
      end
    end
  end
end
