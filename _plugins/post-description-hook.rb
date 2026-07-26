#!/usr/bin/env ruby
#
# Give every post a description.
#
# Posts normally declare their own `description` in front matter. When one
# doesn't, this builds a readable summary from the start of the post instead
# of letting jekyll-seo-tag fall back to raw markdown.
#
# The post body itself is untouched; only `post.data['description']` is set.

MAX_LENGTH = 200

# Runs once after all documents are read and before anything renders, so pages
# that list posts (home, related posts) see the same description as the post's
# own meta tags. A per-post :pre_render hook fires too late for those lists.
Jekyll::Hooks.register :site, :post_read do |site|
  site.posts.docs.each { |post| set_post_description(post) }
end

def set_post_description(post)
  description = post.data['description'].to_s.gsub(/\s+/, ' ').strip

  if description.empty?
    # Markdown source is cheaper and cleaner than the rendered HTML here:
    # drop code blocks, images, headings and blockquotes, then take prose.
    text = post.content.dup
    text.gsub!(/^```.*?^```/m, ' ')     # fenced code
    text.gsub!(/^\s{4,}\S.*$/, ' ')     # indented code
    text.gsub!(/!\[[^\]]*\]\([^)]*\)/, ' ') # images
    text.gsub!(/\[([^\]]*)\]\([^)]*\)/, '\1') # links -> label
    text.gsub!(/^\s*>.*$/, ' ')         # blockquotes
    text.gsub!(/^\s*(?:-{3,}|\*{3,}|_{3,})\s*$/, ' ') # horizontal rules
    text.gsub!(/^\s*#{'#'}+\s*/, ' ')   # heading markers
    text.gsub!(/^\s*\|.*$/, ' ')        # table rows
    text.gsub!(/[*_`~]/, ' ')           # inline emphasis
    text.gsub!(/\{:[^}]*\}/, ' ')       # kramdown attribute lists
    text.gsub!(/<[^>]+>/, ' ')          # stray html

    description = text.gsub(/\s+/, ' ').strip
  end

  return if description.empty?

  if description.length > MAX_LENGTH
    description = description[0, MAX_LENGTH].sub(/\s+\S*\z/, '') + '...'
  end

  post.data['description'] = description
end
