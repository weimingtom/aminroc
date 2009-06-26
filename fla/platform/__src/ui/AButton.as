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
	import flash.text.*;
	// class
	public class AButton extends MovieClip {
	/**Stage Variable
	---------------------------*/
		public var _tfName:TextField;
		
	/**Construct & Destruct
	---------------------------*/
		public function AButton() {
			addEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFormStage);
			
			this.buttonMode = true;
			this.mouseChildren = false;
		}
		private function OnAddedToStage(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			
			addEventListener(MouseEvent.MOUSE_OVER,OnMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT,OnMOuseOut);
			addEventListener(MouseEvent.MOUSE_DOWN,OnMouseDown);
			addEventListener(MouseEvent.MOUSE_UP,OnMouseUp);
		}
		private function OnRemovedFormStage(e:Event):void{
			removeEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFormStage);
			
			removeEventListener(MouseEvent.MOUSE_OVER,OnMouseOver);
			removeEventListener(MouseEvent.MOUSE_OUT,OnMOuseOut);
			removeEventListener(MouseEvent.MOUSE_DOWN,OnMouseDown);
			removeEventListener(MouseEvent.MOUSE_UP,OnMouseUp);
			
			_tfName = null;
		}
		
	/**Public Function
	---------------------------*/
		public function set textFormat(format:*):void{
			_tfName.setTextFormat(TextFormat(format));
		}
		public function set label(n:String):void{
			_tfName.text = n;
		}
		public function get label():String{
			return _tfName.text;
		}
		
	/**Private Function
	---------------------------*/
		public function OnMouseOver(e:MouseEvent):void{
			this.gotoAndStop('over');
		}
		public function OnMOuseOut(e:MouseEvent):void{
			this.gotoAndStop('out');
		}
		public function OnMouseDown(e:MouseEvent):void{
			this.gotoAndStop('down');
		}
		public function OnMouseUp(e:MouseEvent):void{
			this.gotoAndStop('out');
		}
	}
}