package __src.ui{
	// import public package
	import com.al.ATween;
	import flash.display.*;
	import flash.events.*;
	import flash.text.TextField;
	// import private package
	import __def.NodeState;
	// class
	public class AItem_User extends Sprite implements AItem{
	/**Stage Variable
	---------------------------*/
		public var _mcButtons:MovieClip;
		public var _tfIndex:TextField;
		public var _tfName:TextField;
		public var _mcExtend:MovieClip;
		
	/**Private Variable
	---------------------------*/
		private var extendId:uint = 0;
		private var dm:int = 0;
		
	/**Public Const
	---------------------------*/
		public static const DM_EMPTY:int = 1001;
		public static const DM_NORMAL:int = 1002;
		public static const DM_EXTNED:int = 1003;
		
		public static const ACTION_READY:String = 'AC_RD';
		public static const ACTION_CANCEL:String = 'AC_CC';
		public static const ACTION_SWITCH_OWNER:String = 'AC_SO';
		public static const ACTION_REMOVE:String = 'AC_RE';
		
	/**Construct & Destruct
	---------------------------*/
		public function AItem_User():void{
			addEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFormStage);
			
			displayMode = DM_EMPTY;
		}
		private function OnAddedToStage(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			
			_mcExtend.addEventListener(MouseEvent.ROLL_OVER,OnRollOver_Extend);
			_mcExtend.addEventListener(MouseEvent.ROLL_OUT,OnRollOut_Extend);
			_mcButtons.addEventListener(MouseEvent.CLICK,OnClick_Action);
			_mcExtend.addEventListener(MouseEvent.CLICK,OnClick_Action);
		}
		private function OnRemovedFormStage(e:Event):void{
			removeEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFormStage);
			
			_mcExtend.removeEventListener(MouseEvent.ROLL_OVER,OnRollOver_Extend);
			_mcExtend.removeEventListener(MouseEvent.ROLL_OUT,OnRollOut_Extend);
			_mcButtons.removeEventListener(MouseEvent.CLICK,OnClick_Action);
			_mcExtend.removeEventListener(MouseEvent.CLICK,OnClick_Action);
			
			_mcButtons = null;
			_tfIndex = null;
			_tfName = null;
			_mcExtend = null;
		}
		
	/**Public Function
	---------------------------*/
		public function focus():void{
		}
		public function set label(v:String):void{
			_tfName.text = v;
		}
		public function get label():String{
			return _tfName.text;
		}
		public function set index(v:String):void{
			_tfIndex.text = v;
		}
		public function get sn():String{
			return _tfIndex.text;
		}
		public function set sn(v:String):void{
			_tfIndex.text = v;
		}
		public function set displayMode(n:int):void{
			dm = n;
			if(dm == DM_EMPTY){
				_tfName.visible = _mcButtons.visible = false;
				_mcExtend.visible = false;
			}
			else if(dm == DM_NORMAL){
				_tfIndex.visible = _tfName.visible = _mcButtons.visible = true;
				_mcExtend.visible = false;
			}
			else if(dm == DM_EXTNED){
				_tfIndex.visible = _tfName.visible = _mcButtons.visible = true;
				_mcExtend.visible = true;
			}
		}
		public function get displayMode():int{
			return dm;
		}
		public function toState(state:int,status:String):void{
			if(state == NodeState.WAIT){
				_mcButtons.gotoAndStop('wait_' + status);
			}
			else if(state == NodeState.READY){
				_mcButtons.gotoAndStop('ready_' + status);
			}
			else if(state == NodeState.PLAY){
				_mcButtons.gotoAndStop('play_' + status);
			}
		}
		public function isMe():void{
			_tfName.textColor = 0xFF0000;
		}
		
	/**Private Function
	---------------------------*/
		private function OnClick_Action(e:MouseEvent):void{
			if(e.target.name == 'bnReady'){
				this.dispatchEvent(new Event(ACTION_READY));
			}
			else if(e.target.name == 'bnWait'){
				this.dispatchEvent(new Event(ACTION_CANCEL));
			}
			else if(e.target.name == 'bnSwitchOwner'){
				this.dispatchEvent(new Event(ACTION_SWITCH_OWNER));
			}
			else if(e.target.name == 'bnRemove'){
				this.dispatchEvent(new Event(ACTION_REMOVE));
			}
		}
		private function OnClick_Extend(e:MouseEvent):void{
			
		}
		private function OnRollOver_Extend(e:MouseEvent):void{
			e.currentTarget.gotoAndStop(2);
			ATween.kill(extendId);
			extendId = 0;
			extendId = ATween.to(e.currentTarget,200,{x:250});
		}
		private function OnRollOut_Extend(e:MouseEvent):void{
			ATween.kill(extendId);
			extendId = 0;
			extendId = ATween.to(e.currentTarget,200,{x:280},function():void{e.currentTarget.gotoAndStop(1);});
		}
	}
}