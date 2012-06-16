require 'bundler'
require 'meta_methods'

require 'file_utils/file_utils'
require 'zip_dsl/zip_dsl'
require 'zip_dsl/zip_writer'
require 'directory_builder'

class WebAppBuilder
  include MetaMethods
  include FileUtils

  WARFILE_NAME = "Warfile"

  #JRUBY_JARS_VERSION         = Gem.loaded_specs["jruby-jars"].version
  #JRUBY_RACK_VERSION         = Gem.loaded_specs["jruby-rack"].version
  #JRUBY_OPENSSL_VERSION      = Gem.loaded_specs["jruby-openssl"].version
  #BOUNCY_CASTLE_JAVA_VERSION = Gem.loaded_specs["bouncy-castle-java"].version

  JRUBY_JARS_VERSION         = "1"
  JRUBY_RACK_VERSION         = "1"
  JRUBY_OPENSSL_VERSION      = "0.7.6.1"
  BOUNCY_CASTLE_JAVA_VERSION = "1.5.0146.1"

  attr_reader :build_dir, :basedir, :config

  def initialize build_dir, basedir, gemset_name
    @build_dir = build_dir
    @basedir = File.expand_path(basedir)
    @gemset_name = gemset_name
  end

  def configure
    @config ||= locals_to_hash(self, read_file("#{basedir}/#{WARFILE_NAME}"))
  end

  def clean
    configure

    delete_directory build_dir
  end

  def prepare
    create_directory build_dir

    process_templates "#@basedir/#{config[:templates_dir]}"
  end

  def war
    configure

    gems = bundler_gems
    global_gem_home = global_gem_home(@gemset_name)

    manifest = <<-TEXT
