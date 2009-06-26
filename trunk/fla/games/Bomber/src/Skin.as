package src{
	// 导入包
	import def.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	// 主类
	public class Skin extends MovieClip {
	/**私有变量
	---------------------------*/
		private var nRow:int;		// 当前行
		private var nCol:int;		// 当前列
		private var nIndex:int;		// 样式索引

	/**构造 & 析构
	---------------------------*/
		// 构造函数
		public function Skin(index:int,row:int,col:int){
			nRow = row;
			nCol = col;
			nIndex = index;
			x = nCol * _G.CELL_W;
			y = nRow * _G.CELL_H;
			gotoAndStop(nIndex);
		}
	}
}