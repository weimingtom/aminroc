/**
 * Developed by AminLab
 * ------------------------------------
 * date:2009-06-02
 * site:http://www.aminLab.cn
 * ------------------------------------
 */
package __src{
	// 导入包
	import T.*;
	
	import __def.*;
	
	import __src.ui.*;
	
	import com.al.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.external.*;
	import flash.net.*;
	import flash.utils.*;
	// 主类
	public class Platform extends Sprite{
	/**私有变量
	---------------------------*/
		// 网络通讯
		private var net:ANet = new ANet;
		// 当前场景
		private var scene:DisplayObject;
		// 游戏对象
		private var game:URLLoader = new URLLoader;
		// 所有用户信息
		private var userInfos:Array;
		// 平台帧速
		private var nFrameRate:int = 0;
		
		// 队伍信息
		private var myTeam:MyTeam = new MyTeam;
		// 时间信息
		private var myTime:MyTime = new MyTime;
		// 空间信息
		private var myZone:MyZone = new MyZone;
		// 环境参数
		private var params:Params = new Params;
		// 个人信息
		private var session:Session = new Session;
		
		// 事件处理
		private var EM:Object = {
			// 请求验证
			([AEvent.REQUEST_TO]) : function(dataEx:String):void{
				var msg:String = InitScene(scene).getMsg(dataEx);
				net.send(AEvent.VALIDATE_ID + ANet._EN_ + msg + ANet._1_ + session.nickname);
			},
			// 验证身份
			([AEvent.VALIDATE_ID]) : function(dataEx:String):void{
				InitScene(scene).prompt("登入游戏...");
				net.send(AEvent.JOIN_ZONE + ANet._EN_ + params.game);  
			},
			// 进入空间
			([AEvent.JOIN_ZONE]) : function(dataEx:String):void{
				// 切换场景
				switchScene(new ZoneScene(this.net,this.myZone,this.params),2);
				myZone.maxTeam = parseInt(dataEx);
			},
			// 队伍列表
			([AEvent.TEAM_LIST]) : function(dataEx:String):void{
				var infos:Array = dataEx.split(ANet._1_);
				var info:Array;
				var team:Team 
				// 解析数据
				for (var i:int = 0; i < infos.length; ++i){
					info = infos[i].split(ANet._2_);
					team = new Team;
					team.state = parseInt(info[0]);
					team.index = parseInt(info[1]);
					team.name = info[2];
					team.numChildren = parseInt(info[3]);
					team.maxChildren = parseInt(info[4]);
					ZoneScene(scene).showInfo(team);
				}
			},
			// 队伍数量
			([AEvent.TEAM_NUMBER]) : function(dataEx:String):void{
				ZoneScene(scene).updateTeamNumber(parseInt(dataEx));
			},
			// 创建队伍
			([AEvent.CREATE_TEAM]) : function(dataEx:String):void{
			},
			// 进入队伍
			([AEvent.JOIN_TEAM]) : function(dataEx:String):void{
				var arg:Array = dataEx.split(ANet._1_);
				myTeam.teamIndex = parseInt(arg[0]);
				myTeam.myIndex = parseInt(arg[1]);
				myTeam.minUserForTeam = parseInt(arg[2]);
				myTeam.maxUserForTeam = parseInt(arg[3]);
				myTeam.teamName = arg[4];
				myTeam.owner = arg[5];
				// 重置用户信息
				userInfos = new Array;
				userInfos.length = myTeam.maxUserForTeam;
				// 切换场景
				switchScene(new TeamScene(this.net,this.myTeam),3);
			},
			// 离开队伍
			([AEvent.EXIT_TEAM]) : function(dataEx:String):void{
				// 切换场景
				switchScene(new ZoneScene(this.net,this.myZone,this.params),-3);
			},
			// 用户列表
			([AEvent.USER_LIST]) : function(dataEx:String):void{
				var infos:Array = dataEx.split(ANet._1_);
				var info:Array;
				var user:TUser;
				var infoIndex:int;	// 信息索引
				// 解析数据
				for (var i:int = 0; i < infos.length; ++i){
					info = infos[i].split(ANet._2_);
					user = new TUser;
					user.state = parseInt(info[0]);
					user.index = parseInt(info[1]);	// 注意：lua的数组索引是1开始！
					user.name = info[2];
					infoIndex = user.index - 1;
					// 设置数据
					userInfos[infoIndex] = (user.state == NodeState.RELEASE ? null : user);
					// 场景判断
					if(scene is TeamScene){
						TeamScene(scene).showInfo(user);
					}
					else if(user.state == NodeState.RELEASE){
						GameScene(scene).offLine(user.index);
					}
				}
			},
			// 转换拥有权
			([AEvent.SWITCH_OWNER]) : function(dataEx:String):void{
				if(scene is TeamScene){
					TeamScene(scene).setOwner(parseInt(dataEx));
				}
				else{
					this.myTeam.owner = parseInt(dataEx);
				}
			},
			// 游戏准备
			([AEvent.READY]) : function(dataEx:String):void{
			},
			// 游戏取消
			([AEvent.CANCEL]) : function(dataEx:String):void{
			},
			// 开始游戏
			([AEvent.PLAY]) : function(dataEx:String):void{
				// 同步服务器的时间
				myTime.cft = getTimer();
				net.send(AEvent.SYNC_SERVER_TIME);
				// 倒计时开始
				TeamScene(scene).lock(true);
				TeamScene(scene).systemSay("游戏开始倒计时:3\n");
				var i:int = 0;
				var tid:int = setInterval(function(p:Platform):void{
					if(i < 2){
						TeamScene(scene).systemSay("游戏开始倒计时:" + (2-i).toString() + "\n");
						++i;
					}else{
						clearInterval(tid);
						switchScene(new GameScene(p.net,p.game,p.userInfos,p.myTeam,p.myTime,p.beforeExitGame),4);
					}
				},1000,this);
			},
			// 聊天
			([AEvent.CHAT]) : function(dataEx:String):void{
				if(scene is TeamScene){
					// 解析数据并显示
					var arg:Array = dataEx.split(ANet._1_);
					var index:int = parseInt(arg[0]) - 1;
					var content:String = arg[1];
					TeamScene(scene).showChat(userInfos[index],content);
				}
			},
			// 密聊
			([AEvent.CHAT_TO]) : function(dataEx:String):void{
				if(scene is TeamScene){
					// 解析数据并显示
					var arg:Array = dataEx.split(ANet._1_);
					var src:int = parseInt(arg[0]) - 1;
					var dst:int = parseInt(arg[1]) - 1;
					var content:String = arg[2];
					TeamScene(scene).showChatTo(userInfos[src],userInfos[dst],content);
				}
			},
			// 广播数据
			([AEvent.BROADCAST]) : function(dataEx:String):void{
				GameScene(scene).message(dataEx);
			},
			// 广播数据(除了发送人)
			([AEvent.BROADCAST_BUT_THIS]) : function(dataEx:String):void{
				GameScene(scene).message(dataEx);
			},
			// 发送数据
			([AEvent.SEND_TO]) : function(dataEx:String):void{
				GameScene(scene).message(dataEx);
			},
			// 发送数据(且抄送给发送人)
			([AEvent.SEND_TO_AND_CC_THIS]) : function(dataEx:String):void{
				GameScene(scene).message(dataEx);
			},
			// 结束游戏
			([AEvent.EXIT_GAME]) : function(dataEx:String):void{
				// 恢复帧率
				stage.frameRate = this.nFrameRate;
				// 切换场景
				switchScene(new TeamScene(this.net,this.myTeam),1);
			},
			// 同步服务器时间
			([AEvent.SYNC_SERVER_TIME]) : function(dataEx:String):void{
				myTime.co = getTimer();
				var ping:int = Math.round((myTime.co - myTime.cft) * 0.6);
				myTime.so = parseInt(dataEx) + ping;
			},
			// [InitScene]明文错误 
			([AEvent.ERROR_MSG]) : function(dataEx:String):void{
				InitScene(scene).warn("未能通过验证!请尝试重新登入");
			},
			// [InitScene]用户名字错误
			([AEvent.ERROR_USER_NAME]) : function(dataEx:String):void{
				InitScene(scene).warn("无效用户名!请使用合法用户名");
			},
			// [InitScene]没此空间
			([AEvent.NOTEXIST_ZONE]) : function(dataEx:String):void{
				InitScene(scene).warn("无此游戏!请选择其他游戏");
			},
			// [InitScene]连接溢出
			([AEvent.OVERFLOW_SOCKETS]) : function(dataEx:String):void{
				InitScene(scene).warn("在线人线已满!请选择其他游戏或者稍后再试");
			},
			// [ZoneScene]队伍名字错误
			([AEvent.ERROR_TEAM_NAME]) : function(dataEx:String):void{
				ADialog.show("队伍名字错误,请重新命名");
			},
			// [ZoneScene]队伍溢出
			([AEvent.OVERFLOW_TEAM]) : function(dataEx:String):void{
				ZoneScene(scene).lock(false);
				ADialog.show("不能创建新的队伍,请稍后再试或者加入现有队伍");
			},
			// [ZoneScene]无此队伍
			([AEvent.NOTEXIST_TEAM]) : function(dataEx:String):void{
				ZoneScene(scene).lock(false);
				ADialog.show("此队伍不存在!请选择其他队伍");
			},
			// [ZoneScene]队员溢出
			([AEvent.OVERFLOW_USER]) : function(dataEx:String):void{
				ZoneScene(scene).lock(false);
				ADialog.show("队伍人数已满,请选择其他队伍");
			},
			// [TeamScene]不是等待状态
			([AEvent.ISNOT_WAIT_STATUS]) : function(dataEx:String):void{
			},
			// [TeamScene]不是准备状态
			([AEvent.ISNOT_READY_STATUS]) : function(dataEx:String):void{
			},
			// [TeamScene]聊天数据错误
			([AEvent.ERROR_CHAT_DATA]) : function(dataEx:String):void{
				ADialog.show("聊天消息发送失败");
			},
			// [TeamScene]无此聊天对象
			([AEvent.NOTEXIST_CHAT_OBJECT]) : function(dataEx:String):void{
				ADialog.show("无此聊天对象");
			},
			// [TeamScene]聊天对象错误
			([AEvent.ERROR_CHAT_OBJECT]) : function(dataEx:String):void{
				ADialog.show("你不能这样发送");
			},
			// [GameScene]广播数据错误
			([AEvent.ERROR_BROADCAST_DATA]) : function(dataEx:String):void{
				GameScene(scene).error(TError.ERROR_BROADCAST_DATA,dataEx);
			},
			// [GameScene]发送数据错误
			([AEvent.ERROR_SENDTO_DATA]) : function(dataEx:String):void{
				GameScene(scene).error(TError.ERROR_SENDTO_DATA,dataEx);
			},
			// [GameScene]无此发送对象
			([AEvent.NOTEXIST_SENDTO_OBJECT]) : function(dataEx:String):void{
				GameScene(scene).error(TError.NOTEXIST_SENDTO_OBJECT,dataEx);
			},
			// [GameScene]不是游戏状态 - 退出游戏
			([AEvent.ISNOT_PLAY_STATUS]) : function(dataEx:String):void{
			},
			// [TeamScene]拒绝转换拥有权
			([AEvent.DENY_SWITCH_OWNER]) : function(dataEx:String):void{
			}
		}
		
	/**构造 & 析构
	---------------------------*/
		// 构造函数
		public function Platform():void{
			addEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFormStage);
			// 保存帧速
			this.nFrameRate = stage.frameRate;
		}
		// 添加到舞台
		private function OnAddedToStage(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			// 设置挂载点
			ADialog.mount(this.stage);
			// 加载场景
			switchScene(new InitScene(this.params,this.session,this.game,this.afterInited));
		}
		// 析构函数
		private function OnRemovedFormStage(e:Event):void{
			removeEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFormStage);

			this.net.removeEventListener(Event.CONNECT,OnConnectSuc_Socket);
			this.net.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,OnSandBox_Socket);
			this.net.removeEventListener(IOErrorEvent.IO_ERROR,OnIoError_Socket);
			this.net.removeEventListener(Event.CLOSE,OnClose_Socket);
			this.net.removeEventListener(DataEvent.DATA,OnAEvent);
			
			this.net.close();
			this.scene && this.scene.parent.removeChild(this.scene);
			
			this.net = null;
			this.scene = null;
			this.game = null;
			this.userInfos = null;
			this.myTeam = null;
			this.myTime = null;
			this.myZone = null;
			this.params = null;
			this.session = null;
		}

	/**公共函数
	---------------------------*/
		// 重新刷新
		public function refresh():void{
			if(ExternalInterface.available){
            	var url:String = ExternalInterface.call("document.location.href.toString");
           		navigateToURL(new URLRequest(url),'_self');
    		}
  		}

	/**私有函数
	---------------------------*/
		// 初始化完成之后的动作
 		private function afterInited():void{
			net.addEventListener(Event.CONNECT,OnConnectSuc_Socket);
			net.addEventListener(SecurityErrorEvent.SECURITY_ERROR,OnSandBox_Socket);
			net.addEventListener(IOErrorEvent.IO_ERROR,OnIoError_Socket);
			net.addEventListener(Event.CLOSE,OnClose_Socket);
			net.addEventListener(DataEvent.DATA,OnAEvent);
			net.connect(params.server,params.port);
 		}
 		// 退出游戏之前的动作
 		private function beforeExitGame():void{
 		}
 		// 接收数据
		private function OnAEvent(e:DataEvent):void {
			// 解析数据
			var args:Array = e.data.split(ANet._EN_,2);
			if(args.length > 2) {
				return;
			}
			// 是否合法报文
			var event:Number = parseInt(args[0]);
			if(isNaN(event)){
				trace("It's a Error AEvent");
				return;
			}
			// 是否合法事件
			var func:* = EM[event];
			if(func){
				func.call(this,args[1]);
			}
		}
		// 居中
		private function toCenter(obj:DisplayObject):void{
			// 取整数,避免移动模糊
			obj.x = int((stage.stageWidth - obj.width) / 2);
			obj.y = int((stage.stageHeight - obj.height) / 2);
		}
		// 切换场景
		private function switchScene(newScene:DisplayObject,type:int = 1):void{
			var temp:int;
			
			if(type == 1){
				// 删除旧场景
				scene && (scene.parent.removeChild(scene));
				// 更新场景
				scene = null;
				scene = newScene;
				toCenter(scene);
				addChild(scene);
			}
			else if(type == 2){
				// 删除旧场景
				scene && (scene.parent.removeChild(scene));
				// 更新场景
				scene = null;
				scene = newScene;
				toCenter(scene);
				addChild(scene);
				// 效果设置
				temp = scene.y;
				scene.y -= 80;
				ATween.to(scene,200,{y:temp});
			}
			else if(type == 3){
				// 删除旧场景
				scene && ATween.to(scene,200,
							{alpha:0.2},
							function(s:*):void{s.parent.removeChild(s);},
							[scene]);
				// 更新场景
				scene = null;
				scene = newScene;
				toCenter(scene);
				addChild(scene);
				// 效果设置
				temp = scene.x;
				scene.x += 80;
				ATween.to(scene,200,{x:temp});
			}
			else if(type == -3){
				// 删除旧场景
				scene && ATween.to(scene,200,
							{alpha:0.2},
							function(s:*):void{s.parent.removeChild(s);},
							[scene]);
				// 更新场景
				scene = null;
				scene = newScene;
				toCenter(scene);
				addChild(scene);
				// 效果设置
				temp = scene.x;
				scene.x -= 80;
				ATween.to(scene,200,{x:temp});
			}
			else if(type == 4){
				// 删除旧场景
				scene && (scene.parent.removeChild(scene));
				// 更新场景
				scene = null;
				scene = newScene;
				addChild(scene);
			}
		}
		// [通讯]连接成功 
		private function OnConnectSuc_Socket(e:Event):void {
			net.send(AEvent.REQUEST_TO);
		}
		// [通讯]连接错误 
		private function OnIoError_Socket(e:Event):void {
			ADialog.show("找不到服务器的地址,请选择其他服务器");
		}
		// [通讯]安全沙箱  
		private function OnSandBox_Socket(e:SecurityErrorEvent):void {
			ADialog.show("不能连接到服务器,请选择其他服务器");
		}
		// [通讯]关闭通讯 
		private function OnClose_Socket(e:Event):void{
			ADialog.show("由于网络中断，游戏被中止\n点击按钮之后将会再次连接服务器",ADialog.TYPE_ALERT,refresh);
		}
	}
}