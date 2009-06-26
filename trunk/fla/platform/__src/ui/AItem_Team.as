package __src.ui{
	// import public package
	import flash.display.*;
	import flash.events.*;
	import flash.text.TextField;
	import flash.text.TextFormat;
	// import private package
	import __def.Team;
	// class
	public class AItem_Team extends Sprite implements AItem{
	/**Stage Variable
	---------------------------*/
		public var _tfIndex:TextField;
		public var _tfName:TextField;
		public var _mcChildren:MovieClip;
		public var _mcBackground:MovieClip;

	/**Private Variable
	---------------------------*/
		private var _team:Team;
		
	/**Private Const
	---------------------------*/
		private const MAX_CHILDREN:int = 8;

	/**Construct & Destruct
	---------------------------*/
		public function AItem_Team() {
			addEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFormStage);
			
			this.buttonMode = true;
			this.mouseChildren = false
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
			_mcChildren = null;
			_mcBackground = null;
		}

	/**Public Function
	---------------------------*/
		public function focus():void{
		}
		public function get team():Team{
			return _team;
		}
		public function get index():int{
			return _team.index;
		}
		public function set label(n:String):void{
			
		}
		public function get label():String{
			return null;
		}
		public function set team(t:Team):void{
			_team = t;
			_tfIndex.text = _team.index.toString();
			if(_team.index > 1000){
				_tfIndex.setTextFormat(new TextFormat(null,12,null,true));
			}
			else if(_team.index > 100){
				_tfIndex.setTextFormat(new TextFormat(null,16,null,true));
			}
			else{
				_tfIndex.setTextFormat(new TextFormat(null,20,null,true));
			}
			_tfIndex.y = (this.height - _tfIndex.textHeight - 4) / 2;
			_tfIndex.height = _tfIndex.textHeight + 2;
			_tfName.text = _team.name;
			for(var i:int = _team.maxChildren;i < MAX_CHILDREN;++i){
				MovieClip(_mcChildren['mcStar_' + i]).visible = false;
			}
			for(var j:int = 0;j < _team.maxChildren;++j){
				MovieClip(_mcChildren['mcStar_' + j]).gotoAndStop(1);
			}
			for(var k:int = 0;k < _team.numChildren;++k){
				MovieClip(_mcChildren['mcStar_' + k]).gotoAndStop(2);
			}
		}
		
	/**Private Function
	---------------------------*/
		private function OnRollOver(e:MouseEvent):void{
			_mcBackground.gotoAndStop(2);
		}
		private function OnRollOut(e:MouseEvent):void{
			_mcBackground.gotoAndStop(1);
		}
	}
}