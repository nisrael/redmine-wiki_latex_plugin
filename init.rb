require 'redmine'

RAILS_DEFAULT_LOGGER.info 'Starting wiki_latex_plugin for Redmine'

Redmine::Plugin.register :wiki_latex_plugin do
  name 'Latex Wiki-macro Plugin'
  author 'Nils Israel'
  description 'Render latex images'
  version '0.0.3'

	Redmine::WikiFormatting::Macros.register do

		desc <<'EOF'
Latex Plugin
{{latex(place inline latex code here)}}

Don't use curly braces. '
EOF
		macro :latex do |wiki_content_obj, args|
			m = WikiLatexHelper::Macro.new(self, args.to_s)
			m.render
		end


    # code borrowed from wiki template macro
    desc <<'EOF'
Include wiki page rendered with latex.
{{latex_include(WikiName)}}
EOF
    macro :latex_include do |obj, args|
      page = Wiki.find_page(args.to_s, :project => @project)
      raise 'Page not found' if page.nil? || !User.current.allowed_to?(:view_wiki_pages, page.wiki.project)

      @included_wiki_pages ||= []
      raise 'Circular inclusion detected' if @included_wiki_pages.include?(page.title)
      @included_wiki_pages << page.title
      m = WikiLatexHelper::Macro.new(self, page.content.text)
      @included_wiki_pages.pop
      m.render_block(args.to_s)
    end
  end

end
