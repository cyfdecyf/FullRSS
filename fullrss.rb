#!/usr/bin/env ruby
#encoding: UTF-8

# Only tested with UTF-8 encoding XML and HTML
# If there's problems with other encoding, convert to UTF-8 first

require 'rubygems'
require 'hpricot'
require 'open-uri'

# You can use this too
def fetch_full_rss(source, content_fetcher)
  feed = open(source) { |f| Hpricot.XML(f) }

  item = feed/:item
  item.each do |it|
    link = (it/:link).inner_html
    content = content_fetcher.call(link)
    it.at(:description).after <<-CDATA
    \n<content:encoded><!CDATA[#{content}]]</content/encoded>
    CDATA
  end
  feed
end

def fetch_sina_article(link)
  doc = open(link) { |f| Hpricot(f) }

  article = doc.search("//div[@id = 'articlebody']")
  paras = article/('.articalContent p')
  # use inner_text to conver html entities to character
  content = paras.collect { |pa| '<p>' + pa.inner_text + '</p>' }.join("\n")
end

# Han Han's blog on Sina, I created this to read his great articles
sources = [
  ["http://blog.sina.com.cn/rss/1191258123.xml", "hanhan.xml", method(:fetch_sina_article)],
]

sources.each do |url, file, fetcher|
  full = fetch_full_rss(url, fetcher)
  File.open(file, "w") { |f| f.write(full) }
end

