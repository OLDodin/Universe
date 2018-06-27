local b   = {}
b.__index = b

local newLeaf = function(a)
	return setmetatable({
	value   = a,
	height  = 0,
	},b)
end

local getHeight = function(node)
	return node and node.height or -1
end

local setHeight = function(node)
	node.height = math.max(getHeight(node.left),getHeight(node.right))+1
end

local getBalance = function(node)
	return getHeight(node.right)-getHeight(node.left)
end

-- http://en.wikipedia.org/wiki/Tree_rotation
local rotateNode = function(root,rotation_side,opposite_side)
	local pivot           = root[opposite_side]
	root[opposite_side]   = pivot[rotation_side] 
	pivot[rotation_side]  = root
	root,pivot            = pivot,root
	setHeight(pivot);setHeight(root)
	return root
end
-- perform leaf check,height check,& rotation
local updateSubtree = function(root) 
	setHeight(root)
	local rotation_side,opposite_side,pivot,rotate_pivot
	local balance = getBalance(root)
	if balance > 1 then
		pivot = root.right
		if getBalance(pivot) < 0 then rotate_pivot = true end 
		rotation_side,opposite_side = 'left','right'
	elseif balance < -1 then
		pivot = root.left
		if getBalance(pivot) > 0 then rotate_pivot = true end
		rotation_side,opposite_side = 'right','left'
	end
	if rotation_side then
		if rotate_pivot then
			root[opposite_side] = rotateNode(pivot,opposite_side,rotation_side) 
		end
		root = rotateNode(root,rotation_side,opposite_side)
	end
	return root
end

b.add = function(self,a) -- Insert given element, return it if successful
	if not self or not self.value then
		return a,newLeaf(a)
	else
		if a < self.value then
			a,self.left   = b.add(self.left,a)
		elseif a > self.value then
			a,self.right  = b.add(self.right,a)
		else a = nil end
		return a,updateSubtree(self)
	end
end

b.delete = function(self,a)
	if self then 
		local v = self.value
		if a == v then 
			if not self.left or not self.right then
				return self.left or self.right
			else 
				local sNode = self.right
				while sNode.left do
					sNode	    = sNode.left
				end
				self        = b.delete(self,sNode.value)
				self.value  = sNode.value
				return self
			end
		else
			if a < v then
				self.left   = b.delete(self.left,a)
			else
				self.right  = b.delete(self.right,a)
			end
		end
		return updateSubtree(self)
	end
end

b.pop = function(self,side)
	local v
	if not self[side] then
		return self.value,self.left or self.right
	else
		v,self[side] = b.pop(self[side],side)
	end
	return v,updateSubtree(self)
end

b.peek = function(self,side)
	if not self[side] then
		return self.value
	else
		return b.peek(self[side],side)
	end
end

-- Find given element and return it
b.get = function(self,a)
	if self then
		if a == self.value then
			return a
		elseif a < self.value then
			return b.get(self.left,a)
		else
			return b.get(self.right,a)
		end
	end
end

local traverse
traverse = function(node,a,b)
	if node then
		traverse(node[a],a,b)
		coroutine.yield(node.value)
		traverse(node[b],a,b)
	end
end
-- tree traversal is in order by default (left,root,right)
b.iterate = function(self,mode)
	local a,b
	if not mode then 
		a,b = 'left','right'
	else 
		a,b = 'right','left' 
	end
	return coroutine.wrap(function()
		traverse(self,a,b)
	end)
end

-- http://stackoverflow.com/questions/1733311/pretty-print-a-tree
b.printTree = function(self,depth)
	depth = depth or 1
	if self then 
		b.printTree(self.right,depth+1)
		print(string.format("%s%d",string.rep("  ",depth), self.value))
		b.printTree(self.left,depth+1)
	end	
end

GetAVLTree = function()
	local t = { -- proxy table for tree
		root   = newLeaf(),
		add    = function(self,a)
			a,self.root = self.root:add(a)
			return a
		end,
		delete = function(self,a)
			self.root = self.root:delete(a) or newLeaf()
		end,
		pop    = function(self,side)
			assert(side,'No side specified!')
			a,self.root = self.root:pop(side)
			return a
		end,
	}
	return setmetatable(t,{__index = function(t,k) return t.root[k] end})
end