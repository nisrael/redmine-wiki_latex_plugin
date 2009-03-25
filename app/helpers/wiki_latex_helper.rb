require 'digest/sha2'
require	'tempfile'

module WikiLatexHelper
  def render_image_tag(latex, classname)
    render_to_string :template => 'wiki_latex/macro', :layout => false, :locals => {:classname=> classname, :name => latex.image_id, :source => latex.source}
  end

	class Macro
		def initialize(view, source)
		  @view = view
		  @view.controller.extend(WikiLatexHelper)
			@classname = source.index("<br />")!= nil ? "latex-block":"latex-inline" 
			source = source.gsub("<br />","")
			name = Digest::SHA256.hexdigest(source)
			if !WikiLatex.exists?(name)
				@latex = WikiLatex.new(:source => source, :image_id => name)
				@latex.save
			else
				@latex = WikiLatex.find_by_image_id(name)
			end
		end

		def render()
		  @view.controller.render_image_tag(@latex, @classname)
		end
	end
end
