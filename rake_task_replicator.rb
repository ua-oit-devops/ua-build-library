# frozen_string_literal: true

module UaBuildLibrary
  # RakeTaskReplicator creates a copy of a Rake::Task, optionally allowing
  # you to modify the attributes used to create the copy.
  class RakeTaskReplicator
    attr_accessor :name, :args, :prereqs, :order_only_prereqs, :actions,
                  :comments

    def initialize(task)
      @name = task.name
      @args = task.arg_names
      @prereqs = task.prereqs
      @order_only_prereqs = task.order_only_prerequisites
      @actions = task.actions
      @comments = task.full_comment&.split("\n") || []
    end

    def with_name(name)
      @name = name
      self
    end

    def with_args(args)
      @args = (args || []).to_a
      self
    end

    def with_prereqs(prereqs)
      @prereqs = (prereqs || []).to_a
      self
    end

    def with_order_only_prereqs(prereqs)
      @order_only_prereqs = (prereqs || []).to_a
      self
    end

    def with_comments(comments)
      @comments = (comments || []).to_a
      self
    end

    def with_actions(actions)
      @actions = (actions || []).to_a
      self
    end

    def add_action(&block)
      @actions << block
    end

    def create
      task = Rake::Task.define_task(
        name,
        args => prereqs,
        order_only: order_only_prereqs
      )
      actions.each { |block| task.enhance(&block) }
      comments.each { |cmt| task.add_description(cmt) }
    end
  end
end
