package __src{
	// 导入包
	import T.*;
	
	import __def.*;
	
	import com.al.ANet;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	import flash.utils.*;
	
	// 主类
	public class GameScene extends Sprite{
	/**接口变量
	---------------------------*/
		// 通讯管道
		private var net:ANet;
		// 游戏对象
		private var game:URLLoader;
		// 所有用户信息
		private var userInfos:Array;
		// 队伍信息
		private var myTeam:MyTeam;
		// 时间信息
		private var myTime:MyTime;
		// 在退出游戏之前调用的函数
		private var beforeExitGame:Function;
		
	/**私有变量
	---------------------------*/
		// 是否游戏中
		private var gaming:Boolean = false;
		// 游戏实例
		private var ins:Loader = new Loader;
				
	/**构造 & 析构
	---------------------------*/
		// 构造函数
		public function GameScene(n:ANet,g:URLLoader,ui:Array,mt:MyTeam,mti:MyTime,be:Function):void{
			addEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFormStage);
			
			this.net = n;
			this.game = g;
			this.userInfos = ui;
			this.myTeam = mt;
			this.myTime = mti;
			this.beforeExitGame = be;
		}
		// 添加到舞台
		private function OnAddedToStage(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			
			ins.contentLoaderInfo.addEventListener(Event.COMPLETE,OnComplete_Create);
			ins.loadBytes(game.data);
		}
		// 析构函数
		private function OnRemovedFormStage(e:Event):void{
			removeEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFormStage);
			
			this.net = null;
			this.game = null;
			this.userInfos = null;
			this.myTeam = null;
			this.myTime = null;
			
			this.ins.parent.removeChild(ins);
			this.ins.unload();
			this.ins = null;
		}
		
	/**公共函数
	---------------------------*/
		// 消息
		public function message(dataEx:String):void{
			if(!ins.content){return;}
			// 分析消息
			var arg:Array = dataEx.split(ANet._1_,3);
			// 创建事件
			var e:TEvent = new TEvent(TEvent.Message);
			// 设置属性
			e.time = parseInt(arg[0]);
			e.delay = (myTime.so + (getTimer() - myTime.co)) - e.time;
			e.fromIndex = parseInt(arg[1]);
			e.data = arg[2];
			// 触发事件
			ins.content.dispatchEvent(e);
		}
		// 断线
		public function offLine(index:int):void{
			if(!ins.content){return;}
			// 创建事件
			var e:TEvent = new TEvent(TEvent.OffLine)
			// 设置属性
			e.fromIndex = index;
			// 触发事件
			ins.content.dispatchEvent(e);
		}
		// 错误
		public function error(errorNo:int,dataEx:String):void{
			if(!ins.content){return;}
			// 创建事件
			var e:TEvent = new TEvent(TEvent.Error);
			// 设置属性
			e.errorNo = errorNo;
			e.data = dataEx;
			// 触发事件
			ins.content.dispatchEvent(e);
		}
		
	/**私有函数
	---------------------------*/
		// 影片加载完成
		private function OnComplete_Create(e:Event):void{
			ins.contentLoaderInfo.removeEventListener(Event.COMPLETE,OnComplete_Create);
			// 获取游戏帧速
			stage.frameRate = ins.contentLoaderInfo.frameRate;
			// 创建游戏的X,Y轴的起点
		 	ins.x = (stage.stageWidth - ins.contentLoaderInfo.width) / 2;
		 	ins.y = (stage.stageHeight - ins.contentLoaderInfo.height) / 2;
			// 创建蒙板
			var mb:Shape = new Shape();
			mb.graphics.beginFill(0xFFFFFF);
			mb.graphics.drawRect(ins.x,ins.y,ins.contentLoaderInfo.width,ins.contentLoaderInfo.height);
			mb.graphics.endFill();
			addChild(mb);
			// 指定蒙板
			ins.mask = mb;
			// 不显示焦点矩形
			ins.focusRect = false;
			// 更新游戏标志
			gaming = true;
			// 加入影片
			addChild(ins);
			// 聚焦游戏
			stage.focus = ins;
		}
		
	/**接口实现函数
	---------------------------*/
		/**
		 * 把数据广播给所有人
		 * @param {string} data 发送的数据
		 */
		public function broadcast(data:String):void{
			gaming && net.send(AEvent.BROADCAST + ANet._EN_ + data);
		}
		/**
		 * 把数据广播给除了自己之外的所有人
		 * @param {string} data 发送的数据
		 */
		public function broadcastButThis(data:String):void{
			gaming && net.send(AEvent.BROADCAST_BUT_THIS + ANet._EN_ + data);
		}
		/**
		 * 把数据发送给指定索引范围内的人
		 * @param {Array} range 用户索引数组,形式如[1,2,3...]
		 * @param {string} data 发送的数据
		 */
		public function sendTo(range:Array,data:String):void{
			gaming && net.send(AEvent.SEND_TO + ANet._EN_ + range.join(ANet._2_) + ANet._1_ + data);
		}
		/**
		 * 把数据发送给指定索引范围内的人(且抄送给自己)
		 * @param {Array} range 用户索引数组,形式如[1,2,3...]
		 * @param {string} data 发送的数据
		 */
		public function sendToAndCcThis(range:Array,data:String):void{
			gaming && net.send(AEvent.SEND_TO_AND_CC_THIS + ANet._EN_ + range.join(ANet._2_) + ANet._1_ + data);
		}
		/**
		 * 游戏结束
		 */
		public function exitGame():void{
			if(gaming){
				gaming = false;
				beforeExitGame();
				net.send(AEvent.EXIT_GAME);
			}
		}
		/**
		 * 获取自己的索引
		 * @return {int} 索引
		 */
		public function getMyIndex():int{
			return gaming ? this.myTeam.myIndex : 0;
		}
		/**
		 * 获取所有用户信息
		 * @return {Array} 所有用户信息
		 */
		public function getUserInfos():Array{
			return gaming ? this.userInfos : null;
		}
	}
}