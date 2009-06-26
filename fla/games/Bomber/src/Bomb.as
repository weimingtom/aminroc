package src{
	// 导入包
	import def.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.utils.*;
	// 主类
	public class Bomb extends MovieClip {
	/**公共常量
	---------------------------*/
		public static const BLAST_TIME:int = 1800;
		
	/**公共变量
	---------------------------*/
		public var nBlock:Boolean = true;
		public var nPower:uint;
		public var nRange:uint;
		
	/**私有变量
	---------------------------*/
		private var nTimeId:uint;
		private var pRole:Role;
		
	/**构造 & 析构
	---------------------------*/
		// 构造函数
		public function Bomb(role:Role,power:uint,range:uint){
			addEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			
			pRole = role;
			nPower = power;
			nRange = range;
		}
		// 添加到舞台
		private function OnAddedToStage(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			// 编号
			name = Bomber(root).nBombIndex.toString();
			// 监听单元格事件
			parent.addEventListener(GameEvent.BE_BLAST,OnBeBlast);
			// 启动爆炸定时器
			nTimeId = setTimeout(OnBeBlast,BLAST_TIME,null);
		}
		
	/**私有函数
	---------------------------*/
		// 被炸到事件
		private function OnBeBlast(e:GameEvent):void{
			parent.removeEventListener(GameEvent.BE_BLAST,OnBeBlast);
			if(!nTimeId)
				return;
			// 关闭定时器
			clearTimeout(nTimeId);
			nTimeId = 0;
			// 得到位置
			var curRow:int = uint(parent.y / _G.CELL_H);
			var curCol:int = uint(parent.x / _G.CELL_W);
			var ranges:Array = [[],[],[],[]];

			var L:Array;var R:Array;var U:Array;var D:Array;
			// 计算爆炸范围
			for(var i:int = 1;i <= nRange;++i){
				L = [curRow,curCol - i];
				U = [curRow - i,curCol];
				R = [curRow,curCol + i];
				D = [curRow + i,curCol];
				// 判断格子是否有效
				if(L[1] >= 0){
					ranges[0].push(L);
				}
				if(U[0] >= 0){
					ranges[1].push(U);
				}
				if(R[1] < _G.CELLS[0].length){
					ranges[2].push(R);
				}
				if(D[0] < _G.CELLS.length){
					ranges[3].push(D);
				}
			}

			// 中心爆炸
			gotoAndStop(2);
			var cell:Cell = Cell(parent);
			var ce:GameEvent = new GameEvent(GameEvent.BE_BLAST);
			ce.src = this;
			cell.dispatchEvent(ce);
			
			// 周边爆炸
			var pt:Array;var cell_x:int;var cell_y:int;
			var sp:Spray;var line:Array;
			for(var j:int = 0;j < ranges.length;++j)
			{
				line = ranges[j];
				// 方向行列爆炸
				for(var k:int = 0;k < line.length; ++k){
					// 得到单元格对象
					pt = line[k];
					cell = _G.CELLS[pt[0]][pt[1]];
					// 触发爆炸事件
					ce = new GameEvent(GameEvent.BE_BLAST);
					ce.src = this;
					cell.dispatchEvent(ce);
					// 后继判断
					if(cell.isBlock()){
						break;	// 有阻挡不再爆炸后面的方格
					}
					else{
						sp = new Spray;
						// 播放爆炸浪花的方向
						if(k == line.length - 1){sp.gotoAndStop(j + 5); }
						else{ sp.gotoAndStop(j + 1);}
						// 添加浪花
						cell.addChild(sp);
					}
				}
			}
			// 归还弹存
			var spRoot:Bomber = Bomber(root);
			if(spRoot.nMyIndex == pRole.nIndex){
				++ pRole.nCurBombs;
				spRoot.tfCurBombs.text = pRole.nCurBombs + '/' + pRole.nBombLimit;
			}
		}
	}
}