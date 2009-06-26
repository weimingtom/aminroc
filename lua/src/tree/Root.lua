-- 类定义
Root = Node:new({
	--[继承]公有属性
	---------------------------
		-- 类型
		type = NODE.TYPE.ROOT,
		-- 状态
		state = NODE.STATE.NORMAL,

	--[继承]接口
	---------------------------
		_nameSet = {},
		_indexSet ={},
});
-- 单一实例
ROOT = Root:new();

-- 结构配置
------------------------------
function TREE_CONFIG(obj)
	for key,value in pairs(obj) do
		-- 创建空间对象
		local z = Zone:new();
		-- 保存属性
		z.maxOnline = value.maxOnline;
		z.maxTeam = value.maxTeam;
		z.minUserForTeam = value.minUserForTeam;
		z.maxUserForTeam = value.maxUserForTeam;
		-- 更新状态
		z.name = key;
		z.state = NODE.STATE.NORMAL;
		z:updateInnerText();
		z:init();
		-- 添加子结点
		ROOT:appendChild(z);
	end

	PRINT.ITEM("game number",ROOT.numChildren);
end
