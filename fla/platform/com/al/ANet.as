/**
 * Developed by AminLab
 * ------------------------------------
 * date:2009-05-26
 * site:http://www.aminLab.cn
 * ------------------------------------
 */
package com.al{
	// import public package
	import flash.errors.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.ByteArray;
	// class
	public class ANet extends Socket {
	/**Private Variable
	---------------------------*/
		// dava saver
		private var argData:Array;

	/**Public Const
	---------------------------*/
		public static const _ED_:int = 0;			// package delimiter
		public static const _CB_:int = 1;			// combo delimiter
		public static const _EN_:String = "\x03";	// event delimiter
		public static const _1_:String  = "\x16";
		public static const _2_:String  = "\x1E";
			
	/**Private Const
	---------------------------*/
		// charset
		private const _CS_:String = 'gb2312';
		
	/**Public Function
	---------------------------*/
		public function ANet(host:String = null, port:uint = 0) {
			super(host,port);
			this.argData = new Array;
			addEventListener(ProgressEvent.SOCKET_DATA, OnRecv);
		}
		private function OnRecv(e:ProgressEvent):void {
			if (this.bytesAvailable) {
				// read data
				var data:ByteArray = new ByteArray  ;
				this.readBytes(data,0,0);
				// search delimiter
				var lastIndex:int = 0;
				var de:DataEvent;
				for(var i:int = 0; i < data.length; ++i) {
					if(data[i] <= ANet._CB_) {
						this.argData.push(data.readMultiByte(i - lastIndex,this._CS_));
						lastIndex = i;
						data.position = lastIndex+1;
						de = new DataEvent(DataEvent.DATA);
						de.data = this.argData.join('');
						dispatchEvent(de);
						this.argData.length = 0;
					}
				}
				// save leave data
				if (lastIndex != data.length-1) {
					this.argData.length = 0;
					this.argData.push(data.readMultiByte(data.bytesAvailable,this._CS_));
				}
			}
		}
		public function send(str:String):void {
			this.writeMultiByte(str,this._CS_);
			this.writeByte(ANet._ED_);
			this.flush();
		}
	}
}