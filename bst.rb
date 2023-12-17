class Node
  include Comparable

  attr_accessor :data, :left, :right

  def initialize(data)
    @data = data
    @left = nil
    @right = nil
  end

  def <=>(other_node)
    @data <=> other_node.data
  end
end

class Tree
  attr_accessor :root

  def initialize(array)
    @root = build_tree(array)
  end

  def build_tree(array)
    array = array.uniq.sort
    return nil if array.empty?

    mid = array.length / 2
    root = Node.new(array[mid])
    root.left = build_tree(array[0...mid])
    root.right = build_tree(array[mid + 1..-1])
    root
  end

  def pretty_print(node = @root, prefix = '', is_left = true)
    pretty_print(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.data}"
    pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left
  end

  # Write an #insert and #delete method which accepts a value to insert/delete.
  # You’ll have to deal with several cases for delete, such as when a node has children or not.
  def insert(value, node = @root)
    if !(value.is_a? Integer)
      return nil
    end
    if node.nil?
      return Node.new(value)
    elsif value < node.data
      node.left = insert(value, node.left)
    elsif value > node.data
      node.right = insert(value, node.right)
    end

    node
  end

  def delete(value, node = @root)
    return nil if node.nil?

    if value < node.data
      node.left = delete(value, node.left)
    elsif value > node.data
      node.right = delete(value, node.right)
    else
      # Node with only one child or no child
      if node.left.nil?
        temp = node.right
        node = nil
        return temp
      elsif node.right.nil?
        temp = node.left
        node = nil
        return temp
      end

      # Node with two children: Get the in-order successor
      temp = min_value(node.right)

      # Copy the in-order successor's content to this node
      node.data = temp.data

      # Delete the in-order successor
      node.right = delete(temp.data, node.right)
    end

    node
  end

  # Write a #find method which accepts a value and returns the node with the given value.
  def find(value, node = @root)
    # Base Cases: root is null or key is present at root
    if node.nil? || node.data == value
      return node
    end

    # Key is greater than root's key
    if node.data < value
      return find(value, node.right)
    end

    # Key is smaller than root's key
    if node.data > value
      return find(value, node.left)
    end
  end

  # Write a #level_order method which accepts a block. This method should traverse the
  # tree in breadth-first level order and yield each node to the provided block.
  # This method can be implemented using either iteration or recursion (try implementing both!).
  # The method should return an array of values if no block is given.
  def level_order(&_block)
    if block_given?
      queue = []
      queue << @root
      while queue.any?
        current = queue.shift
        yield(current)
        queue << current.left unless current.left.nil?
        queue << current.right unless current.right.nil?
      end
    else
      result = []
      queue = []
      queue << @root
      while queue.any?
        current = queue.shift
        result << current.data
        queue << current.left unless current.left.nil?
        queue << current.right unless current.right.nil?
      end
      result
    end
  end

  # Write #inorder, #preorder, and #postorder methods that accepts a block. Each method should traverse the
  # tree in their respective depth-first order and yield each node to the provided block. The methods should
  # return an array of values if no block is given.

  def inorder(node = @root, &block)
    return [] unless node

    result = []
    result.concat(inorder(node.left, &block))
    if block_given?
      yield node
    else
      result << node.data
    end
    result.concat(inorder(node.right, &block))
  end

  def preorder(node = @root, &block)
    return [] unless node

    result = []
    if block_given?
      yield(node)

    else
      result << node.data
    end
    result.concat(preorder(node.left, &block))
    result.concat(preorder(node.right, &block))
  end

  def postorder(node = @root, &block)
    return [] unless node

    result = []
    result.concat(postorder(node.left, &block))
    result.concat(postorder(node.right, &block))

    if block_given?
      yield(node)
    else
      result << node.data
    end
  end

  # Write a #height method that accepts a node and returns its height. Height is defined as the number of edges in
  # longest path from a given node to a leaf node.
  def height(node)
    if node.nil?
      return -1
    else
      left_height = height(node.left)
      right_height = height(node.right)

      return left_height > right_height ? left_height + 1 : right_height + 1
    end
  end

  # Write a #depth method that accepts a node and returns its depth. Depth is defined as the number of edges in path
  # from a given node to the tree’s root node.
  def depth(node)
    if node.nil?
      return nil
    else
      current = @root
      depth = 0
      while current != node
        if node.data < current.data
          current = current.left
        else
          current = current.right
        end
        depth += 1
      end
      depth
    end
  end

  # Write a #balanced? method that checks if the tree is balanced. A balanced tree is one where the difference between
  # heights of left subtree and right subtree of every node is not more than 1.
  def balanced?(node = @root)
    return true if node.nil?

    left_height = height(node.left)
    right_height = height(node.right)

    # Check if current node is balanced
    is_current_balanced = (left_height - right_height).abs <= 1

    # Check if left and right subtrees are balanced
    is_left_balanced = balanced?(node.left)
    is_right_balanced = balanced?(node.right)

    # The tree is balanced if all conditions are met
    is_current_balanced && is_left_balanced && is_right_balanced
  end

  # Write a #rebalance method that rebalances an unbalanced tree. Tip: You’ll want to use a traversal method to provide
  # a new array to the #build_tree method.
  def rebalance
    array = inorder
    @root = build_tree(array)
  end

  private

  def min_value(node)
    current = node
    current = current.left while current.left
    current
  end
end

# Driver script
# 1/ Create a binary search tree from an array of random numbers (Array.new(15) { rand(1..100) })
tree = Tree.new(Array.new(15) { rand(1..100) })

# 2/ Confirm that the tree is balanced by calling #balanced?
puts "Balanced: #{tree.balanced?}"

# 3/ Print out all elements in level, pre, post, and in order
puts "Level order: #{tree.level_order}"
puts "Preorder: #{tree.preorder}"
puts "Postorder: #{tree.postorder}"
puts "Inorder: #{tree.inorder}"

# 4/ Unbalance the tree by adding several numbers > 100
tree.insert(101)
tree.insert(102)
tree.insert(103)
tree.insert(104)
tree.insert(105)

# 5/ Confirm that the tree is unbalanced by calling #balanced?
puts "Balanced: #{tree.balanced?}"

# 6/ Balance the tree by calling #rebalance
tree.rebalance

# 7/ Confirm that the tree is balanced by calling #balanced?
puts "Balanced: #{tree.balanced?}"

# 8/ Print out all elements in level, pre, post, and in order.
puts "Level order: #{tree.level_order}"
puts "Preorder: #{tree.preorder}"
puts "Postorder: #{tree.postorder}"
puts "Inorder: #{tree.inorder}"
