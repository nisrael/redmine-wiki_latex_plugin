require 'digest/sha2'
require	'tempfile'

module WikiLatexHelper
  def render_image_tag(image_name, source)
    render_to_string :template => 'wiki_latex/macro_inline', :layout => false, :locals => {:name => image_name, :source => source}
  end

  def render_image_block(image_name, source, wiki_name)
    render_to_string :template => 'wiki_latex/macro_block', :layout => false, :locals => {:name => image_name, :source => source, :wiki_name => wiki_name}
  end
	class Macro
		def initialize(view, source)
		  @view = view
		  @view.controller.extend(WikiLatexHelper)
			source.gsub!(/<br \/>/,"")
			source.gsub!(/<\/?p>/,"")
			name = Digest::SHA256.hexdigest(source)
			if !WikiLatex.find_by_image_id(name)
				@latex = WikiLatex.new(:source => source, :image_id => name)
				@latex.save
			end
			@latex = WikiLatex.find_by_image_id(name)
		end

		def render()
		  if @latex
		    @view.controller.render_image_tag(@latex.image_id, @latex.source)
		  else
		    @view.controller.render_image_tag("error", "error")
		  end
		end
		def render_block(wiki_name)
		  if @latex
		    @view.controller.render_image_block(@latex.image_id, @latex.source, wiki_name)
		  else
		    @view.controller.render_image_block("error", "error", wiki_name)
		  end
		end
	end
end
