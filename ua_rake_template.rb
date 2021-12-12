# frozen_string_literal: true

require 'rake'
require_relative 'config'
require_relative 'rake_task_replicator'

module UaBuild
  # RakeTemplates allows you to import rake tasks from a centrally managed
  # repository.
  class RakeTemplate
    include UaBuildLibrary

    attr_accessor :excluded

    # def initialize(repotype=nil, layout=nil)
    #   repotype ||= UaBuild::Config['type']
    #   layout   ||= UaBuild::Config['layout']
    def initialize(repotype = UaBuild::Config['type'],
                   layout = UaBuild::Config['layout'])
      template_dir = File.join('templates', repotype.to_s, layout.to_s)
      @rakefile = File.join(__dir__, template_dir, 'template.rake')
      @excluded = {}

      # Create .../uabuild/library/CURRENT symlink.
      current_link = File.join(__dir__, 'CURRENT')
      File.symlink(template_dir, current_link) unless File.exist?(current_link)

      # Create .../uabuild/library/CURRENT/COMMON symlink.
      common_dir = File.join(__dir__, 'common')
      common_link = File.join(current_link, 'COMMON')
      File.symlink(common_dir, common_link) unless File.exist?(common_link)
    end

    def template
      @template ||= Rake.with_application do |_app|
        load(@rakefile)
      end
    end

    def tasks
      @tasks ||= template.tasks.each_with_object({}) do |v, m|
        m[v.name.to_s] = v
      end
    end

    def exclude_tasks(*task_names)
      task_names.each { |name| excluded[name] = true }
    end

    def define_task(task_name)
      return if excluded[task_name]

      task = RakeTaskReplicator.new(@tasks[task_name])
      task.prereqs.reject! { |p| excluded[p] }
      task.order_only_prereqs.reject! { |p| excluded[p] }
      task.create
    end

    def recursive_prereqs(task_name, prereqs = [])
      return prereqs unless tasks.include? task_name

      task = tasks[task_name]
      (task.prereqs + task.order_only_prerequisites).each do |name|
        next if prereqs.include?(name) || excluded[name]

        prereqs << name
        recursive_prereqs(name, prereqs)
      end
      prereqs
    end

    def define_common_tasks
      recursive_prereqs('_COMMON_').each { |name| define_task(name) }
    end

    # disable_synthetic_file_tasks mokey-patches the method in rake
    # responsible for creating implicit FileTask definitions so that it
    # instead does nothing.
    #
    # Rake implicitly defines no-op tasks matching the names of files and
    # directories on the file system.  Having `rake test` do nothing but exit
    # with a success status because a `test` directory exists on the file
    # system can be disasterous for a build pipeline.
    def disable_synthetic_file_tasks
      Rake::TaskManager.module_eval do
        def synthesize_file_task(task_name); end
      end
    end
  end
end
