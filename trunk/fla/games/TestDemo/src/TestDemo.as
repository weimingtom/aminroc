/**
 * Developed by AminLab
 * ------------------------------------
 * date:2009-06-02
 * site:http://www.aminLab.cn
 * ------------------------------------
 */
package src{
	// 导入公共包
	import T.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	// 主类
	public class TestDemo extends Sprite{
	/**私有变量
	---------------------------*/
		private var TE:TEmbed;						//平台插件
		private var rect:Sprite = new Sprite;
		private var sendto:Boolean = false;
		private var startTime:int = getTimer();
		
	/**构造 & 析构
	---------------------------*/
		// 构造函数
		public function TestDemo():void{
			addEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFormStage);
		}
		// 添加到舞台
		private function OnAddedToStage(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);

			// 创建插件
			TE = new TEmbed;
			// 添加到平台以调用平台提供的API(!! 可供调用的API请查看TEmbed类)
			this.addChild(TE);
			// 显示当前玩家索引
			root['tfMyIndex'].text = TE.getMyIndex();	// 调用平台API得到自己的索引
			var userInfos:Array = TE.getUserInfos();	// 调用平台API得到所有玩家的信息(!! 玩家的信息结构请查看TUser类)
			// 显示所有玩家信息
			var user:TUser;
			for(var i:int = 0;i < userInfos.length;++i){
				user = userInfos[i];
				if(user != null){
					root['tfInfos'].appendText(user.index + ',' + user.name + '\n');
					root['tfInfos'].scrollV = root['tfInfos'].maxScrollV;
					// 添加图形
					var temp:Shape = new Shape;
					temp.graphics.beginFill(0x000000);
					temp.graphics.drawRect(0,0,30,30);
					temp.graphics.beginFill(0xFF9900 - user.index * 50);
					temp.graphics.drawRect(1,1,28,28);
					temp.graphics.endFill();
					temp.x = (temp.width + 10) * i + 110;
					temp.y = 250;
					temp.name = 's_' + user.index;
					rect.addChild(temp);
				}
			}
			// 监听平台事件(!! 事件具体参数说明请查看TEvent类)
			this.addEventListener(TEvent.Message,OnMessage);
			this.addEventListener(TEvent.OffLine,OnOffLine);
			this.addEventListener(TEvent.Error,OnError);
			// 监听事件
			stage.addEventListener(KeyboardEvent.KEY_DOWN,OnKeyUp);
			root['bnExitGame'].addEventListener(MouseEvent.CLICK,OnClick_ExitGame);
			root['bnMode'].addEventListener(MouseEvent.CLICK,OnClick_Mode);
			this.addChild(rect);
		}
		// 析构函数
		private function OnRemovedFormStage(e:Event):void{
			removeEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFormStage);

			this.removeEventListener(TEvent.Message,OnMessage);
			this.removeEventListener(TEvent.OffLine,OnOffLine);
			this.removeEventListener(TEvent.Error,OnError);
			
			stage.removeEventListener(KeyboardEvent.KEY_DOWN,OnKeyUp);
			root['bnExitGame'].removeEventListener(MouseEvent.CLICK,OnClick_ExitGame);
			root['bnMode'].removeEventListener(MouseEvent.CLICK,OnClick_Mode);
			
			TE = null;
		}
		
	/**事件函数
	---------------------------*/
		// 接收消息事件
		private function OnMessage(e:TEvent):void{
			root['tfMessage'].appendText('发送方:' + e.fromIndex + ' | 数据:' + e.data + ' | 延时:' + e.delay + '\n');
			root['tfMessage'].scrollV = root['tfMessage'].maxScrollV;
			
			// 分析数据和处理
			var arg:Array = e.data.split(',');
			var index:int = parseInt(arg[0]);
			var target:* = rect.getChildByName('s_' + index);
			
			switch(arg[1])
			{
				case '←':
					target.x -= 5;
				break
				case '↑':
					target.y -= 5;
				break
				case '→':
					target.x += 5;
				break
				case '↓':
					target.y += 5;
				break
			}
		}
		// 断线事件
		private function OnOffLine(e:TEvent):void{
			root['tfOffLine'].appendText('离开的玩家索引:' + e.fromIndex + '\n');
		}
		// 错误事件(!! 错误类型事件请查看TError类)
		private function OnError(e:TEvent):void{
			root['tfError'].appendText('编号:' + e.errorNo + ',详细:' + e.data + '\n');
		}

	/**公共函数
	---------------------------*/
		// 退出游戏返回队伍
		private function OnClick_ExitGame(e:MouseEvent):void{
			TE.exitGame();
		}
		// 切换发送模式
		private function OnClick_Mode(e:MouseEvent):void{
			sendto = !sendto;
		}
		// 响应KeyUp事件
		private function OnKeyUp(e:KeyboardEvent):void{
			// 判断时差
			var now:int = getTimer();
			if(now - startTime < 40){
				return;
			}
			startTime = now;
			// 判断按键
			switch(e.keyCode){
				// 向左
				case 37:
				case 65:
					// 发送数据
					if(sendto)
						TE.sendTo([1],TE.getMyIndex() + ",←");
					else
						TE.broadcast(TE.getMyIndex() + ",←");
				break;
				// 向上
				case 38:
				case 87:
					// 发送数据
					if(sendto)
						TE.sendTo([1],TE.getMyIndex() + ",↑");
					else
						TE.broadcast(TE.getMyIndex() + ",↑");
				break;
				// 向右
				case 39:
				case 68:
					// 发送数据
					if(sendto)
						TE.sendTo([1],TE.getMyIndex() + ",→");
					else
						TE.broadcast(TE.getMyIndex() + ",→");
				break;
				// 向下
				case 40:
				case 83:
					// 发送数据
					if(sendto)
						TE.sendTo([1],TE.getMyIndex() + ",↓");
					else
						TE.broadcast(TE.getMyIndex() + ",↓");
				break;
			}
		}
	}
}