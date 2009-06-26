package src{
	// 导入包
	import def.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	// 主类
	public class TheEnd extends MovieClip {
	/**私有常量
	---------------------------*/
		private var EXIT_INTERVAL:int = 3000;

	/**构造 & 析构
	---------------------------*/
		// 构造函数
		public function TheEnd(){
			addEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
		}
		// 添加到舞台
		private function OnAddedToStage(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			var tid:int = setTimeout(function():void{Bomber(root).TE.exitGame();clearTimeout(tid);},EXIT_INTERVAL);
		}
	}
}