/**
 * Developed by AminLab
 * ------------------------------------
 * date:2009-05-26
 * site:http://www.aminLab.cn
 * ------------------------------------
 */
package __src.ui{
	// import public package
	import flash.display.*;
	import flash.events.*;
	import flash.text.TextField;
	// class
	public class APanel extends Sprite {
	/**Stage Variable
	---------------------------*/
		public var _tfName:TextField;
		
	/**Construct & Destruct
	---------------------------*/
		public function APanel() {
			addEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFormStage);
		}
		private function OnAddedToStage(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
		}
		private function OnRemovedFormStage(e:Event):void{
			removeEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFormStage);
			
			_tfName = null;
		}
		
	/**Public Function
	---------------------------*/	
		public function set label(v:String):void{
			_tfName.text = v;
		}
	}
}