require 'rails/generators/base'

module DeviseFidoUsf
  module Generators
    MissingORMError = Class.new(Thor::Error)

    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Creates a FIDO U2F initializer for devise and copy locale files to your application."
      class_option :orm

      def copy_initializer
        unless options[:orm]
          raise MissingORMError, <<-ERROR.strip_heredoc
          An ORM must be set to install Devise in your application.

          Be sure to have an ORM like Active Record or Mongoid loaded in your
          app or configure your own at `config/application.rb`.

            config.generators do |g|
              g.orm :your_orm_gem
            end
          ERROR
        end

      end

      def add_application_helper
        in_root do
          inject_into_module "app/helpers/application_helper.rb", ApplicationHelper, application_helper_data
        end
      end

      def copy_locale
        copy_file "../../../config/locales/en.yml", "config/locales/fido_usf.en.yml"
      end

      def run_migration
        generate "devise_fido_usf:migrate", "FidoUsfDevices"
      end

      def show_readme
        readme "README" if behavior == :invoke
      end

      def application_helper_data
<<RUBY

  def u2f
    # use base_url as app_id, e.g. 'http://localhost:3000'
    @u2f ||= U2F::U2F.new(request.base_url)
  end
RUBY
      end
    end
  end
end

