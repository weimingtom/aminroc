package __src{
	// 导入公共包
	import T.*;
	
	import __def.*;
	
	import __src.ui.*;
	
	import com.al.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.system.*;
	// 主类
	public class TeamScene extends Sprite{
	/**舞台变量
	---------------------------*/
		public var pnBackground:APanel;
		
		public var lsUsers:AList;
		public var cbUsers:AComboBox;
		public var taChat:ATextArea;
		public var tfInput:TextField;
		
		public var bnExit:SimpleButton;
		public var bnChat:AButton;

	/**接口变量
	---------------------------*/
		// 通讯管道
		private var net:ANet;
		// 队伍信息
		private var myTeam:MyTeam;
		
	/**私有变量
	---------------------------*/
		private var bFirst:Boolean = true;

	/**构造 & 析构
	---------------------------*/
		// 构造函数
		public function TeamScene(n:ANet,mt:MyTeam):void{
			addEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFormStage);
			
			this.net = n;
			this.myTeam =  mt;
		}
		// 添加到舞台
		private function OnAddedToStage(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			
			ADialog.show('正在读取资料,请稍等...',ADialog.TYPE_WAIT);
			// 1.初始化组件
			bnExit.addEventListener(MouseEvent.CLICK,OnClick_Exit);
			bnChat.addEventListener(MouseEvent.CLICK,OnClick_Chat);
			taChat = new ATextArea(8,275,304,113);
			addChild(taChat);
			bnChat.label = '聊天';
			tfInput.addEventListener(KeyboardEvent.KEY_UP,OnKeyUp_Input);
			pnBackground.label = myTeam.teamIndex + '.' + myTeam.teamName;
			lsUsers = new AList(5,30,310,240);
			addChild(lsUsers);
			this.setChildIndex(cbUsers,this.numChildren-1);
			cbUsers.length = myTeam.maxUserForTeam;
			cbUsers.addEventListener(AListEvent.ITEM_CLICK,OnClick_Select);
			// 2.创建座位
			var item1:AItem_User;
			var item2:AItem_ComboBox;
			for(var i:int = 0;i < myTeam.maxUserForTeam;++i){
				item1 = new AItem_User;
				item1.index = (i + 1).toString();
				item1.addEventListener(AItem_User.ACTION_READY,OnAction_Ready);
				item1.addEventListener(AItem_User.ACTION_CANCEL,OnAction_Cancel);
				item1.addEventListener(AItem_User.ACTION_REMOVE,OnAction_Remove);
				item1.addEventListener(AItem_User.ACTION_SWITCH_OWNER,OnAction_SwitchOwner);
				lsUsers.addItem(item1);
				
				item2 = new AItem_ComboBox;
				item2.index = (i + 1).toString();
				cbUsers.addItem(item2);
			}
			// 3.发送请求
			net.send(AEvent.USER_LIST.toString());
		}
		// 析构函数
		private function OnRemovedFormStage(e:Event):void{
			removeEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFormStage);
			
			this.bnExit.removeEventListener(MouseEvent.CLICK,OnClick_Exit);
			this.bnChat.removeEventListener(MouseEvent.CLICK,OnClick_Chat);
			this.tfInput.removeEventListener(KeyboardEvent.KEY_UP,OnKeyUp_Input);
			this.cbUsers.removeEventListener(AListEvent.ITEM_CLICK,OnClick_Select);

			var item:AItem_User;
			for(var i:int = 0;i < myTeam.maxUserForTeam;++i){
				item = this.lsUsers.getItemAt(i);
				item.removeEventListener(AItem_User.ACTION_READY,OnAction_Ready);
				item.removeEventListener(AItem_User.ACTION_CANCEL,OnAction_Cancel);
				item.removeEventListener(AItem_User.ACTION_REMOVE,OnAction_Remove);
				item.removeEventListener(AItem_User.ACTION_SWITCH_OWNER,OnAction_SwitchOwner);
			}
			this.pnBackground = null;
			this.lsUsers = null;
			this.cbUsers = null;
			this.taChat = null;
			this.tfInput = null;
			this.bnExit = null;
			this.bnChat = null;

			this.net = null;
			this.myTeam = null;
		}
		
	/**公共函数
	---------------------------*/
		// 显示信息
		public function showInfo(user:TUser):void{
			if(bFirst){
				bFirst = false;ADialog.close();
			}
			// 身份判断
			var status:String = (user.index == myTeam.myIndex ? '2' : '1');
			// 选项
			var item1:AItem_User = lsUsers.getItemAt(user.index - 1);
			var item2:AItem_ComboBox = cbUsers.getItemAt(user.index);

			if(user.state == NodeState.RELEASE){
				item1.displayMode = AItem_User.DM_EMPTY;
				
				item2.index = '';
				item2.label = '';
			}
			else{
				// 显示模式
				if(myTeam.myIndex == myTeam.owner && myTeam.myIndex != user.index){
					item1.displayMode = AItem_User.DM_EXTNED;
				}
				else{
					item1.displayMode = AItem_User.DM_NORMAL;
				}
				// 是否是自己
				if(myTeam.myIndex == user.index){
					item1.isMe();
					item2.isMe();
				}
				// 显示状态
				item1.toState(user.state,status);
				
				item1.index = user.index.toString();
				item1.label = user.name;
				item2.index = user.index.toString();
				item2.label = user.name;
			}
		}
		// 显示聊天内容
		public function showChat(user:TUser,content:String):void{
			var tx:String;
			if(myTeam.myIndex == user.index){
				tx = "<font color='#0000FF'>我：</font>"+ content;
			}
			else{
				tx = "<font color='#0000FF'>["+ (user.index) + "]"+ user.name  +"：</font>"+ content;
			}
			taChat.htmlText += tx;
			taChat.scrollMax();
		}
		// 显示密语内容
		public function showChatTo(srcUser:TUser,dstUser:TUser,content:String):void{
			var tx:String;
			if(myTeam.myIndex == srcUser.index){
				tx = "<font color='#FF9900'>[我]对["+ (dstUser.index) +"#"+ dstUser.name + "]说：</font>"+ content;
			}
			else{
				tx = "<font color='#FF9900'>["+ (srcUser.index) + "#"+ srcUser.name  +"]对[我]说：</font>"+ content;
			}
			taChat.htmlText += tx;
			taChat.scrollMax();
		}
		// 显示指定聊天内容
		public function systemSay(dataEx:String):void{
			taChat.htmlText += "<font color='#FF0000'>"+ dataEx +"<font>";
			taChat.scrollMax();
		}
		// 设置拥有者
		public function setOwner(index:int):void{
			myTeam.owner = index;
			var item:AItem_User;
			for(var i:int = 0;i < lsUsers.length;++i){
				item = AItem_User(lsUsers.getItemAt(i));
				if(item.displayMode == AItem_User.DM_EMPTY){
					continue;
				}
				if(myTeam.myIndex == myTeam.owner && (i + 1) != myTeam.myIndex){
					item.displayMode = AItem_User.DM_EXTNED;
				}
				else{
					item.displayMode = AItem_User.DM_NORMAL;
				}
			}
		}
		// 锁定
		public function lock(v:Boolean):void{
			lsUsers.enabled = !v;
			tfInput.text = '';
			tfInput.type = TextFieldType.DYNAMIC;
			bnExit.mouseEnabled = !v;
		}
		
	/**私有函数
	---------------------------*/
		// 准备
		private function OnAction_Ready(e:Event):void{
			AItem_User(e.currentTarget).toState(NodeState.READY,'2');
			net.send(AEvent.READY);
		}
		// 取消
		private function OnAction_Cancel(e:Event):void{
			AItem_User(e.currentTarget).toState(NodeState.WAIT,'2');
			net.send(AEvent.CANCEL);
		}
		// 踢除
		private function OnAction_Remove(e:Event):void{
			net.send(AEvent.REMOVE + ANet._EN_ + e.currentTarget.sn);
		}
		// 转移拥有权
		private function OnAction_SwitchOwner(e:Event):void{
			net.send(AEvent.SWITCH_OWNER + ANet._EN_ + e.currentTarget.sn);
		}
		// 退出
		private function OnClick_Exit(e:MouseEvent):void{
			this.lock(true);
			net.send(AEvent.EXIT_TEAM);
		}
		// 回车
		private function OnKeyUp_Input(e:KeyboardEvent):void{
			if(e.keyCode == 13){
				OnClick_Chat(null);
			}
		}
		// 聊天
		private function OnClick_Chat(e:MouseEvent):void{
			// 内容
			if(!tfInput.text)
				return;
				
			// 全体聊天
			if(cbUsers.selectedIndex){
				net.send(AEvent.CHAT_TO + ANet._EN_ + cbUsers.selectedIndex + ANet._1_ + tfInput.text);
			}
			else{
				net.send(AEvent.CHAT + ANet._EN_ + tfInput.text);
			}
			tfInput.text = "";
			stage.focus = tfInput;
		}
		// 选择选项
		private function OnClick_Select(e:AListEvent):void {
			if(e.item.label){
				var st:String = e.item.index ? ('[' + e.item.index + ']' + e.item.label) : e.item.label;
				cbUsers.text = st;
				stage.focus = tfInput;
			}
		}
	}
}