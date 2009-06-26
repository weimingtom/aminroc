/**
 * Developed by AminLab
 * ------------------------------------
 * date:2009-05-26
 * site:http://www.aminLab.cn
 * ------------------------------------
 */
package com.al{
	// import public package
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	// class
	public class ATween{
	/**Private Const
	---------------------------*/
		// frames per second
		static private const FPS:Number = 75;					
		// time per time
		static private const TPT:Number = Math.round(1000 / FPS);
		
	/**Public Function
	---------------------------*/
		static public function to(src:*,time:Number,props:Object,fnComplete:Function = null,argParams:Array = null):uint{
			var envir:Object = {id:0,times:0,complete:fnComplete,params:argParams,startTime:0,execTimes:0,spendTime:0};
			var srcValue:*;var dstVaule:*;var offset:Number;var step:Number;
			var upSet:Array = new Array;
			
			envir.times = Math.round(time / TPT);
			
			for(var key:String in props){
				srcValue = src[key];
				dstVaule = props[key];
				offset = dstVaule > srcValue ? dstVaule - srcValue : -(srcValue - dstVaule);
				step = Math.round(offset / envir.times * 100) / 100;
				upSet.push([key,step,dstVaule]);
			}
			envir.startTime = getTimer();
			envir.id = setInterval(_to,TPT,envir,src,upSet);
			return envir.id;
		}
		static public function kill(tid:uint):void{
			tid && clearInterval(tid);
		}
		
	/**Private Function
	---------------------------*/
		static private function _to(envir:Object,src:*,upSet:Array):void{
			++ envir.execTimes;
			var nowTime:int = getTimer();
			envir.spendTime +=  (nowTime - envir.startTime);
			envir.startTime = nowTime;
			
			var key:String;
			var step:Number;
			var newValue:Number;
			var dstValue:Number;

			-- envir.times;
			if(envir.times > 0){
				for(var i:int = 0;i < upSet.length;++i){
					key = upSet[i][0];
					step = upSet[i][1];
					src[key] = src[key] + step;
				}
			}
			else{
				for(var j:int = 0;j < upSet.length;++j){
					key = upSet[j][0];
					dstValue = upSet[j][2];
					src[key] = dstValue;
				}
				if(envir.complete){
					envir.complete.apply(null,envir.params);
				}
				
				envir.id && clearInterval(envir.id);
				envir = null;
				src = null;
				upSet = null;
			}
		}
	}
}