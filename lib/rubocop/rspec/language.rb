# frozen_string_literal: true

module RuboCop
  module RSpec
    # RSpec public API methods that are commonly used in cops
    module Language
      # Set of method selectors
      class SelectorSet
        def initialize(selectors)
          @selectors = selectors.freeze
          freeze
        end

        def ==(other)
          selectors.eql?(other.selectors)
        end

        def +(other)
          self.class.new(selectors + other.selectors)
        end

        def include?(selector)
          selectors.include?(selector)
        end

        def block_pattern
          "(block #{send_pattern} ...)"
        end

        def block_pass_pattern
          "(send #rspec? #{node_pattern_union} _ block_pass)"
        end

        def block_or_block_pass_pattern
          "{#{block_pattern} #{block_pass_pattern}}"
        end

        def send_pattern
          "(send #rspec? #{node_pattern_union} ...)"
        end

        def send_or_block_or_block_pass_pattern
          "{#{send_pattern} #{block_pattern} #{block_pass_pattern}}"
        end

        def node_pattern_union
          "{#{node_pattern}}"
        end

        def node_pattern
          selectors.map(&:inspect).join(' ')
        end

        def to_a
          selectors
        end

        protected

        attr_reader :selectors
      end

      module ExampleGroups
        GROUPS  = SelectorSet.new(%i[describe context feature example_group])
        SKIPPED = SelectorSet.new(%i[xdescribe xcontext xfeature])
        FOCUSED = SelectorSet.new(%i[fdescribe fcontext ffeature])

        ALL = GROUPS + SKIPPED + FOCUSED
      end

      module SharedGroups
        EXAMPLES = SelectorSet.new(%i[shared_examples shared_examples_for])
        CONTEXT = SelectorSet.new(%i[shared_context])

        ALL = EXAMPLES + CONTEXT
      end

      module Includes
        EXAMPLES = SelectorSet.new(
          %i[
            it_behaves_like
            it_should_behave_like
            include_examples
          ]
        )
        CONTEXT = SelectorSet.new(%i[include_context])

        ALL = EXAMPLES + CONTEXT
      end

      module Examples
        EXAMPLES = SelectorSet.new(%i[it specify example scenario its])
        FOCUSED  = SelectorSet.new(%i[fit fspecify fexample fscenario focus])
        SKIPPED  = SelectorSet.new(%i[xit xspecify xexample xscenario skip])
        PENDING  = SelectorSet.new(%i[pending])
        API_DOC  = SelectorSet.new(%i[example_request])

        ALL = EXAMPLES + FOCUSED + SKIPPED + PENDING + API_DOC
      end

      module Hooks
        ALL = SelectorSet.new(
          %i[
            prepend_before
            before
            append_before
            around
            prepend_after
            after
            append_after
          ]
        )

        module Scopes
          ALL = SelectorSet.new(
            %i[
              each
              example
              context
              all
              suite
            ]
          )
        end
      end

      module Helpers
        ALL = SelectorSet.new(%i[let let!])
      end

      module Subject
        ALL = SelectorSet.new(%i[subject subject!])
      end

      module Expectations
        ALL = SelectorSet.new(%i[expect is_expected expect_any_instance_of])
      end

      module Runners
        ALL = SelectorSet.new(%i[to to_not not_to])
      end

      ALL =
        ExampleGroups::ALL +
        SharedGroups::ALL  +
        Examples::ALL      +
        Hooks::ALL         +
        Helpers::ALL       +
        Subject::ALL       +
        Expectations::ALL  +
        Runners::ALL
    end
  end
end
