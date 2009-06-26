-- 类定义
Team = Node:new({
	--[继承]公有属性
	---------------------------
		-- 类型
		type = NODE.TYPE.TEAM,
		-- 状态
		state = NODE.STATE.NORMAL,

	--公有属性
	---------------------------
		minUserForTeam = 0,
		maxUserForTeam = 0,
		time = 0,
		owner = 0,
});

-- 初始化函数
function Team:init()
	-- 私有属性
	self._argFreeIndex = {};	-- 可用索引
	self._nameSet = {};
	self._indexSet = {};
	self._cache = {};

	for i = self.maxUserForTeam,1,-1 do
		table.insert(self._argFreeIndex,i);
	end
end

-- 添加子结点
function Team:appendChild(n)
	-- 保存队伍索引
	n.index = table.remove(self._argFreeIndex);
	-- 调用父接口
	Node.appendChild(self,n);
end

-- 删除子结点
function Team:removeChild(n)
	-- 保存队伍索引
	table.insert(self._argFreeIndex,1,n.index);
	-- 调用父接口
	Node.removeChild(self,n);
end

-- 是否满员
function Team:isAppendChild()
	if self.numChildren >= self.maxUserForTeam then
		return true;
	else
		return false;
	end
end

-- 用户消息
function Team:OnUserMsg()

end

-- 广播事件
function Team:broadcast(dataEx)
	for k,v in pairs(self._indexSet) do
		CNetSend(v.socket,dataEx);
	end
end

-- 广播事件(除了指定之外)
function Team:broadcastButThis(user,dataEx)
	for k,v in pairs(self._indexSet) do
		if k ~= user.index then
			CNetSend(v.socket,dataEx);
		end
	end
end

-- 广播事件(根据状态)
function Team:broadcastByState(dataEx,state)
	for k,v in pairs(self._indexSet) do
		if v.state == state then
			CNetSend(v.socket,dataEx);
		end
	end
end

-- 广播事件(根据状态)(除了指定之外)
function Team:broadcastByStateButThis(exception,dataEx,state)
	for k,v in pairs(self._indexSet) do
		if v ~= exception and v.state == state then
			CNetSend(v.socket,dataEx);
		end
	end
end

-- 全部都是指定状态
function Team:isAll(state)
	for k,v in pairs(self._indexSet) do
		if v.state ~= state then
			return false
		end
	end
	return true;
end

-- 全部都不是指定状态
function Team:isAllNot(state)
	for k,v in pairs(self._indexSet) do
		if v.state == state then
			return false
		end
	end
	return true;
end

-- 格式化
function Team:toString()
	return self.state .._2_.. self.index .._2_.. self.name .._2_.. self.numChildren .._2_.. self.maxUserForTeam;
end

-- 更新显示
function Team:updateDisplay(msg,time,node)
	if node then
		self._cache[node] = msg;
		local t = {};
		for k,v in pairs(self._cache) do
			table.insert(t,v);
		end
		self.style = table.concat(t,_1_);
	end
	-- 上传次数
	if time > 0 then
		-- 调用父接口
		local parent = self.parentNode;
		if parent then
			parent:updateDisplay(msg,time - 1,self);
		end
	end
end

-- 更新所有子结点
function Team:setAllChildState(state)
	for k,v in pairs(self._indexSet) do
		v.state = state;
		v:updateDisplay(v:toString(),1);
	end
end

-- 更新所有子结点
function Team:setAllChildPos(pos)
	for k,v in pairs(self._indexSet) do
		v.pos = pos;
	end
end


