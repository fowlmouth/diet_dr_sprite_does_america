class Test
	def mx
		return @x
	end
	
	def mx=(value)
		@x = value
	end
	
	def update
		puts "Before: #{mx}"
		puts "After: #{mx}"
	end
	
	def initialize
		@x = @y = 0
	end
end

t = Test.new
t.update
