/**
 * Developed by AminLab
 * ------------------------------------
 * date:2009-05-26
 * site:http://www.aminLab.cn
 * ------------------------------------
 */
package com.al{
	// class
	public class AJson {
	/**Public Function
	---------------------------*/
		public static function encode(e:Object):String {
			var d:Array = new Array();
			for(var i:String in e){
				if(e[i] is String)
					d.push(i + ":'" + e[i] + "'");
				else
					d.push(i + ":" + e[i]);
			}
			return '{' + d.join(',') + '}';
		}
		public static function decode(str:String):* {
			var e:Object = {};
			str = str.replace( /^\s*{|}\s*$/g,"");
			var ds:Array = str.split(',');
			for(var i:int = 0;i < ds.length;++i){
				var d:Array = ds[i].split(':');
				var len:int = d[1].length;
				
				d[1] = d[1].replace( /^\s*['|"]|['|"]\s*$/g,"");
				d[0] = d[0].replace(/\s*/g,"");
				
				if(len == d[1].length)
					e[d[0]] = Number(d[1]);
				else
					e[d[0]] = d[1];
			}
			return e;
		}
	}
}