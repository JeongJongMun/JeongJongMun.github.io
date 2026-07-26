#!/usr/bin/env ruby
#
# Give every post its own description.
#
# Most posts open with the same standing disclaimer, so anything derived from
# the post body (jekyll-seo-tag's meta description, feeds, search snippets)
# ended up identical across ~100 posts. This strips the boilerplate listed in
# `site.description_boilerplate` and, when nothing meaningful is left, builds
# a description from the first real content of the post.
#
# The post body itself is untouched; only `post.data['description']` is set.

MAX_LENGTH = 200

# Runs once after all documents are read and before anything renders, so pages
# that list posts (home, related posts) see the same description as the post's
# own meta tags. A per-post :pre_render hook fires too late for those lists.
Jekyll::Hooks.register :site, :post_read do |site|
  site.posts.docs.each { |post| set_post_description(post, site) }
end

def set_post_description(post, site)
  boilerplate = site.config['description_boilerplate'] || []

  strip_boilerplate = lambda do |text|
    boilerplate.reduce(text.to_s) { |acc, phrase| acc.gsub(phrase, ' ') }
               .gsub(/\s+/, ' ')
               .strip
  end

  description = strip_boilerplate.call(post.data['description'])

  if description.empty?
    # Markdown source is cheaper and cleaner than the rendered HTML here:
    # drop code blocks, images, headings and blockquotes, then take prose.
    text = post.content.dup
    text.gsub!(/^```.*?^```/m, ' ')     # fenced code
    text.gsub!(/^\s{4,}\S.*$/, ' ')     # indented code
    text.gsub!(/!\[[^\]]*\]\([^)]*\)/, ' ') # images
    text.gsub!(/\[([^\]]*)\]\([^)]*\)/, '\1') # links -> label
    text.gsub!(/^\s*>.*$/, ' ')         # blockquotes (the disclaimer lives here)
    text.gsub!(/^\s*(?:-{3,}|\*{3,}|_{3,})\s*$/, ' ') # horizontal rules
    text.gsub!(/^\s*#{'#'}+\s*/, ' ')   # heading markers
    text.gsub!(/^\s*\|.*$/, ' ')        # table rows
    text.gsub!(/[*_`~]/, ' ')           # inline emphasis
    text.gsub!(/\{:[^}]*\}/, ' ')       # kramdown attribute lists
    text.gsub!(/<[^>]+>/, ' ')          # stray html
    text = strip_boilerplate.call(text)

    description = text
  end

  return if description.empty?

  if description.length > MAX_LENGTH
    description = description[0, MAX_LENGTH].sub(/\s+\S*\z/, '') + '...'
  end

  post.data['description'] = description
end
