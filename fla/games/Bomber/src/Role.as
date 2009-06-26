package src{
	// 导入包
	import def.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.utils.*;
	// 主类
	public class Role extends MovieClip {
	/**舞台变量
	---------------------------*/
		public var mcCartoon:MovieClip;
		public var tfName:TextField;
		
	/**私有常量
	---------------------------*/
		public const RUN_DIRECTION_LEFT:int = 1;
		public const RUN_DIRECTION_UP:int = 2;
		public const RUN_DIRECTION_RIGHT:int = 3;
		public const RUN_DIRECTION_DOWN:int = 4;
		public const SPEED_LIMIT:int = 8;
		
	/**公有变量
	---------------------------*/
		public var nStatus:int;
		public var nCurBombs:int;
		public var nIndex:int;

		public var nSpeed:int;
		public var nBombLimit:int;
		public var nBombPower:int;
		public var nBombRange:int;
		
		public var nCurRow:int;				// 当前行
		public var nCurCol:int;				// 当前列
		
		public var bResult:Boolean = true;	// 胜负结果

		public var argLine:Array = [];
		public var nStep:int;				// 移动步数
		
	/**私有变量
	---------------------------*/
		private var nMID:uint;				// 移动ID
		private var nLID:uint;				// 循环ID
		
		private var nDirection:int;			// 移动方向

		private var strName:String;
		private var bNext:Boolean = true;
		
		private var nGoalX:int;
		private var nGoalY:int;
		
		private var argVT:Array;
		
	/**私有常量
	---------------------------*/
		private const OFFSET_X:int = _G.CELL_W / 2;
		private const OFFSET_Y:int = _G.CELL_H / 2;
		private const RUN_DISTANCE:int = 1000;
		private const RUN_TIME:int = 26100; 	// 毫秒级
		private const LOOP_INTERVAL:int = 20; 	// 小宇宙循环时间
		private const INFINITE_LEN:int = 10000; // 无限移动长度
			
	/**构造 & 析构
	---------------------------*/
		// 构造函数
		public function Role(index:int,name1:String,row:uint,col:uint,bombLimit:uint,bombPower:uint,bombRange:uint,speed:uint){
			addEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFormStage);
			
			strName = name1;
			tfName.text = strName;
			// ------------------------
			nIndex = index;
			nStatus = ROLE.NORMAL;
			nCurBombs = bombLimit;
			// ------------------------
			nSpeed = speed;
			nBombLimit = bombLimit;
			nBombPower = bombPower;
			nBombRange = bombRange;
			// ------------------------
			nMID = 0;
			nStep = 5;
			// ------------------------
			nCurRow = row;
			nCurCol = col;
			x = col * _G.CELL_W + OFFSET_X;
			y = row * _G.CELL_H + OFFSET_Y;
		}
		// 添加到舞台
		private function OnAddedToStage(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			
			// 监听爆炸事件
			_G.CELLS[nCurRow][nCurCol].addEventListener(GameEvent.BE_BLAST,OnBeBlast);
			// 监听角色事件
			_G.CELLS[nCurRow][nCurCol].addEventListener(GameEvent.BE_TOUTH,OnBeTouch);
			
			// 调整Z轴
			var zCell:Cell = _G.CELLS[nCurRow][_G.CELLS[nCurRow].length - 1];
			var cellIndex:int = parent.getChildIndex(zCell);
			var roleIndex:int = parent.getChildIndex(this);
			var inc:int = cellIndex < roleIndex ? 1 : 0;
			parent.setChildIndex(this,cellIndex + inc);
			
			nLID = setInterval(universe,LOOP_INTERVAL);
		}
		// 析构函数
		private function OnRemovedFormStage(e:Event):void{
			removeEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFormStage);
			
			clearInterval(nLID);
			clearInterval(nMID);
		}
		
	/**公共函数
	---------------------------*/
		// 设置名字
		public function setName(n:String):void{
			strName = n;
			tfName.text = strName;
		}
		// 获得名字
		public function getName():String{
			return strName;
		}
		// 扔炸弹
		public function dropBomb(row:int,col:int):void{
			// 添加炸弹
			_G.CELLS[row][col].addChild(new Bomb(this,nBombPower,nBombRange));
		}
		// 被撞到
		public function BeFire(_x:int,_y:int):void{
			x = _x;
			y = _y;
			nStatus = ROLE.FIRE;
			nStep = 1;
			gotoAndStop('fire');
		}
		// 结束
		public function over():void{
			// 清掉移动ID
			if(nMID){clearInterval(nMID);nMID = 0;}
			// 设置状态
			bResult = false;
			nStatus = ROLE.OVER;
			// 解除事件				
			removeEventListener(GameEvent.BE_BLAST,OnBeBlast);
			removeEventListener(GameEvent.BE_TOUTH,OnBeTouch);
			gotoAndStop('over');
		}
		// 被触到事件(Role影片里需要调用到,所以是public)
		public function OnBeTouch(e:GameEvent):void{
			// 被击中
			if(nStatus == ROLE.FIRE){
				if(nIndex == Bomber(root).nMyIndex){
					nStatus = ROLE.OVER;
					Bomber(root).TE.broadcast(GameEvent.OVER);
				}
			}
		}
		
	/**私有函数
	---------------------------*/
		// 被炸到事件
		private function OnBeBlast(e:GameEvent):void{
			// 状态正常
			if(nStatus == ROLE.NORMAL){
				if(nIndex == Bomber(root).nMyIndex){
					nStatus = ROLE.FIRE;
					Bomber(root).TE.broadcast(GameEvent.BE_FIRE +_G.SPLIT + x + _G.SPLIT + y);
				}
			}
		}
		// 小宇宙
		private function universe():void{
			// 不获取下个动作则返回
			if(!bNext){
				return;
			}
			// 获得当前线路
			var curLine:Array = argLine.shift();
			// 没有则返回
			if(!curLine){
				return;
			}
			// 获得事件
			var ge:String = curLine[0];
			// 移动事件
			if(ge == GameEvent.MOVE){
				nGoalX = INFINITE_LEN;
				nGoalY = INFINITE_LEN;
				run(parseInt(curLine[1]));
			}
			// 移到目标地址
			else if(ge == GameEvent.MOVETO){
				nGoalX = parseInt(curLine[1]);
				nGoalY = parseInt(curLine[2]);
				bNext = false;
			}
		}
		// 运动
		private function run(direction:int):void{
			// 清掉移动ID
			if(nMID){clearInterval(nMID);nMID = 0;}

			// 移动样式
			if(nStatus == ROLE.NORMAL){
				// 播放动画
				if(nDirection == direction){
					mcCartoon.play();
				}
				else{
					gotoAndStop(direction + 1);
				}
			}
			// 保存方向
			nDirection = direction;
			var totalTime:int = RUN_TIME - nSpeed * 100;
			var interval:Number =  totalTime / RUN_DISTANCE;
			// 移动
			if(direction == RUN_DIRECTION_LEFT){
				argVT = [-1,0];
				nMID = setInterval(move,interval,argVT);
			}
			else if(direction == RUN_DIRECTION_UP){
				argVT = [0,-1];
				nMID = setInterval(move,interval,argVT);
			}
			else if(direction == RUN_DIRECTION_RIGHT){
				argVT = [1,0];
				nMID = setInterval(move,interval,argVT);
			}
			else{
				argVT = [0,1];
				nMID = setInterval(move,interval,argVT);
			}
		}
		// 停止
		private function stand():void{
			// 清掉移动ID
			if(nMID){clearInterval(nMID);nMID = 0;}
			// 停止动画
			if(nStatus == ROLE.NORMAL && mcCartoon){
				mcCartoon.gotoAndStop(1);
			}
		}
		// 移动
		private function move(vt:Array):void{
			// 下个移动坐标
			var x_move:int = vt[0] * nStep;
			var y_move:int = vt[1] * nStep;

			// 不是无限移动中
			if(nGoalX != INFINITE_LEN){
				var fix:Boolean = false;
				// 修复移动
				if(nDirection == RUN_DIRECTION_LEFT){
					if(x + x_move <= nGoalX){
						fix = true;
					}
				}
				else if(nDirection == RUN_DIRECTION_UP){
					if(y + y_move <= nGoalY){
						fix = true;
					}
				}
				else if(nDirection == RUN_DIRECTION_RIGHT){					
					if(x + x_move >= nGoalX){
						fix = true;
					}
				}
				else{
					if(y + y_move >= nGoalY){
						fix = true;
					}
				}
				if(fix){
					x = nGoalX;
					y = nGoalY;
					// 停止移动
					stand();
					// 获取下个指令
					bNext = true;
					return;
				}
			}
			// 得到两点坐标
			var x_1:int;var y_1:int;var x_2:int;var y_2:int;
			// 向右
			if(vt[0] == 1){
				x_1 = x + OFFSET_X + nStep;
				y_1 = y - OFFSET_Y;
				x_2 = x + OFFSET_X + nStep;
				y_2 = y + OFFSET_Y;
			}
			// 向左
			else if(vt[0] == -1){
				x_1 = x - OFFSET_X - nStep;
				y_1 = y - OFFSET_Y;
				x_2 = x - OFFSET_X - nStep;
				y_2 = y + OFFSET_Y;
			}
			// 向下
			else if(vt[1] == 1){
				x_1 = x - OFFSET_X;
				y_1 = y + OFFSET_Y + nStep;
				x_2 = x + OFFSET_X
				y_2 = y + OFFSET_Y + nStep;
			}
			// 向上
			else{
				x_1 = x - OFFSET_X;
				y_1 = y - OFFSET_Y - nStep;
				x_2 = x + OFFSET_X
				y_2 = y - OFFSET_Y - nStep;			
			}
			// 两点所在单元格
			var _row_1:Number = y_1 / _G.CELL_H;
			var _col_1:Number = x_1 / _G.CELL_W;
			var _row_2:Number = y_2 / _G.CELL_H;
			var _col_2:Number = x_2 / _G.CELL_W;
			var row_1:int = int(_row_1);
			var col_1:int = int(_col_1);
			var row_2:int = int(_row_2);
			var col_2:int = int(_col_2);
			// 单元格状态
			var cell_1:Cell;
			var cell_2:Cell;
			var block_1:Boolean;
			var block_2:Boolean;
			// 补正
			var paddingX:int = 0;
			var paddingY:int = 0;
			// 第一单元格阻挡判断
			if(_row_1 < 0 || _col_1 < 0 || _row_1 >= _G.CELLS.length || _col_1 >= _G.CELLS[0].length){
				block_1 = true;
			}
			else{
				cell_1 = _G.CELLS[row_1][col_1];
				block_1 = cell_1.isBlock();
			}
			// 第二单元格阻挡判断
			if(_row_2 < 0 || _col_2 < 0 || _row_2 >= _G.CELLS.length || _col_2 >= _G.CELLS[0].length){
				block_2 = true;
			}
			else{
				cell_2 = _G.CELLS[row_2][col_2];
				block_2 = cell_2.isBlock();
			}
			// 是否在中心线
			var centerX:Boolean = vt[1] && (x % _G.CELL_W == OFFSET_X);
			var centerY:Boolean = vt[0] && (y % _G.CELL_W == OFFSET_Y);
			// 帖x轴移动
			if(!block_1 && centerX){
				y += y_move;
			}
			// 帖y轴移动
			else if(!block_1 && centerY){
				x += x_move;
			}
			// 跨格全无阻挡
			else if(!block_1 && !block_2){
				x += x_move;
				y += y_move;
			}
			else{
				// 补进空隙
				paddingX = vt[0] && (nCurCol + 1) * _G.CELL_W - OFFSET_X - x;
				paddingY = vt[1] && (nCurRow + 1) * _G.CELL_H - OFFSET_Y - y;
				if(paddingX > 0){
					x += (paddingX > x_move ? x_move : paddingX);
				}
				else if(paddingX < 0){
					x += (paddingX < x_move ? x_move : paddingX);
				}
				else if(paddingY > 0){
					y += (paddingY > y_move ? y_move : paddingY);
				}
				else if(paddingY < 0){
					y += (paddingY < y_move ? y_move : paddingY);
				}
				else{
					// 帖线移动且阻挡
					if(centerX || centerY){
						return; // 不用更新坐标
					}
					// 全挡
					if(block_1 && block_2){
						return;	// 不用更新坐标
					}
					// 无阻挡处自动吸引
					else{
						if(!block_1){
							x -= vt[1] * y_move;
							y -= vt[0] * x_move; 
						}
						else{
							x += vt[1] * y_move;
							y += vt[0] * x_move; 
						}
					}
				}
			}
			// 显示坐标
			if(nIndex == Bomber(root).nMyIndex){
				root['tfX'].text = x;
				root['tfY'].text = y;
			}
			// 更新坐标
			var row:int = uint(y / _G.CELL_H);
			var col:int = uint(x / _G.CELL_W);
			if(row == nCurRow && col == nCurCol){
				return;
			}
			// 调整Z轴
			if(nCurRow != row){
				var zCell:Cell = _G.CELLS[row][_G.CELLS[row].length - 1];
				var cellIndex:int = parent.getChildIndex(zCell);
				var roleIndex:int = parent.getChildIndex(this);
				var inc:int = cellIndex < roleIndex ? 1 : 0;
				parent.setChildIndex(this,cellIndex + inc);
			}
			
			// 旧单元格
			var oldCell:Cell = _G.CELLS[nCurRow][nCurCol];
			// 解除监听事件
			oldCell.removeEventListener(GameEvent.BE_BLAST,OnBeBlast);
			oldCell.removeEventListener(GameEvent.BE_TOUTH,OnBeTouch);
				
			// 新单元格
			var newCell:Cell = _G.CELLS[row][col];
			// 解发角色事件
			var en:GameEvent = new GameEvent(GameEvent.BE_TOUTH);
			en.src = this;
			newCell.dispatchEvent(en);
			// 监听事件
			newCell.addEventListener(GameEvent.BE_BLAST,OnBeBlast);
			newCell.addEventListener(GameEvent.BE_TOUTH,OnBeTouch);
			
			// 更新中心点索引坐标
			nCurRow = row;
			nCurCol = col;
		}
	}
}