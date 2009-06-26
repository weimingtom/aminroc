-- 类定义
Node = {
	--公有属性
	---------------------------
		type = 0,			-- 类型
		index = 0,			-- 相对父结束的索引
		name = 0,			-- 名字
		state = 0,			-- 状态
		status = 0,			-- 身份
		network = 0,		-- 网络状态
		style = '',			-- 样式
		numChildren = 0,	-- 子结点数量
		parentNode = 0,		-- 父结点引用

	--内部属性
	---------------------------
		-- 引用资料
		_refCount = 0,

	-- 接口
	---------------------------
		_nameSet = nil,
		_indexSet = nil,
		_cache = nil,
}

-- 创建对象
function Node:new(struct)
	local s = struct or {};
	setmetatable(s,self);
	self.__index = self;
	return s;
end

-- 添加子结点
function Node:appendChild(n)
	-- 检查
	if n.parentNode ~= 0 then
		n.parentNode:removeChild(n);
	end
	-- 自身
	self.numChildren = self.numChildren + 1;
	self._nameSet[n.name] = n;
	self._indexSet[n.index] = n;
	-- 子结点
	n.parentNode = self;
	n._refCount = n._refCount + 1;
end

-- 删除子结点
function Node:removeChild(n)
	-- 自身
	self.numChildren = self.numChildren - 1;
	self._nameSet[n.name] = nil;
	self._indexSet[n.index] = nil;
	-- 子结点
	n.parentNode = 0;
	n._refCount = n._refCount - 1;
end

-- 克隆
function Node:clone()
	return false;
end

-- 添加事件监视
function Node:addEventListener(event)
	local tree = self.tree;
	local map = tree[event];

	if not map then
		tree[event] = {};
		map = tree[event];
		map.set = {}
		map.length = 0;
	end

	map.set[self] = 1;
	map.length = map.length + 1;
	return true;
end

-- 删除事件监视
function Node:removeEventListener(event)
	local tree = self.tree;
	local map = tree[event];

	map.set[self] = nil;
	map.length = map.length - 1;
end

-- 派发事件
function Node:dispatchEvent(event,dataEx)
	local tree = self;
	local set = tree[event].set;

	for k,v in pairs(set) do
		CNetSend(k.socket,dataEx);
	end
end

-- 字符串格式化
function Node:toString()
	return nil;
end

-- 设置属性
function Node:setAttribute(name,v)
	rawset(self,name,v);
end

-- 移除属性
function Node:removeAttribute(name)
	self[name] = nil;
end

-- 读取属性
function Node:getAttribute(name)
	return self[name];
end

-- 根据名字返回子结点
function Node:getChildByName(name)
	return self._nameSet[name];
end

-- 根据名字返回子结点
function Node:getChildByIndex(index)
	return self._indexSet[index];
end

-- 返回第一个子结点
function Node:firstChild()
	for k,v in pairs(self._indexSet) do
		return v;
	end
end


-- 更新内部文本
function Node:updateInnerText()
end

-- 更新外部文本
function Node:updateOuterText()
end

-- 更新显示
function Node:updateDisplay()
end
