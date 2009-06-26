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
	public class ATextArea extends Sprite {
	/**Private Variable
	---------------------------*/
		private var spMask:Sprite;
		private var textField:TextField;
		private var scrollBar:AScrollBar;
		
	/**Private Const
	---------------------------*/
		private const TRACK_W:int = 8;
		
	/**Construct & Destruct
	---------------------------*/
		public function ATextArea(_x:int,_y:int,_w:int,_h:int){
			addEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFormStage);
			
			x = _x;
			y = _y;
			
			spMask = new Sprite;
			spMask.graphics.beginFill(0xFFFFFF);
			spMask.graphics.drawRect(0,0,_w,_h);
			spMask.graphics.endFill();
			
			textField = new TextField;
			textField.width = _w - TRACK_W;
			textField.height = _h;
			textField.type = TextFieldType.DYNAMIC;
			textField.multiline = true;
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.mask = spMask;
			
			scrollBar = new AScrollBar(_w - TRACK_W,0,TRACK_W,_h);
			
			addChild(spMask);
			addChild(textField);
			addChild(scrollBar);
			
		}
		private function OnAddedToStage(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			
			scrollBar.addEventListener(AScrollBarEvent.SCROLL,OnScroll);
		}
		private function OnRemovedFormStage(e:Event):void{
			removeEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFormStage);
			
			scrollBar.removeEventListener(AScrollBarEvent.SCROLL,OnScroll);
			
			spMask = null;
			textField = null;
			scrollBar = null;
		}
		
	/**Public Function
	---------------------------*/
		public function set htmlText(v:String):void{
			this.textField.htmlText = v;
			scrollBar.resetThumb(this.textField.textHeight,this.spMask.height);
		}
		public function get htmlText():String{
			return this.textField.htmlText;
		}
		public function set text(v:String):void{
			this.textField.text = v;
			scrollBar.resetThumb(this.textField.textHeight,this.spMask.height);
		}
		public function get text():String{
			return this.textField.text;
		}
		public function appednText(v:String):void{
			this.textField.appendText(v);
			scrollBar.resetThumb(this.textField.textHeight,this.spMask.height);
		}
		public function set scrollV(v:int):void{
			this.textField.scrollV = v;
		}
		public function get scrollV():int{
			return this.textField.scrollV;
		}
		public function get maxScrollV1():int{
			return this.textField.maxScrollV;
		}
		public function get numLines():int{
			return this.textField.numLines;
		}
		public function scrollMax():void{
			this.scrollBar.bLastPos && this.scrollBar.toBottom();
		}
		
	/**Private Function
	---------------------------*/
		private function OnScroll(e:AScrollBarEvent):void{
			this.textField.y = -(this.textField.textHeight * e.percent);
		}
	}
}