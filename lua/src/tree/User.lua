-- 类定义
User = Node:new({
	--[继承]公有属性
	---------------------------
		-- 类型
		type = NODE.TYPE.USER,
		-- 状态
		state = NODE.STATE.NORMAL,
		-- 身份标识
		status	= NODE.STATUS.GUEST,
		-- 连接状态
		network = NODE.NETWORK.NORMAL,

	--公有属性
	---------------------------
		-- 所在树节点
		tree = 0,
		-- socket
		socket = 0,
		-- 明文
		msg = '',
		-- 位置
		pos = USER.POS.FREE,
});

-- 格式化
function User:toString()
	return self.state .._2_.. self.index .._2_.. self.name;
end

-- 更新显示
function User:updateDisplay(msg,times,node)
	if node and msg then
		self._cache[root] = msg;
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
