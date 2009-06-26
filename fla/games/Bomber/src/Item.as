package src{
	// 导入包
	import def.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	// 主类
	public class Item extends MovieClip {
	/**公共变量
	---------------------------*/
		public var nBlock:Boolean = false;
		
	/**私有变量
	---------------------------*/
		private var nType:uint;

	/**构造 & 析构
	---------------------------*/
		// 构造函数
		public function Item(type:uint){
			addEventListener(Event.ADDED_TO_STAGE ,OnAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE ,OnReomvedFromStage);
			// 物品类型
			nType = type;
			// 显示
			gotoAndStop(nType);
		}
		// 添加到舞台
		private function OnAddedToStage(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE ,OnAddedToStage);
		
			parent.addEventListener(GameEvent.BE_BLAST,OnBeBlast);
			parent.addEventListener(GameEvent.BE_TOUTH,OnBeTouch);
		}
		// 从舞台中移移
		private function OnReomvedFromStage(e:Event):void{
			removeEventListener(Event.REMOVED_FROM_STAGE ,OnReomvedFromStage);
		
			parent.removeEventListener(GameEvent.BE_BLAST,OnBeBlast);
			parent.removeEventListener(GameEvent.BE_TOUTH,OnBeTouch);
		}
		
	/**私有函数
	---------------------------*/
		// 被炸到事件
		private function OnBeBlast(e:GameEvent):void{
			parent.removeChild(this);	// 移动对象
		}
		// 被触到事件
		private function OnBeTouch(e:GameEvent):void{
			// 接触到的对象不在正常状态
			var role:Role = Role(e.src);
			var spRoot:Bomber = Bomber(root);
			if(role.nStatus != ROLE.NORMAL)
				return;
				
			// 判断类型
			switch(nType){
				case ITEM.BOMB:
					++ role.nBombLimit;
					++ role.nCurBombs
					
					// 如果是自己,更新图示
					if(spRoot.nMyIndex == role.nIndex){
						spRoot.tfCurBombs.text = role.nCurBombs + '/' + role.nBombLimit;
					}
				break;
				case ITEM.POWER:
					++ role.nBombPower;
					
					// 如果是自己,更新图示
					if(spRoot.nMyIndex == role.nIndex){
						spRoot.tfCurPower.text = role.nBombPower.toString();
					}
				break;
				case ITEM.RANGE:
					++ role.nBombRange;
					
					// 如果是自己,更新图示
					if(spRoot.nMyIndex == role.nIndex){
						spRoot.tfCurRange.text = role.nBombRange.toString();
					}
				break;
				case ITEM.SPEED:
					if(role.nSpeed < role.SPEED_LIMIT){
						++ role.nSpeed;
						// 如果是自己,更新图示
						if(spRoot.nMyIndex == role.nIndex){
							spRoot.tfCurSpeed.text = role.nSpeed.toString();
						}
					}
				break;
			}
			
			// 移动对象
			parent.removeChild(this);
		 }
	}
}