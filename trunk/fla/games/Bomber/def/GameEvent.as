package def{
	// 导入包
	import flash.events.Event;
	// 主类
	public class GameEvent extends Event
	{
		// 事件类型
		public static const MOVE:String 			= '1';	// 移动
		public static const MOVETO:String 			= '2';	// 移动至目标
		public static const DROP_BOMB:String 		= '3';	// 丢炸弹
		public static const BE_BLAST:String 		= '4';	// 被炸到
		public static const BE_TOUTH:String 		= '5';	// 被触到
		public static const BE_FIRE:String 			= '6';	// 被撞到
		public static const OVER:String 			= '7';	// 结束
		
		// 事件参数
		public var src:*;
		
		// 构造函数
		public function GameEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false){
			super(type,bubbles,cancelable);
		}
	}
}