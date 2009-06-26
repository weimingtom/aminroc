-- 类定义
Zone = Node:new({
	--[继承]公有属性
	---------------------------
		-- 类型
		type = NODE.TYPE.ZONE,
		-- 状态
		state = NODE.STATE.NORMAL,

	--公有属性
	---------------------------
		maxOnline = 0,
		maxTeam = 0,
		minUserForTeam = 0,
		maxUserForTeam = 0,
});

-- 初始化函数
function Zone:init()
	-- 私有属性
	self._argFreeIndex = {};		-- 可用索引
	self._nameSet = {};
	self._indexSet ={};
	self._cache = {};

	for i = self.maxTeam,1,-1 do
		table.insert(self._argFreeIndex,i);
	end
end

-- 添加子结点
function Zone:appendChild(n)
	-- 保存队伍索引
	n.index = table.remove(self._argFreeIndex);
	-- 调用父接口
	Node.appendChild(self,n);
end

-- 删除子结点
function Zone:removeChild(n)
	-- 保存队伍索引
	table.insert(self._argFreeIndex,n.index);
	-- 调用父接口
	Node.removeChild(self,n);
end

-- 是否满队
function Zone:isAppendChild()
	if self.numChildren >= self.maxTeam then
		return true;
	else
		return false;
	end
end

-- 是否满人
function Zone:isMaxOnline()
	local map = self[TreeEvent.ZONE_UPDATE];
	if not map then
		return false;
	end
	if map.length < self.maxOnline then
		return false
	end
	return true;
end

-- 更新显示
function Zone:updateDisplay(msg,times,node)
	if node then
		self._cache[node] = msg;
		local t = {};
		for k,v in pairs(self._cache) do
			table.insert(t,v);
		end
		self.style = table.concat(t,_1_);
	end
	-- 上传次数
	if times > 0 then
		-- 调用父接口
		local parent = self.parentNode;
		if parent then
			parent:updateDisplay(msg,times - 1,self);
		end
	end
end

