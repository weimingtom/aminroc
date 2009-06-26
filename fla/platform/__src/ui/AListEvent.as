package __src.ui{
	// import public package
	import flash.events.Event;
	// class
	public class AListEvent extends Event
	{
	/**Public Const
	---------------------------*/	
		public static const ITEM_CLICK:String = "IC";

	/**Public Variable
	---------------------------*/	
		public var item:*;
		
	/**Construct & Destruct
	---------------------------*/
		public function AListEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false){
			super(type,bubbles,cancelable);
		}
	}
}