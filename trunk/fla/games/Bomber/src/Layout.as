package src{
	// 导入包
	import def.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	// 主类
	public class Layout extends Sprite {
	/**公共变量
	---------------------------*/		
		// 地表层
		public var spGround:Sprite;
		// 单元层
		public var spCell:Sprite;
		
	/**构造 & 析构
	---------------------------*/
		// 构造函数
		public function Layout(arg:Object){
			// 创建层
			spGround = new Sprite();
			spCell = new Sprite();
			
			var cell:*;
			var skin:*
			var rowlen:int = arg.ground.length;
			var collen:int = arg.ground[0].length;
			var cols:*;
			
			// 初始化地表
			for (var i:int = 0; i < rowlen; ++i) {
				// 压入行
				_G.CELLS.push([]);
				cols = _G.CELLS[_G.CELLS.length - 1];
				for (var j:int = 0; j < collen; ++j){
					// 创建皮肤
					skin = new Skin(arg.ground[i][j],i,j);
					spGround.addChild(skin);
					// 创建单元格
					cell = new Cell(i,j);
					var cv:* = arg.cell[i][j];
					if(cv){
						cell.addChild(new Box(cv,cv));
					}
					
					cols.push(spCell.addChild(cell));
				}
			}
			
			// 加入组层
			addChild(spGround);
			addChild(spCell);
		}
	}
}