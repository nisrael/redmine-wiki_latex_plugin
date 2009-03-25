require 'redmine'

RAILS_DEFAULT_LOGGER.info 'Starting wiki_latex_plugin for Redmine'

Redmine::Plugin.register :wiki_latex_plugin do
  name 'Latex Wiki-macro Plugin'
  author 'soda'
  description 'Render latex images'
  version '0.0.2'

	Redmine::WikiFormatting::Macros.register do

		desc <<'EOF'
Latex Plugin
{{latex(place latex code here)}}

{{latex(
or place
some code
here
)}}
EOF
		macro :latex do |wiki_content_obj, args|
			m = WikiLatexHelper::Macro.new(self, args[0])
			m.render
		end
	end
end
