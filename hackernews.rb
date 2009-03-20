require 'sinatra'
require 'open-uri'
require 'hpricot'

# Written by Peter Cooper for this Hacker News thread:
# http://news.ycombinator.com/item?id=524586

get '/:username' do
	username = params[:username]
	uri = 'http://news.ycombinator.com/threads?id=' + username
	doc = Hpricot(open(uri))

	out = %{<?xml version="1.0" encoding="utf-8" ?>
	<rss version="2.0">
	<channel>
	<title>Hacker News responses to #{username}</title>
	<link>#{uri}</link>\n}

	(doc/'td td table').each do |post|
		content = post.inner_html
		next if content =~ />#{username}</       # skip if we posted it
		next unless post.inner_html =~ /vote/    # skip if it's not a post
		id = content[/\_(\d+)/,1]
		comment_text = (post/'.comment').first.inner_text
		commenter = content[/user\?id=(\w+)/,1]
		out += %{  <item>\n    <title>Comment from #{commenter}</title>\n}
		out += %{    <link>http://news.ycombinator.com/item?id=#{id}</link>\n}
		out += %{    <description>#{comment_text}</description>\n  </item>\n}
	end
	out += %{</channel></rss>}
end
