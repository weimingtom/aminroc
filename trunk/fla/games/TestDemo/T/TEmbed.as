/**
 * -----------------------------------------------------------------
 * 
 * 注意:最好在游戏的Event.ADDED_TO_STAGE事件触发后再调用类的函数
 * 
 * -----------------------------------------------------------------
 */
package T{
	// 导入公有包
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	// 主类
	public class TEmbed extends Sprite
	{
		// 调试标志
		public var debug:Boolean = false;
		// 平台应用程序接口
		private var API:* = null;
		/**
		 * 构造函数
		 */
		public function TEmbed(){
			addEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFromStage);
		}
		/**
		 * 添加到舞台
		 * @param {Event} e 事件
		 */
		private function OnAddedToStage(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			API = root.parent.parent;
			if(!API){
				debug = true;
			}
		}
		/**
		 * 从舞台中移除
		 * @param {Event} e 事件
		 */
		private function OnRemovedFromStage(e:Event):void{
			removeEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFromStage);
			API= null;
		}
		/**
		 * 把数据广播给所有人
		 * @param {string} data 发送的数据
		 */
		public function broadcast(data:String):void{
			// 请在正式版发布前去掉此区间的语句
			//---------------------------------------------------------
			if(!root){ trace('请将TEmbed的实例添加到舞台上!'); return;}
			if(debug){
				var e:TEvent = new TEvent(TEvent.Message);
				e.time = getTimer();
				e.delay = 0;
				e.fromIndex = getMyIndex();
				e.data = data;
				root.dispatchEvent(e);
				return
			}
			//---------------------------------------------------------
			API["broadcast"](data);
		}
		/**
		 * 把数据广播给除了自己之外的所有人
		 * @param {string} data 发送的数据
		 */
		public function broadcastButThis(data:String):void{
			// 请在正式版发布前去掉此区间的语句
			//---------------------------------------------------------
			if(!root){ trace('请将TEmbed的实例添加到舞台上!'); return;}
			if(debug){
				return
			}
			//---------------------------------------------------------
			API["broadcastButThis"](data);
		}
		/**
		 * 把数据发送给指定索引范围内的人
		 * @param {Array} range 用户索引数组,形式如[1,2,3...]
		 * @param {string} data 发送的数据
		 */
		public function sendTo(range:Array,data:String):void{
			// 请在正式版发布前去掉此区间的语句
			//---------------------------------------------------------
			if(!root){ trace('请将TEmbed的实例添加到舞台上!'); return;}
			if(debug){
				return
			}
			//---------------------------------------------------------
			API["sendTo"](range,data);
		}
		/**
		 * 把数据发送给指定索引范围内的人(且抄送给自己)
		 * @param {Array} range 用户索引数组,形式如[1,2,3...]
		 * @param {string} data 发送的数据
		 */
		public function sendToAndCcThis(range:Array,data:String):void{
			// 请在正式版发布前去掉此区间的语句
			//---------------------------------------------------------
			if(!root){ trace('请将TEmbed的实例添加到舞台上!'); return;}
			if(debug){
				var e:TEvent = new TEvent(TEvent.Message);
				e.time = getTimer();
				e.delay = 0;
				e.fromIndex = getMyIndex();
				e.data = data;
				root.dispatchEvent(e);
				return
			}
			//---------------------------------------------------------
			API["sendToAndCcThis"](range,data);
		}
		/**
		 * 退出游戏
		 */
		public function exitGame():void{
			// 请在正式版发布前去掉此区间的语句
			//---------------------------------------------------------
			if(!root){ trace('请将TEmbed的实例添加到舞台上!'); return;}
			if(debug){
				trace('已经退出游戏');
				return;
			}
			//---------------------------------------------------------
			API["exitGame"]();
		}
		/**
		 * 获取自己的索引
		 * @return {int} 索引
		 */
		public function getMyIndex():int{
			// 请在正式版发布前去掉此区间的语句
			//---------------------------------------------------------
			if(!root){ trace('请将TEmbed的实例添加到舞台上!'); return 0;}
			if(debug){
				return 1;
			}
			//---------------------------------------------------------
			return API["getMyIndex"]();
		}
		/**
		 * 获取所有用户信息
		 * @return {Array} 所有用户信息
		 */
		public function getUserInfos():Array{
			// 请在正式版发布前去掉此区间的语句
			//---------------------------------------------------------
			if(!root){ trace('请将TEmbed的实例添加到舞台上!'); return null;}
			if(debug){
				var u1:TUser = new TUser;u1.index = 1; u1.name = 'debug_1';
				var u2:TUser = new TUser;u2.index = 2; u2.name = 'debug_2';
				var u3:TUser = new TUser;u3.index = 3; u3.name = 'debug_3';
				var u4:TUser = new TUser;u4.index = 4; u4.name = 'debug_4';
				var u5:TUser = new TUser;u5.index = 5; u5.name = 'debug_5';
				var u6:TUser = new TUser;u6.index = 6; u6.name = 'debug_6';
				var u7:TUser = new TUser;u7.index = 7; u7.name = 'debug_7';
				var u8:TUser = new TUser;u8.index = 8; u8.name = 'debug_8';
				return [u1,u2,u3,u4,u5,u6,u7,u8];
			}
			//---------------------------------------------------------
			return API["getUserInfos"]();
		}
	}
}