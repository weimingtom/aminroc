package src{
	// 导入包
	import def.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	// 主类
	public class Cell extends Sprite {
	/**私有变量
	---------------------------*/
		private var nRow:int;		// 当前行
		private var nCol:int;		// 当前列

	/**构造 & 析构
	---------------------------*/	
		// 构造函数
		public function Cell(row:int,col:int){
			nRow = row;
			nCol = col;
			x = nCol * _G.CELL_W;
			y = nRow * _G.CELL_H;	
		}
		
	/**公共函数
	---------------------------*/
		// 是否阻塞
		public function isBlock():Boolean{
			for(var i:int = 0;i < numChildren;++ i)
			{
				var child:* = getChildAt(i);
				if(child.nBlock == true)
					return true;
			}
			return false;
		}
	}
}