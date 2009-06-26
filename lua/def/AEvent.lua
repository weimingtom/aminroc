-- 事件定义
AEvent = {

------------------------------------------------------------------------------------------
--
-- 正确
--
------------------------------------------------------------------------------------------
	REQUEST_TO			= '10',		-- 请求进入
	VALIDATE_ID			= '11',		-- 验证身份

	JOIN_ZONE			= '20',		-- 加入空间
	TEAM_LIST			= '21',		-- 队伍列表
	TEAM_NUMBER			= '22',		-- 队伍数量

	CREATE_TEAM			= '30',		-- 创建队伍
	JOIN_TEAM			= '31',		-- 加入队伍
	EXIT_TEAM			= '32',		-- 退出队伍
	USER_LIST			= '33',		-- 用户列表
	SWITCH_OWNER		= '34',		-- 转换拥有权

	READY				= '40',		-- 准备
	CANCEL				= '41',		-- 取消
	PLAY				= '42',		-- 游戏(预留)
	CHAT				= '43',		-- 聊天
	CHAT_TO				= '44',		-- 指定聊天
	REMOVE				= '45',		-- 踢除用户

	BROADCAST			= '50',		-- 广播数据
	BROADCAST_BUT_THIS	= '51',		-- 广播数据(除了发送人)
	SEND_TO				= '52',		-- 发送数据
	SEND_TO_AND_CC_THIS = '53',		-- 发送数据(且抄送给发送人)
	EXIT_GAME			= '54',		-- 退出游戏
	REPLAY				= '55',		-- 重玩游戏(预留)

	SYNC_SERVER_TIME	= '60',		-- 同步服务器时间

------------------------------------------------------------------------------------------
--
-- 错误
--
------------------------------------------------------------------------------------------
	ISNOT_WAIT_STATUS		= '1010',		-- 不是等待状态
	ISNOT_READY_STATUS		= '1011',		-- 不是准备状态
	ISNOT_PLAY_STATUS		= '1012',		-- 不是游戏状态

	NOTEXIST_ZONE			= '1020',		-- 无此空间
	NOTEXIST_TEAM			= '1021',		-- 无此队伍
	NOTEXIST_CHAT_OBJECT	= '1022',		-- 无此聊天对象
	NOTEXIST_SENDTO_OBJECT	= '1023',		-- 无此发送对象

	EMPTY_BROADCAST_DATA	= '1030',		-- 空广播数据
	EMPTY_SENDTO_DATA		= '1031',		-- 空发送数据

	ERROR_MSG				= '1040',		-- 明文错误
	ERROR_USER_NAME			= '1041',		-- 用户名字错误
	ERROR_TEAM_NAME			= '1042',		-- 队伍名字错误
	ERROR_CHAT_DATA			= '1043',		-- 聊天数据错误
	ERROR_CHAT_OBJECT		= '1044',		-- 聊天对象错误
	ERROR_BROADCAST_DATA	= '1045',		-- 广播数据错误
	ERROR_SENDTO_DATA		= '1046',		-- 发送数据错误

	OVERFLOW_SOCKETS		= '1050',		-- 连接溢出
	OVERFLOW_TEAM			= '1051',		-- 队伍溢出
	OVERFLOW_USER			= '1052',		-- 队员溢出

	OVERFLOW_USER			= '1052',		-- 队员溢出

	DENY_SWITCH_OWNER		= '1060',		-- 拒绝更改拥有者
	DENY_REMOVE				= '1070',		-- 拒绝踢除用户
}
