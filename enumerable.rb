module Enumerable
  def my_each
    return to_enum(:my_each) unless block_given?

    count = 0
    is_2darr = false
    is_2darr = true unless self.class == Array
    if is_2darr
      t_arr = to_a
      until count == t_arr.length
        yield(t_arr[count][0], t_arr[count][1])
        count += 1
      end
    else
      until count == length
        yield(self[count])
        count += 1
      end
    end
    self.class == Range ? self : to_a
  end

  def my_each_with_index
    return to_enum(:my_each_with_index) unless block_given?

    count = 0
    is_2darr = false
    is_2darr = true unless self.class == Array
    if is_2darr
      t_arr = to_a
      until count == t_arr.length
        yield(t_arr[count], count)
        count += 1
      end
    else
      until count == length
        yield(self[count], count)
        count += 1
      end
    end
    self
  end

  def my_select
    return to_enum(:my_select) unless block_given?

    arr = to_a
    temp_a = []
    temp_h = {}
    is_2darr = false
    is_2darr = true unless arr.class == Array
    is_2darr == true ? arr.my_each { |x, y| temp_h[x] = y if yield(x, y) } : arr.my_each { |x| temp_a << x if yield(x) }
    is_2darr == false ? temp_a : temp_h
  end

  def my_all?(*datatype)
    block = create_block if !block_given? && datatype.empty?
    return my_all?(&block) unless block.nil?

    if is_a? Array
      my_each do |x|
        unless datatype.empty?
          return false if ((datatype[0].is_a? Class) && !(x.is_a? datatype[0])) ||
                          ((datatype[0].is_a? Regexp) && x.to_s.match(datatype[0]).nil?) ||
                          !((datatype[0].is_a? Class) || (datatype[0].is_a? Regexp) || (x == datatype[0]))

          next
        end
        return false unless yield(x)
      end
    else
      my_each do |x, y|
        return false if !datatype.empty? || (datatype.empty? && !yield(x, y))
      end
    end
    true
  end

  def my_any?(*datatype)
    block = create_block if !block_given? && datatype.empty?
    return my_any?(&block) unless block.nil?

    arr = to_a
    if arr.is_a? Array
      arr.my_each do |x|
        unless datatype.empty?
          return true if ((datatype[0].is_a? Class) && (x.is_a? datatype[0])) ||
                         ((datatype[0].is_a? Regexp) && !x.to_s.match(datatype[0]).nil?) ||
                         (!((datatype[0].is_a? Class) || (datatype[0].is_a? Regexp)) && (x == datatype[0]))

          next
        end

        return true if yield(x)
      end
    else
      arr.my_each do |x, y|
        return true if block_given? && yield(x, y)
      end
    end
    false
  end

  def my_none?(*datatype, &test)
    !my_any?(*datatype, &test)
  end

  def my_count(*value)
    return to_a.length if !block_given? && value.empty?

    count = 0
    to_a.my_each { |x| count += 1 if x == value[0] } unless value.empty?
    to_a.my_each { |x, y| count += 1 if yield(x, y) } if block_given?
    count
  end

  def my_map
    return to_enum(:my_map) unless block_given?

    res_arr = []
    to_a.my_each { |x| res_arr << yield(x) }
    res_arr
  end

  def my_inject(*value)
    raise ArgumentError, "wrong number of argumets (given #{value.length}, expected 0..2" if value.length > 2

    memo = value.length == 2 || ((value.length == 1) && (((value[0].is_a? String) && block_given?) || (!value[0].is_a? Symbol))) ? value[0] : nil
    if !value.empty? && (value[-1].class == Symbol || value[-1].class == String)
      to_a.my_each do |x|
        memo = memo.nil? ? x : memo.send(value[-1], x)
      end
      return memo
    end
    to_a.my_each do |x|
      memo = memo.nil? ? x : yield(memo, x)
    end
    memo
  end

  protected

  def create_block
    exproc = proc do |x|
      x
    end
    exproc
  end
end
