# frozen_string_literal: true

module DiverDown
  class Web
    class ConcurrencyWorker
      # @param concurrency [Integer]
      def initialize(concurrency: 10)
        @concurrency = concurrency
        @mutex = Mutex.new
      end

      # @param jobs [Array, Concurrent::Array]
      # @return [Hash]
      def run(jobs)
        queue = Queue.new
        jobs.each_with_index { queue << [_2, _1] }

        results = {}

        threads = Array.new(@concurrency) do
          Thread.new do
            # rubocop:disable Lint::AssignmentInCondition
            while !queue.empty? && poped = queue.pop
              index, job = poped
              result = yield(job)
              results[index] = result
            end
            # rubocop:enable Lint::AssignmentInCondition
          end
        end

        threads.each(&:join)

        ::Array.new(jobs.length) { results[_1] }
      end
    end
  end
end
