class WikiLatexController < ApplicationController

  def image
    @latex = WikiLatex.find_by_image_id(params[:image_id])
    @name = params[:image_id]
    if @name != "error"
	image_file = File.join([RAILS_ROOT, 'tmp', 'wiki_latex_plugin', @name+".png"])
    else
	image_file = File.join([RAILS_ROOT, 'public', 'plugin_assets', 'wiki_latex_plugin', 'images', @name+".png"])
    end
    if (!File.exists?(image_file))
    	render_image
    end
    if (File.exists?(image_file))
      render :file => image_file, :layout => false, :content_type => 'image/png'
    else
    	render_404
    end
    rescue ActiveRecord::RecordNotFound
      render_404
  end

private
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
    temp_latex.puts('\usepackage{color}')
    temp_latex.puts('\usepackage[active,displaymath,textmath,graphics]{preview}')
    temp_latex.puts('\begin{document}')
    temp_latex.puts @latex.source
    temp_latex.puts '\end{document}'
    temp_latex.flush
    temp_latex.close

    fork_exec(dir, "/usr/bin/latex --interaction=nonstopmode "+@name+".tex 2> /dev/null > /dev/null")
    fork_exec(dir, "/usr/bin/dvipng "+@name+".dvi -o "+@name+".png")
    ['tex','dvi','log','aux','ps'].each do |ext|
	if File.exists?(basefilename+"."+ext)
    	    File.unlink(basefilename+"."+ext)
	end
    end
  end

  def fork_exec(dir, cmd)
    pid = fork{
      Dir.chdir(dir)
      exec(cmd)
      exit! ec
    }
    ec = nil
    begin
      Process.waitpid pid
      ec = $?.exitstatus
    rescue
    end
  end

end

