package __src.ui{
	import flash.events.Event;
	// class
	public class AScrollBarEvent extends Event
	{
	/**Public Const
	---------------------------*/	
		public static const SCROLL:String = "S";

	/**Public Variable
	---------------------------*/	
		public var percent:Number;
		
	/**Construct & Destruct
	---------------------------*/
		public function AScrollBarEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false){
			super(type,bubbles,cancelable);
		}
	}
}