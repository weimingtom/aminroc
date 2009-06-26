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
	import flash.geom.*;
	import flash.utils.*;
	// class
	public class AList extends Sprite {
	/**Stage Variable
	---------------------------*/
		private var spBackground:AList_Background;
		private var spItems:Sprite;
		private var spMask:Sprite;
		private var scrollBar:AScrollBar;

	/**Private Variable
	---------------------------*/		
		private var nFocusedIndex:int = -1;
		private var nSelectedIndex:int = -1;
		
	/**Private Const
	---------------------------*/
		private const TRACK_W:int = 8;
		
	/**Construct & Destruct
	---------------------------*/
		public function AList(_x:int,_y:int,_w:int,_h:int) {
			addEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFormStage);

			x = _x;
			y = _y;

			spBackground = new AList_Background();
			spBackground.width = _w;
			spBackground.height = _h;
			
			spMask = new Sprite;
			spMask.graphics.beginFill(0xFFFFFF);
			spMask.graphics.drawRect(0,0,_w,_h);
			spMask.graphics.endFill();
			
			spItems = new Sprite;
			spItems.mask = spMask;
			scrollBar = new AScrollBar(_w - TRACK_W,0,TRACK_W,_h);
			
			addChild(spBackground);
			addChild(spMask);
			addChild(spItems);
			addChild(scrollBar);
		}
		private function OnAddedToStage(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			
			scrollBar.addEventListener(AScrollBarEvent.SCROLL,OnScroll);
			addEventListener(MouseEvent.MOUSE_WHEEL,OnMouseWheel);
			spItems.addEventListener(MouseEvent.CLICK,OnClick);
		}
		private function OnRemovedFormStage(e:Event):void{
			removeEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFormStage);
			
			scrollBar.removeEventListener(AScrollBarEvent.SCROLL,OnScroll);
			removeEventListener(MouseEvent.MOUSE_WHEEL,OnMouseWheel);
			spItems.removeEventListener(MouseEvent.CLICK,OnClick);
			
			spBackground = null;
			spItems = null;
			spMask = null;
			scrollBar = null;
		}
		
	/**Public Function
	---------------------------*/
		public function addItem(item:DisplayObject):int{
			item.x = 0;
			item.y = spItems.height;
			spItems.addChild(item);
			scrollBar.resetThumb(spItems.height,spMask.height);
			return spItems.numChildren;
		}
		public function addItemAt(item:DisplayObject,index:int):int{
			item.x = 0;
			item.y = spItems.getChildAt(index).y;
			spItems.addChildAt(item,index);
			resizePosition(index,item.height);
			return spItems.numChildren;
		}
		public function delItem(item:DisplayObject):void{
			var index:int = spItems.getChildIndex(item);
			delItemAt(index);
		}
		public function delItemAt(index:int):void{
			var item:DisplayObject = spItems.getChildAt(index);
			resizePosition(index,-item.height);
			spItems.removeChild(item);
		}
		public function getItemAt(index:int):*{
			return spItems.getChildAt(index);
		}
		public function get length():int{
			return spItems.numChildren;
		}
		public function get focusedIndex():int{
			return nFocusedIndex;
		}
		public function set focusedIndex(index:int):void{
			AItem(spItems.getChildAt(index)).focus();
		}
		public function set enabled(v:Boolean):void{
			this.mouseChildren = v;
			this.mouseEnabled = v;
		}
		
	/**Private Function
	---------------------------*/
		private function resizePosition(index:int,offsetY:int):void{
			var item:DisplayObject;
			for(var i:int = index + 1;i < spItems.numChildren;++i){
				item = spItems.getChildAt(i);
				item.y += offsetY;
			}
		}
		private function OnClick(e:MouseEvent):void{
			if(e.target == this || e.target == this.spItems){
				return;
			}
			var ie:AListEvent = new AListEvent(AListEvent.ITEM_CLICK);
			ie.item = e.target;
			dispatchEvent(ie);
		}
		private function OnScroll(e:AScrollBarEvent):void{
			spItems.y = -(spItems.height * e.percent);
		}
		private function OnMouseWheel(e:MouseEvent):void{
			scrollBar.scroll(-e.delta);
		}
	}
}