package T{
	// 导入公有包
	import flash.events.Event;
	// 主类
	public class TEvent extends Event
	{
		// 事件类型
		public static const Message:String 			= "TE_ME"; // 消息事件
		public static const OffLine:String  		= "TE_OL"; // 断线事件
		public static const Error:String 			= "TE_ER"; // 错误事件
		
		// 事件参数
		public var time:Number;		// 服务器公元时间
		public var delay:int;		// 收到此事件时的延时时间(非精确)
		public var fromIndex:int;	// 发送方的索引
		public var data:String;		// 收到数据
		public var errorNo:int;		// 错误编号
		
		// 构造函数
		public function TEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false){
			super(type,bubbles,cancelable);
		}
	}
}