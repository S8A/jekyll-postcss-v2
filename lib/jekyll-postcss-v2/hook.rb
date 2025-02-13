# frozen_string_literal: true

require "pathname"

module PostCssV2
  class Engine
    def initialize(source, options = {})
      @script = File.expand_path(options[:script] || 'node_modules/.bin/postcss', source)
      unless File.exist?(@script)
        Jekyll.logger.error "PostCSS v2:",
                            "PostCSS not found.
                             Make sure postcss and postcss-cli
                             are installed in your Jekyll source."
        Jekyll.logger.error "PostCSS v2:",
                            "Couldn't find #{@script}"
        exit 1
      end

      @config = File.expand_path(options[:config] || 'postcss.config.js', source)
      unless File.exist?(@config)
        Jekyll.logger.error "PostCSS v2:",
                            "postcss.config.js not found.
                             Make sure it exists in your Jekyll source."
        Jekyll.logger.error "PostCSS v2:",
                            "Couldn't find #{@config}"
        exit 1
      end
    end

    def process(page)
      file_path = Pathname.new(page.destination(page.site.dest))
      postcss_command = `#{@script} #{file_path} -r --config #{@config}`
      Jekyll.logger.info "PostCSS v2:",
                         "Rewrote #{page.url} #{postcss_command}"
    end
  end
end

Jekyll::Hooks.register :site, :post_write do |site|
  site.pages.each do |page|
    Jekyll.logger.debug "PostCSS v2:",
                        "Processing #{page.url}"
    if %r!\.css$! =~ page.destination(site.dest)
      engine = PostCssV2::Engine.new(site.source, {
        script: site.config.dig("postcss", "script"),
        config: site.config.dig("postcss", "config"),
      })
      engine.process(page)
    end
  end
end
