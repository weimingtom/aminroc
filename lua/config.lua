-- 最大用户名字长度(汉字 / 2)
MAX_USER_NAME_LEN = 20;

-- 最大队伍名字长度(汉字 / 2)
MAX_TEAM_NAME_LEN = 20;

-- 最大聊天文字长度(汉字 / 2)
MAX_TEAM_CHAT_LEN = 60;

-- 密钥文件
KEY = 'keys/090427';

-- 调试模式
__DEBUG__ = true;

-- 结构配置
TREE_CONFIG{
	['TestDemo'] = {
		maxOnline = 9000,		-- 最多在线人数
		maxTeam = 1500,			-- 最多可用队伍
		minUserForTeam = 2,		-- 最少游戏人数
		maxUserForTeam = 8,		-- 最多游戏人数
	},
	['Bomber'] = {
		maxOnline = 9000,
		maxTeam = 1500,
		minUserForTeam = 2,
		maxUserForTeam = 4,
	},
}
