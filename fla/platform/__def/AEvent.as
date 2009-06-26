package __def{
	// 平台事件
	public final class AEvent{
		public static const REQUEST_TO:String				= '10';		// 请求进入
		public static const VALIDATE_ID:String				= '11';		// 验证身份

		public static const JOIN_ZONE:String				= '20';		// 加入空间
		public static const TEAM_LIST:String				= '21';		// 队伍列表
		public static const TEAM_NUMBER:String				= '22';		// 队伍数量

		public static const CREATE_TEAM:String				= '30';		// 创建队伍
		public static const JOIN_TEAM:String				= '31';		// 加入队伍
		public static const EXIT_TEAM:String				= '32';		// 退出队伍
		public static const USER_LIST:String				= '33';		// 用户列表
		public static const SWITCH_OWNER:String				= '34';		// 转换拥有权

		public static const READY:String					= '40';		// 准备
		public static const CANCEL:String					= '41';		// 取消
		public static const PLAY:String						= '42';		// 游戏(预留)
		public static const CHAT:String						= '43';		// 聊天
		public static const CHAT_TO:String					= '44';		// 指定聊天
		public static const REMOVE:String					= '45';		// 踢除用户

		public static const BROADCAST:String				= '50';		// 广播数据
		public static const BROADCAST_BUT_THIS:String		= '51';		// 广播数据(除了发送人)
		public static const SEND_TO:String					= '52';		// 发送数据
		public static const SEND_TO_AND_CC_THIS:String		= '53';		// 发送数据(且抄送给发送人)
		public static const EXIT_GAME:String				= '54';		// 退出游戏
		public static const REPLAY:String					= '55';		// 重玩游戏(预留)

		public static const SYNC_SERVER_TIME:String			= '60';		// 同步服务器时间

		public static const ISNOT_WAIT_STATUS:String		= '1010';	// 不是等待状态
		public static const ISNOT_READY_STATUS:String		= '1011';	// 不是准备状态
		public static const ISNOT_PLAY_STATUS:String		= '1012';	// 不是游戏状态

		public static const NOTEXIST_ZONE:String			= '1020';	// 无此空间
		public static const NOTEXIST_TEAM:String			= '1021';	// 无此队伍
		public static const NOTEXIST_CHAT_OBJECT:String		= '1022';	// 无此聊天对象
		public static const NOTEXIST_SENDTO_OBJECT:String	= '1023';	// 无此发送对象

		public static const EMPTY_BROADCAST_DATA:String		= '1030';	// 空广播数据
		public static const EMPTY_SENDTO_DATA:String		= '1031';	// 空发送数据

		public static const ERROR_MSG:String				= '1040';	// 明文错误
		public static const ERROR_USER_NAME:String			= '1041';	// 用户名字错误
		public static const ERROR_TEAM_NAME:String			= '1042';	// 队伍名字错误
		public static const ERROR_CHAT_DATA:String			= '1043';	// 聊天数据错误
		public static const ERROR_CHAT_OBJECT:String		= '1044';	// 聊天对象错误
		public static const ERROR_BROADCAST_DATA:String		= '1045';	// 广播数据错误
		public static const ERROR_SENDTO_DATA:String		= '1046';	// 发送数据错误

		public static const OVERFLOW_SOCKETS:String			= '1050';	// 连接溢出
		public static const OVERFLOW_TEAM:String			= '1051';	// 队伍溢出
		public static const OVERFLOW_USER:String			= '1052';	// 队员溢出

		public static const DENY_SWITCH_OWNER:String		= '1060';	// 队员溢出
	}
}