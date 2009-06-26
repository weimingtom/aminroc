package __src{
	// 导入包
	import __def.*;
	
	import __src.ui.*;
	
	import com.al.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.TextField;
	import flash.utils.*;
	import flash.system.*;
	// 主类
	public class ZoneScene extends Sprite{
	/**舞台变量
	---------------------------*/
		public var pnBackground:APanel;
		public var lsTeams:AList;
		public var tfTeamNumber:TextField;
		public var bnCreate:SimpleButton;

	/**接口变量
	---------------------------*/
		// 通讯管道
		private var net:ANet;
		// 空间信息
		private var myZone:MyZone;
		// 环境参数
		private var params:Params;

	/**私有变量
	---------------------------*/
		private var bFirst:Boolean = true;
			
	/**私有常量
	---------------------------*/
		private const AUTO_IV:Number = 600;	// 自动操作时间
		
	/**构造 & 析构
	---------------------------*/
		// 构造函数
		public function ZoneScene(n:ANet,mz:MyZone,p:Params):void{
			addEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFormStage);
			
			this.net = n;
			this.myZone = mz;
			this.params = p;
		}
		// 添加到舞台
		private function OnAddedToStage(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			
			ADialog.show('正在读取资料,请稍等...',ADialog.TYPE_WAIT);
			// 1.初始化组件
			bnCreate.addEventListener(MouseEvent.CLICK,OnClick_Create);
			pnBackground.label = params.game;
			lsTeams = new AList(5,30,310,385);
			lsTeams.addEventListener(AListEvent.ITEM_CLICK,OnClick_Join);
			addChild(lsTeams);
			// 2.发送请求
			net.send(AEvent.TEAM_LIST);
			// 3.是否自动化
			if(params.auto){
				setTimeout(automate,AUTO_IV);
			}
		}
		// 析构函数
		private function OnRemovedFormStage(e:Event):void{
			removeEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFormStage);
			
			this.bnCreate.removeEventListener(MouseEvent.CLICK,OnClick_Create);
			this.lsTeams.removeEventListener(AListEvent.ITEM_CLICK,OnClick_Join);
			
			this.pnBackground = null;
			this.lsTeams = null;
			this.tfTeamNumber = null;
			this.bnCreate = null;
		
			this.net = null;
			this.myZone = null;
			this.params = null;
		}
		// 锁定
		public function lock(v:Boolean):void{
			lsTeams.enabled = !v;
			bnCreate.mouseEnabled = !v;
		}
		
	/**公共函数
	---------------------------*/
		// 显示信息
		public function showInfo(team:Team):void{
			if(bFirst){
				bFirst = false;ADialog.close();
			}
			var item:AItem_Team;
			// 等待队伍
			if(team.state == NodeState.WAIT){
				// 修改
				for(var i:int = 0;i < lsTeams.length;++i){
					item = lsTeams.getItemAt(i);
					if(item.team.index == team.index){
						item.team = team;
						return;
					}
				}
				// 添加
				item = new AItem_Team;
				item.team = team;
				lsTeams.addItem(item);
			}
			// 释放队伍或隐藏队伍
			else if(team.state == NodeState.RELEASE || team.state == NodeState.HIDDEN){
				for(i = 0;i < lsTeams.length;++i){
					item = lsTeams.getItemAt(i);
					if(item.team.index == team.index){
						lsTeams.delItem(item);
						return;
					}
				}
			}
		}
		// 更新队伍数量
		public function updateTeamNumber(n:int):void{
			tfTeamNumber.text = n + '/' + myZone.maxTeam;
		}
		
	/**私有函数
	---------------------------*/
		// 创建事件
		private function OnClick_Create(e:MouseEvent):void {
			ADialog.show('请输入新的队伍名称:',ADialog.TYPE_PROMPT,OnInput_Create);
		}
		// 输入名字
		private function OnInput_Create(bn:int,dataEx:*):void{
			dataEx && toCreate(dataEx);
		}
		// 加入事件
		private function OnClick_Join(e:AListEvent):void {
			toJoin(e.item.index);
		}
		// 创建队伍
		private function toCreate(n:String):void {
			lock(true);
			net.send(AEvent.CREATE_TEAM + ANet._EN_ + n);
		}
		// 加入队伍
		private function toJoin(index:uint):void{
			lock(true);
			net.send(AEvent.JOIN_TEAM + ANet._EN_+ index);
		}
		// 自动化
		private function automate():void{
			// 自动创建队伍或加入
			if(lsTeams.length > 0){
				toJoin(lsTeams.getItemAt(0).index);
			}
			else{
				toCreate('Auto Team');
			}
		}

	}
}