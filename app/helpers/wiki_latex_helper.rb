require 'digest/sha2'
require	'tempfile'

module WikiLatexHelper
  def render_image_tag(latex)
    render_to_string :template => 'wiki_latex/macro_inline', :layout => false, :locals => {:name => latex.image_id, :source => latex.source}
  end

  def render_image_block(latex, wiki_name)
    render_to_string :template => 'wiki_latex/macro_block', :layout => false, :locals => {:name => latex.image_id, :source => latex.source, :wiki_name => wiki_name}
  end
	class Macro
		def initialize(view, source)
		  @view = view
		  @view.controller.extend(WikiLatexHelper)
			@classname = source.index("<br />")!= nil ? "latex-block":"latex-inline" 
			source.gsub!(/<br \/>/,"")
			source.gsub!(/<\/?p>/,"")
			name = Digest::SHA256.hexdigest(source)
			if !WikiLatex.exists?(name)
				@latex = WikiLatex.new(:source => source, :image_id => name)
				@latex.save
			else
				@latex = WikiLatex.find_by_image_id(name)
			end
		end

		def render()
		  @view.controller.render_image_tag(@latex)
		end
		def render_block(wiki_name)
		  @view.controller.render_image_block(@latex, wiki_name)
		end
	end
end
