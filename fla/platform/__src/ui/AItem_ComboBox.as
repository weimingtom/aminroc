package __src.ui{
	// import public package
	import flash.display.*;
	import flash.events.*;
	import flash.text.TextField;
	// class
	public class AItem_ComboBox extends Sprite implements AItem{
	/**Stage Variable
	---------------------------*/
		public var _tfIndex:TextField;
		public var _tfName:TextField;
		public var _mcBackground:MovieClip;
		
	/**Private Variable
	---------------------------*/
		private var _enabled:Boolean = true;
				
	/**Construct & Destruct
	---------------------------*/
		public function AItem_ComboBox():void{
			addEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFormStage);

			this.mouseChildren = false;
			this.mouseEnabled = false;
		}
		private function OnAddedToStage(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);

			addEventListener(MouseEvent.ROLL_OVER,OnRollOver);
			addEventListener(MouseEvent.ROLL_OUT,OnRollOut);
		}
		private function OnRemovedFormStage(e:Event):void{
			removeEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFormStage);
			
			removeEventListener(MouseEvent.ROLL_OVER,OnRollOver);
			removeEventListener(MouseEvent.ROLL_OUT,OnRollOut);
			
			_tfIndex = null;
			_tfName = null;
			_mcBackground = null;
		}
		
	/**Public Function
	---------------------------*/
		public function focus():void{
		}
		public function set label(v:String):void{
			_tfName.text = v;
			v && (this.enabled = this._enabled);
		}
		public function get label():String{
			return _tfName.text;
		}
		public function set index(v:String):void{
			_tfIndex.text = v;
		}
		public function get index():String{
			return _tfIndex.text;
		}
		public function isMe():void{
			_tfName.textColor = 0x999999;
			this.enabled = false;
		}
		public function set enabled(v:Boolean):void{
			this._enabled = v;
			this.buttonMode = this.mouseEnabled = v;
		}
		public function get enabled():Boolean{
			return this._enabled;
		}
		
	/**Private Function
	---------------------------*/
		private function OnRollOver(e:MouseEvent):void{
			if(_tfName.text != ''){
				_mcBackground.gotoAndStop(2);
			}
		}
		private function OnRollOut(e:MouseEvent):void{
			if(_tfName.text != ''){
				_mcBackground.gotoAndStop(1);
			}
		}
	}
}