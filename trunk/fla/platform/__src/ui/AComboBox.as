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
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	// class
	public class AComboBox extends Sprite {
	/**Stage Variable
	---------------------------*/
		public var _tfName:TextField;
		public var _tfShow:SimpleButton;
		private var _list:AList;

	/**Public Variable
	---------------------------*/
		public var selectedIndex:int = 0;
		
	/**Private Const
	---------------------------*/
		private const ALL:String = '所有人';
		private const ITEM_H:int = 20;
		private const ITEM_W:int = 130;
		
	/**Construct & Destruct
	---------------------------*/
		public function AComboBox() {
			addEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFormStage);
		}
		private function OnAddedToStage(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			
			addEventListener(MouseEvent.ROLL_OUT,OnMouseOut_Show);
			_list.addEventListener(AListEvent.ITEM_CLICK,OnClick_Select);
			_tfShow.addEventListener(MouseEvent.MOUSE_OVER,OnMouseOver_Show);
		}
		private function OnRemovedFormStage(e:Event):void{
			removeEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFormStage);
			
			removeEventListener(MouseEvent.ROLL_OUT,OnMouseOut_Show);
			_list.removeEventListener(AListEvent.ITEM_CLICK,OnClick_Select);
			_tfShow.removeEventListener(MouseEvent.MOUSE_OVER,OnMouseOver_Show);
			
			_tfName = null;
			_tfShow = null;
			_list = null;
		}
	
	/**Public Function
	---------------------------*/
		public function set length(v:int):void{
			var h:int = (v + 1) * ITEM_H;
			_list = new AList(0,-h,ITEM_W,h);
			_list.visible = false;
			_list.filters = [new GlowFilter(0,1,6,6)];
			_list.name = '_list';
			this.addChild(_list);
			
			var all:AItem_ComboBox = new AItem_ComboBox;
			all.index = '';
			all.label = ALL;
			_list.addItem(all);
		}
		public function set text(v:String):void{
			_tfName.text = v;
		}
		public function get text():String{
			return _tfName.text;
		}
		public function addItem(item:DisplayObject):int{
			return _list.addItem(item);
		}
		public function getItemAt(index:int):*{
			return _list.getItemAt(index);
		}
		public function delItem(item:DisplayObject):void{
			_list.delItem(item);
		}
		public function delItemAt(index:int):void{
			_list.delItemAt(index);
		}
		
	/**Private Function
	---------------------------*/
		private function OnMouseOut_Show(e:MouseEvent):void{
			_list.visible = false;
		}
		private function OnMouseOver_Show(e:MouseEvent):void{
			_list.visible = true;
		}
		private function OnClick_Select(e:AListEvent):void {
			this.selectedIndex = parseInt(e.item.index);
			
			var ie:AListEvent = new AListEvent(AListEvent.ITEM_CLICK);
			ie.item = e.item;
			dispatchEvent(ie);
			
			_list.visible = false;
		}
	}
}