-- 树定义
NODE = {
	-- 结点类型
	TYPE = {
		ROOT = 1,				-- 根结点
		ZONE = 2,				-- 空间结点
		TEAM = 3,				-- 队伍结点
		USER = 4,				-- 用户结点
	},
	-- 状态
	STATE = {
		NORMAL		= 1,		-- 正常
		HIDDEN		= 2,		-- 隐藏
		RELEASE		= 3,		-- 释放

		WAIT		= 5,		-- 等待
		READY		= 6,		-- 准备
		PLAY		= 7,		-- 游戏

		SYNC_TIME	= 8,		-- 同步时间中
	},
	-- 身份
	STATUS = {
		UNDEFINED	= 1,		-- 未明确
		GUEST		= 2,		-- 游客
		MEMBER		= 3,		-- 会员
	},
	-- 网络状态
	NETWORK = {
		NORMAL		= 1,		-- 正常
		OFFLINE		= 0,		-- 断线
	},
}
