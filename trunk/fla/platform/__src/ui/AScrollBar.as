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
	import flash.geom.Point;
	// class
	public class AScrollBar extends Sprite {
	/**Public Variable
	---------------------------*/
		public var bLastPos:Boolean = true;
		
	/**Private Variable
	---------------------------*/
		private var spBackground:AScrollBar_Background;
		private var spThumb:AScrollBar_Thumb;
		
		private var bMove:Boolean = false;
		private var nStagePoint:Number;
		private var nLastPercent:Number 
		
	/**Private Const
	---------------------------*/
		private const DOWN_ALPHA:Number = 1;
		private const UP_ALPHA:Number = 0.25;
		
	/**Construct & Destruct
	---------------------------*/
		public function AScrollBar(_x:int,_y:int,_w:int,_h:int) {
			addEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFromStage);
			
			x = _x;
			y = _y;
			
			this.visible = false;
			
			spBackground = new AScrollBar_Background;
			spBackground.width = _w;
			spBackground.height = _h;
			
			spThumb = new AScrollBar_Thumb;
			spThumb.width = _w;
			spThumb.height = _h;
			spThumb.alpha = UP_ALPHA;
			
			addChild(spBackground);
			addChild(spThumb);
		}
		private function OnAddedToStage(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
		
			addEventListener(MouseEvent.MOUSE_WHEEL,OnMouseWheel);
			spBackground.addEventListener(MouseEvent.CLICK,OnBlankClick);
			spThumb.addEventListener(MouseEvent.MOUSE_OVER,OnMouseOver);
			spThumb.addEventListener(MouseEvent.MOUSE_OUT,OnMouseOut);
			spThumb.addEventListener(MouseEvent.MOUSE_DOWN,OnMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP,OnMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE,OnMouseMove);
		}
		private function OnRemovedFromStage(e:Event):void{
			removeEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFromStage);
			
			removeEventListener(MouseEvent.MOUSE_WHEEL,OnMouseWheel);
			spBackground.removeEventListener(MouseEvent.CLICK,OnBlankClick);
			spThumb.removeEventListener(MouseEvent.MOUSE_OVER,OnMouseOver);
			spThumb.removeEventListener(MouseEvent.MOUSE_OUT,OnMouseOut);
			spThumb.removeEventListener(MouseEvent.MOUSE_DOWN,OnMouseDown);
			stage.removeEventListener(MouseEvent.MOUSE_UP,OnMouseUp);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,OnMouseMove);
			
			spBackground = null;
			spThumb = null;
		}
		
	/**Public Function
	---------------------------*/
		public function resetThumb(totalLen:Number,showLen:Number):void{
			var percent:Number = showLen / totalLen;
			var lastSlice:Number = spBackground.height / spThumb.height;
			spThumb.height = spBackground.height * percent;
			var curSlice:Number = spBackground.height / spThumb.height;
			var sliceScale:Number = lastSlice / curSlice;
			spThumb.y *= sliceScale;
			this.visible = (totalLen > showLen ? true : false);
		}
		public function scroll(offset:int):void{
			var goalY:Number = spThumb.y + offset;
			if(goalY < 0){
				spThumb.y = 0;
			}
			else if(goalY > spBackground.height - spThumb.height){
				spThumb.y = spBackground.height - spThumb.height;
			}
			else{
				spThumb.y = goalY;
			}
			bLastPos = (spThumb.y + spThumb.height == spBackground.height) ? true : false;
			nLastPercent = spThumb.y / spBackground.height;
			var abe:AScrollBarEvent = new AScrollBarEvent(AScrollBarEvent.SCROLL);
			abe.percent = nLastPercent;
			this.dispatchEvent(abe);
		}
		
		public function toBottom():void{
			bLastPos = true;
			var offset:Number = (spBackground.height - spThumb.height);
			nLastPercent = offset / spBackground.height;
			spThumb.y = offset;
			var abe:AScrollBarEvent = new AScrollBarEvent(AScrollBarEvent.SCROLL);
			abe.percent = nLastPercent;
			this.dispatchEvent(abe);
		}
		
	/**Private Function
	---------------------------*/
		private function OnMouseOver(e:MouseEvent):void{
			spThumb.alpha = DOWN_ALPHA;
		}
		private function OnMouseOut(e:MouseEvent):void{
			!bMove && (spThumb.alpha = UP_ALPHA);
		}
		private function OnMouseDown(e:MouseEvent):void{
			bMove = true;
			spThumb.alpha = DOWN_ALPHA;
			nStagePoint = e.stageY;
		}
		private function OnMouseUp(e:MouseEvent):void{
			bMove = false;
			spThumb.alpha = UP_ALPHA;
		}
		private function OnMouseMove(e:MouseEvent):void{
			if(bMove){
				var offset:int = e.stageY - nStagePoint;
				nStagePoint = e.stageY;
				scroll(offset);
			}
		}
		private function OnMouseWheel(e:MouseEvent):void{
			scroll(-e.delta);
		}
		private function OnBlankClick(e:MouseEvent):void{
			var p:Point = localToGlobal(new Point(0,spThumb.y));
			nStagePoint = p.y + spThumb.height;
			if(e.stageY <= p.y){
				scroll(e.stageY - p.y);
			}
			else{
				scroll(e.stageY - (p.y + spThumb.height));
			}
		}
	}
}