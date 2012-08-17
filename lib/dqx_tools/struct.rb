module DQXTools
  class Struct
    class << self
      def keys
        @keys ||= []
      end

      def _map
        @map ||= Proc.new{|k, x| x }
      end

      private

      def attributes(*args)
        @keys = args.freeze
      end

      def map(&block)
        @map = block
      end
    end

    def initialize(values={})
      if values.is_a?(Array)
        @hash = Hash[values.zip(self.class.keys).map(&:reverse)]
      else
        @hash = values
      end

      map = self.class._map
      @hash = @hash.each.with_object({}) do |(key, value), o|
        o[key] = map.arity > 1 ? map[key, value] : map[value]
      end

      klass = self.singleton_class
      self.class.keys.each do |key|
        klass.send(:define_method, key) { @hash[key] }
      end
    end

    def inspect; "#<#{self.class.name}: #{@hash.inspect}>"; end
  end
end