Built-By: web_app_builder
Created-By: #{config[:author]}
    TEXT

    builder = Zip::DSL.new "#{build_dir}/#{config[:project_name]}.war", "."

    builder.build do
      directory :from_dir => "#{build_dir}/WEB-INF", :to_dir => "WEB-INF"
      directory :from_dir => "#{build_dir}/META-INF", :to_dir => "META-INF"
      directory :from_dir => "app", :to_dir => "WEB-INF/app"
      directory :from_dir => "config", :to_dir => "WEB-INF/config"
      directory :from_dir => "lib", :to_dir => "WEB-INF/lib", :filter => "*.rb"
      directory :from_dir => "vendor", :to_dir => "WEB-INF/vendor"

      directory :from_dir => "#{gem_home}/gems", :to_dir => "WEB-INF/gems/gems", :filter => included_gems(gems)
      directory :from_dir => "#{gem_home}/specifications", :to_dir => "WEB-INF/gems/specifications",
                :filter => included_specs(gems)
      directory :from_dir => "#{global_gem_home}/gems", :to_dir => "WEB-INF/gems/gems",
      :filter => included_global_gems
      directory :from_dir => "#{global_gem_home}/specifications", :to_dir => "WEB-INF/gems/specifications",
      :filter => included_global_specs

      directory :from_dir => "#{global_gem_home}/gems/jruby-openssl-#{JRUBY_OPENSSL_VERSION}/lib/shared",
                :to_dir => "WEB-INF/lib", :filter => "*.jar"
      directory :from_dir => "#{global_gem_home}/gems/bouncy-castle-java-#{BOUNCY_CASTLE_JAVA_VERSION}/lib",
                :to_dir => "WEB-INF/lib", :filter => "*.jar"
      directory :from_dir => "#{ruby_home}/lib", :to_dir => "WEB-INF/lib", :filter => "*.jar"

      config[:additional_java_jars].each do |jar|
        file :name => jar, :to_dir => "WEB-INF/lib"
      end if config[:additional_java_jars]

      directory :to_dir => "WEB-INF/log"

      directory :from_dir => "#{gem_home}/gems/jruby-rack-#{JRUBY_RACK_VERSION}/lib", :to_dir => "WEB-INF/lib", :filter => "*.jar"
      directory :from_dir => "#{gem_home}/gems/jruby-jars-#{JRUBY_JARS_VERSION}/lib", :to_dir => "WEB-INF/lib", :filter => "*.jar"

      jars(gems).each do |jar|
        file :name => jar, :to_dir => "WEB-INF/lib"
      end

      file :name => "#{basedir}/Gemfile", :to_dir => "WEB-INF"
      file :name => "#{basedir}/Gemfile.lock", :to_dir => "WEB-INF"

      directory :from_dir => "public"

      content :name => "MANIFEST.MF", :to_dir => "META-INF", :source => manifest
    end
  end

  def war_exploded
    configure

    to_dir = "#{build_dir}/exploded"

    gems = bundler_gems

    global_gem_home = global_gem_home(@gemset_name)

    builder = DirectoryBuilder.new to_dir, basedir

    builder.build do
      directory :from_dir => "#{build_dir}/WEB-INF", :to_dir => "WEB-INF"
      directory :from_dir => "#{build_dir}/META-INF", :to_dir => "META-INF"

      directory :from_dir => "app", :to_dir => "WEB-INF/app"
      directory :from_dir => "config", :to_dir => "WEB-INF/config"
      directory :from_dir => "lib", :to_dir => "WEB-INF/lib", :filter => "*.rb"
      directory :from_dir => "vendor", :to_dir => "WEB-INF/vendor"

      directory :from_dir => "#{gem_home}/gems", :to_dir => "WEB-INF/gems/gems", :filter => included_gems(gems)
      directory :from_dir => "#{gem_home}/specifications", :to_dir => "WEB-INF/gems/specifications",
                :filter => included_specs(gems)
      directory :from_dir => "#{global_gem_home}/gems", :to_dir => "WEB-INF/gems/gems",
      :filter => included_global_gems
      directory :from_dir => "#{global_gem_home}/specifications", :to_dir => "WEB-INF/gems/specifications",
      :filter => included_global_specs

      directory :from_dir => "#{global_gem_home}/gems/jruby-openssl-#{JRUBY_OPENSSL_VERSION}/lib/shared",
                :to_dir => "WEB-INF/lib", :filter => "*.jar"
      directory :from_dir => "#{global_gem_home}/gems/bouncy-castle-java-#{BOUNCY_CASTLE_JAVA_VERSION}/lib",
                :to_dir => "WEB-INF/lib", :filter => "*.jar"
      directory :from_dir => "#{ruby_home}/lib", :to_dir => "WEB-INF/lib", :filter => "*.jar"

      config[:additional_java_jars].each do |jar|
        file :name => jar, :to_dir => "WEB-INF/lib"
      end if config[:additional_java_jars]

      directory :from_dir => "#{gem_home}/gems/jruby-rack-#{JRUBY_RACK_VERSION}/lib", :to_dir => "WEB-INF/lib", :filter => "*.jar"
      directory :from_dir => "#{gem_home}/gems/jruby-jars-#{JRUBY_JARS_VERSION}/lib", :to_dir => "WEB-INF/lib", :filter => "*.jar"

      jars(gems).each do |jar|
        file :name => jar, :to_dir => "WEB-INF/lib"
      end

      file :name => "#{basedir}/Gemfile", :to_dir => "WEB-INF"
      file :name => "#{basedir}/Gemfile.lock", :to_dir => "WEB-INF"

      directory :from_dir => "public"
    end
  end

  def process_templates dir
    configure

    with_dir(dir) do |entry_name|
      if entry_name == "META-INF"
        with_dir("#{dir}/META-INF") do |entry_name2|
          new_content = execute_template("#{dir}/META-INF/#{entry_name2}", binding)

          create_directory "#{build_dir}/META-INF/"

          write_content_to_file new_content, "#{build_dir}/META-INF/#{entry_name2}"
        end
      elsif entry_name == "WEB-INF"
        with_dir("#{dir}/WEB-INF") do |entry_name2|
          new_content = execute_template("#{dir}/WEB-INF/#{entry_name2}", binding)

          create_directory "#{build_dir}/WEB-INF/"

          write_content_to_file new_content, "#{build_dir}/WEB-INF/#{entry_name2}"
        end
      else
        new_content = execute_template("#{dir}/#{entry_name}", binding)

        write_content_to_file new_content, "#{build_dir}/#{entry_name}"
      end
    end if File.exist?(dir)
  end

  private

  def ruby_home
    ENV['MY_RUBY_HOME']
  end

  def gem_home
    ENV['GEM_HOME']
  end

  def global_gem_home gemset_name
    gem_home.gsub(gemset_name, 'global')
  end

  def included_global_gems
    "jruby-openssl-#{JRUBY_OPENSSL_VERSION}/**/*, bouncy-castle-java-#{BOUNCY_CASTLE_JAVA_VERSION}/**/*"
  end

  def included_global_specs
    "jruby-openssl-#{JRUBY_OPENSSL_VERSION}.gemspec, bouncy-castle-java-#{BOUNCY_CASTLE_JAVA_VERSION}.gemspec"
  end

  def included_gems gems
    gems.collect {|gem| "#{gem_folder(gem)}/**/*"}
  end

  def included_specs gems
    gems.collect {|gem| gem_spec(gem) }
  end

  def jars gems
    jars = []

    gems.each do |gem|
      gem_jars = Dir["#{gem.full_gem_path}/**/*.jar"]

      jars += gem_jars unless gem_jars.empty?
    end

    jars
  end

  def gem_folder gem
    "#{gem.name}-#{gem.version}#{(gem.platform.to_s == 'java') ? '-java' : ''}"
  end

  def gem_spec gem
    "#{gem.name}-#{gem.version}#{(gem.platform.to_s == 'java') ? '-java' : ''}.gemspec"
  end

  def bundler_gems
    orig_without_groups = Bundler.settings.without

    Bundler.settings.without = config[:groups_to_reject]

    gems = Bundler::Definition.build(Bundler.default_gemfile, Bundler.default_lockfile, nil).requested_specs

    new_gems = gems.reject do |gem|
      config[:gems_to_reject].include? gem.name
    end

    Bundler.settings.without = orig_without_groups

    new_gems
  end

end
