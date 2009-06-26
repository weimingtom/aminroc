package src{
	// 导入包
	import def.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	// 主类
	public class Box extends MovieClip {
	/**舞台变量
	---------------------------*/
		public var mcCartoon:MovieClip;
		
	/**公共变量
	---------------------------*/
		public var nBlock:Boolean  = true;

	/**私有变量
	---------------------------*/
		private var nDefense:uint;
		private var nType:uint;
		
	/**构造 & 析构
	---------------------------*/
		// 构造函数
		public function Box(type:uint,defense:uint){
			addEventListener(Event.ADDED_TO_STAGE ,OnAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE ,OnReomvedFromStage);
			// 初始化变量
			nDefense = defense;
			nType = type;
			// 显示
 			gotoAndStop(nType);
		}
		// 添加到舞台
		private function OnAddedToStage(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE ,OnAddedToStage);
			
			parent.addEventListener(GameEvent.BE_BLAST,OnBeBlast);
		}
		// 从舞台中移移
		private function OnReomvedFromStage(e:Event):void{
			removeEventListener(Event.REMOVED_FROM_STAGE ,OnReomvedFromStage);
			
			var curRow:int = parent.y / _G.CELL_H;
			var curCol:int = parent.x / _G.CELL_W;
			var item:uint = Bomber(root).objLayout.item[curRow][curCol];
			if(item){
				parent.addChild(new Item(item));
			}
		}
			
	/**私有函数
	---------------------------*/
		// 被炸到事件
		private function OnBeBlast(e:GameEvent):void{
			// 爆炸威力不够
			if(Bomb(e.src).nPower < nDefense){
				return;
			}
			// 解除监听
			parent.removeEventListener(GameEvent.BE_BLAST,OnBeBlast);
			// 播放动画
			mcCartoon.play();
		}
	}
}