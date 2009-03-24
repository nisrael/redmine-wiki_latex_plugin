require 'digest/sha2'
require	'tempfile'

module WikiLatexHelper

	class Macro
		def initialize(source)
			@block = source.index("<br />")!= nil
			@source = source.gsub("<br />","")
			@name = Digest::SHA256.hexdigest(@source)
			@dir = File.join([RAILS_ROOT, 'public', 'images', 'wiki_latex_plugin'])
		end

		def render()
			if !File.exists?(File.join([@dir, @name]))
				begin
					Dir.mkdir(@dir)
				rescue
				end
				render_image
				counter = 0
				while (!File.exists?(File.join([@dir, @name])) && counter<50) do
					counter+=1
					sleep 0.1
				end

		
			end
			if @block
				"<img class='latex_block' src='/redmine/images/wiki_latex_plugin/"+@name+".png' />"
			else
				"<img class='latex_inline' src='/redmine/images/wiki_latex_plugin/"+@name+".png' />"
			end
		end
		
		def render_image
			dir = File.join([RAILS_ROOT, 'tmp', 'wiki_latex_plugin'])
			begin
				Dir.mkdir(dir)
			rescue
			end
			basefilename = File.join([dir,@name])
			temp_latex = File.open(basefilename+".tex",'w')
			temp_latex.puts('\documentclass[10pt]{article}')
			temp_latex.puts('% add additional packages here')
			temp_latex.puts('\usepackage{amsmath}')
			temp_latex.puts('\usepackage{amsfonts}')
			temp_latex.puts('\usepackage{amssymb}')
			temp_latex.puts('\usepackage{pst-plot}')
			temp_latex.puts('\usepackage{color}')
			temp_latex.puts('\pagestyle{empty}')
			temp_latex.puts('\begin{document}')
			temp_latex.puts @source
			temp_latex.puts '\end{document}'
			temp_latex.flush
			temp_latex.close
			fork {
				Dir.chdir(dir)
				exec("/usr/bin/latex --interaction=nonstopmode "+@name+".tex 2> /dev/null > /dev/null ; /usr/bin/dvips -E "+@name+".dvi -o "+@name+".ps ; /usr/bin/convert -density 120 "+@name+".ps "+@name+".png ; cp "+@name+".png "+@dir+" ; rm -f "+basefilename+".*")
				exit!
			}
			#['tex','dvi','log','aux','ps','png'].each do |ext|
			#	File.unlink(basefilename+"."+ext)
			#end
		end

	end

	def	render_graph_exactly(layout, fmt, dot_text, options = {})

		dir = File.join([RAILS_ROOT, 'tmp', 'wiki_graphviz_plugin'])
		begin
			Dir.mkdir(dir)
		rescue
		end
		temp_img = Tempfile.open("graph", dir)
		temp_img.close
		fn_img = temp_img.path
		temp_map = Tempfile.open("map", dir)
		temp_map.close
		fn_map = temp_map.path

		result = {}

		pipe = IO.pipe
		pid = fork {
			# child

			# Gv reports errors to stderr immediately.
			# so, get the message from pipe
			STDERR.reopen(pipe[1])

			require 'gv'

			g = nil
			ec = 0
			begin
				g = Gv.readstring(dot_text)
				if g.nil?
					ec = 1
					raise	"readstring"
				end
				r = Gv.layout(g, layout)
				if !r
					ec = 2
					raise	"layout"
				end
				r = Gv.render(g, fmt[:type], fn_img)
				if !r
					ec = 3
					raise	"render"
				end
				r = Gv.render(g, "imap", fn_map)
				if !r
					ec = 4
					raise	"render imap"
				end
			rescue
			ensure
				if g
					Gv.rm(g)
				end
			end
			exit! ec
		}

		# parent
		pipe[1].close
		ec = nil
		begin
			Process.waitpid pid
			ec = $?.exitstatus
			RAILS_DEFAULT_LOGGER.info("child status: sig=#{$?.termsig}, exit=#{ec}")
		rescue
		end
		result[:message] = pipe[0].read.to_s.strip
		pipe[0].close

		img = nil
		maps = []
		begin
			if !ec.nil? && ec == 0
				temp_img.open
				img = temp_img.read

				temp_map.open
				temp_map.each {|t|
					cols = t.split(/ /)
					if cols[0] == "base"
						next
					end

					shape = cols.shift
					url = cols.shift
					maps.push(:shape => shape, :url => url, :positions => cols)
				}
			end
		rescue
		ensure
			temp_img.close(true)
			temp_map.close(true)
		end

		result[:image] = img
		result[:maps] = maps
		result[:format] = fmt
		result
	end


end

# vim: set ts=2 sw=2 sts=2:

