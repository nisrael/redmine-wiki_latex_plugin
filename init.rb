require 'redmine'

RAILS_DEFAULT_LOGGER.info 'Starting wiki_latex_plugin for Redmine'

Redmine::Plugin.register :wiki_latex_plugin do
  name 'Latex Wiki-macro Plugin'
  author 'soda'
  description 'Render latex image from the wiki contents'
  version '0.0.1'
#	settings :default => {'cache_seconds' => '0'}, :partial => 'wiki_graphviz/settings'

	Redmine::WikiFormatting::Macros.register do

		desc <<'EOF'
Latex Plugin
EOF
		macro :latex do |wiki_content_obj, args|
			#m = WikiGraphvizHelper::Macro.new(self, wiki_content_obj)
			#m.graphviz(args, params[:id])
      "nix"
		end
	end
end



# vim: set ts=2 sw=2 sts=2:
