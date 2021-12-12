# frozen_string_literal: true

shared_context 'isolate_recipe' do
  unless @_shared_context_isolate_recipe_included
    @_shared_context_isolate_recipe_included = true

    #
    # Returns a boolean indicating whether or not to load attributes and
    # library functions from cookbook dependencies.  The default behavior
    # is to load all cookbook dependencies.
    #
    let(:load_cookbook_deps) { true }

    #
    # Returns a list of recipes that the runner is allowed to load.
    # Recipes are represented by strings of the format "Cookbook::Recipe".
    # All recipes are allowed to load if this function returns an empty
    # list.  The default behavior is to only allow the recipe in the RSpec
    # describe block to load.
    #
    # Note: "Cookbook" is not equivalent to "Cookbook::default" in this
    # list; you must always spell out the recipe name.
    #
    let(:allowed_recipes) { [described_recipe] }

    before(:example) do
      # Stub the depends methods of Chef::Cookbook::Metadata so it always
      # returns nil, indicating that there are no cookbook dependencies.
      # FIXME: Rewrite these to not use allow_any_instance_of.
      if load_cookbook_deps
        allow_any_instance_of(Chef::Cookbook::Metadata).to \
          receive(:depends).and_return(nil)
      end

      # Stub the load_recipe method of Chef::CookbookVersion with a
      # method that only loads the recipe when its name is listed in
      # allowed_recipes.
      unless allowed_recipes.empty?
        allow_any_instance_of(Chef::CookbookVersion).to \
          receive(:load_recipe).and_wrap_original do |method, *args|
          if allowed_recipes.include?("#{method.receiver.name}::#{args[0]}")
            method.call(*args)
          else
            false
          end
        end
      end
    end
  end
end
