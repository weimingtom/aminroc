/**
 * Developed by AminLab
 * ------------------------------------
 * date:2009-06-02
 * site:http://www.aminLab.cn
 * ------------------------------------
 */
package src{
	// 导入公共包
	import T.*;
	
	import def.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.text.TextField;
	import flash.utils.*;
	// 主类
	public class Bomber extends Sprite{
	/**舞台变量
	---------------------------*/
		public var tfCurBombs:TextField;
		public var tfCurPower:TextField;
		public var tfCurRange:TextField;
		public var tfCurSpeed:TextField;
	
	/**公有变量
	---------------------------*/
		// 布局
		public var spLayout:Layout;
		// 场景
		public var objLayout:Object;
		// 是否已经结束
		public var bEnd:Boolean = false;
		// 平台插件
		public var TE:TEmbed;
		// 自己的索引
		public var nMyIndex:uint;
		// 用户信息
		public var argUserInfo:Array;
		// 炸弹索引
		public var nBombIndex:int = 1;

	/**私有变量
	---------------------------*/
		// 角色集合
		private var argRole:Array;
		// 主方向
		private var nD1:*;
		// 副方向
		private var nD2:*;
		// 当前玩家人数
		private var nCurPlayerNum:int = 0;
		// 炸弹弹冷却时间
		private var nBombTime:Number = new Date().getTime();
		
	/**私有常量
	---------------------------*/
		// 放炸弹延时时间
		public const DROPBOMB_DELAY:int = 50;
		// 炸弹冷却时间
		public const BOMB_FROST_TIME:int = 50;

	/**构造 & 析构
	---------------------------*/
		// 构造函数
		public function Bomber():void{
			addEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFormStage);
		}
		// 添加到舞台
		private function OnAddedToStage(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE,OnAddedToStage);

			objLayout = {
				// 地表布局
				ground : [[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
						[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
						[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
						[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
						[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
						[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
						[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
						[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
						[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
						[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]],
				// 建筑布局
				cell : [[0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0],
						[0,1,1,0,1,1,3,3,3,3,3,1,1,0,1,1,0],
						[1,1,2,0,1,1,0,0,0,0,0,1,1,0,2,1,1],
						[0,0,0,0,1,1,0,4,4,4,0,1,1,0,0,0,0],
						[0,1,1,0,1,1,0,4,2,4,0,1,1,1,1,0,1],
						[0,1,1,0,1,1,0,4,2,4,0,1,1,1,0,1,0],
						[0,0,0,0,1,1,0,4,4,4,0,1,1,0,0,0,0],
						[1,1,2,0,1,1,0,0,0,0,0,1,1,0,2,1,1],
						[0,1,1,0,1,1,3,3,3,3,3,1,1,0,1,1,0],
						[0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0]],
				// 物品布局
				item : [[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
						[0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0],
						[0,0,4,0,0,0,0,0,0,0,0,0,0,0,1,0,0],
						[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
						[0,2,0,0,0,1,0,0,3,0,0,2,0,0,1,0,3],
						[1,0,3,0,0,1,0,0,3,0,0,2,0,0,0,2,0],
						[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
						[0,0,3,0,0,0,0,0,0,0,0,0,0,0,2,0,0],
						[0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,3,0],
						[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]]
			}
						
			// 创建场景
			spLayout = new Layout(objLayout);
			spLayout.x = 20;
			spLayout.y = 43;
			addChild(spLayout);
			// 监听事件
			stage.addEventListener(KeyboardEvent.KEY_DOWN,OnKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP,OnKeyUp);
						
			// 创建并添加平台插件
			TE = new TEmbed();
			addChild(TE);
			// 监听平台事件
			this.addEventListener(TEvent.OffLine,OnOffLine);
			this.addEventListener(TEvent.Message,OnMessage);
			// 保存自己的用户索引
			nMyIndex = TE.getMyIndex();
			// 保存用户信息
			argUserInfo = TE.getUserInfos();
			// 创建角色组
			argRole = new Array(argUserInfo.length);
			// 创建角色
			var user:TUser;var attribute:Array;
			var row:int;var col:int;
			for(var i:int = 0;i < 4;++i){
				user = argUserInfo[i];
				if(!user){
					continue;
				}
				// 增加游戏人数
				++ nCurPlayerNum;
				// 判断索引
				switch(user.index){
					case 1:
						row = 0;col = 0;
					break;
					case 2:
						row = 0;col = _G.CELLS[0].length - 1;
					break;
					case 3:
						row = _G.CELLS.length - 1;col = 0;
					break;
					case 4:
						row = _G.CELLS.length - 1;col = _G.CELLS[0].length - 1;
					break;
				}
				// 角色属性
				// 0 - 炸弹上限
				// 1 - 炸弹威力
				// 2 - 炸弹范围
				// 3 - 速度
				attribute = [3,1,1,1];
				// 创建人物
				var role:Role = new Role(user.index,user.name,row,col,attribute[0],attribute[1],attribute[2],attribute[3]);
				// 初始化属性
				tfCurBombs.text = attribute[0] + '/' + attribute[0];
				tfCurPower.text = attribute[1];
				tfCurRange.text = attribute[2];
				tfCurSpeed.text = attribute[3];
				// 加到单元格上
				argRole[i] = spLayout.spCell.addChild(role);
			}
			// 开始游戏前有人退出了
			if(nCurPlayerNum < 2){
				nCurPlayerNum = 2;
				isGameOver(0);
			}
		}
		// 析构
		private function OnRemovedFormStage(e:Event):void{
			removeEventListener(Event.REMOVED_FROM_STAGE,OnRemovedFormStage);
			
			stage.removeEventListener(KeyboardEvent.KEY_DOWN,OnKeyDown);
			stage.removeEventListener(KeyboardEvent.KEY_UP,OnKeyUp);
			
			this.removeEventListener(TEvent.OffLine,OnOffLine);
			this.removeEventListener(TEvent.Message,OnMessage);
			
			argUserInfo = null;
			TE.parent.removeChild(TE);
			TE = null;
		}

	/**私有函数
	---------------------------*/
		// 键盘事件(按下)
		private function OnKeyDown(e:KeyboardEvent):void{
			var tid:int;
			if(e.keyCode == 65){ e.keyCode = 37 }
			else if(e.keyCode == 87){ e.keyCode = 38 } 
			else if(e.keyCode == 68){ e.keyCode = 39 } 
			else if(e.keyCode == 83){ e.keyCode = 40 }
			// 我的角色
			var role:Role = argRole[nMyIndex - 1];
			// 方向键
			if(e.keyCode >= 37 && e.keyCode <= 40){
				// 已按下两个方向
				if(nD1 && nD2)
					return
				// 与已按下方向一致
				if(nD1 == e.keyCode || nD2 == e.keyCode)
					return
				var direction:int;
				// 副方向置主
				if(nD1){
					nD2 = nD1;			// 主方向置为副方向
					nD1 = e.keyCode;	// 保存主方向
					// 发送事件
					TE.broadcastButThis(GameEvent.MOVETO + _G.SPLIT + role.x + _G.SPLIT + role.y);
					// 本地动作
					role.argLine.push([GameEvent.MOVETO,role.x,role.y]);
					// 得到键值
					direction = nD1 - 36;
					// 发送事件通知其他玩家
					TE.broadcastButThis(GameEvent.MOVE + _G.SPLIT + direction);
					// 本地即时动作
					role.argLine.push([GameEvent.MOVE,direction]);
				}
				else{
					nD1 = e.keyCode;	// 保存主方向
					// 得到键值
					direction = nD1 - 36;
					// 发送事件通知其他玩家
					TE.broadcastButThis(GameEvent.MOVE + _G.SPLIT + direction);
					// 本地即时动作
					role.argLine.push([GameEvent.MOVE,direction]);
				}
			}
			// 空格键
			else if(e.keyCode == 32){
				// 玩家处于正常状态且炸弹量不为空
				if(role.nStatus == ROLE.NORMAL && role.nCurBombs > 0){
					// 已过冷却时间
					var now:Number = new Date().getTime();
					if(now - nBombTime > this.BOMB_FROST_TIME){
						// 减少弹存
						-- role.nCurBombs;
						tfCurBombs.text = role.nCurBombs + '/' + role.nBombLimit;
						// 更新放置炸弹时间
						nBombTime = now;
						var row:int = role.nCurRow;
						var col:int = role.nCurCol;
						// 发送事件通知其他玩家
						TE.broadcastButThis(GameEvent.DROP_BOMB + _G.SPLIT + row + _G.SPLIT + col);
						// 本地延后动作
						tid = setTimeout(function():void{
							role.dropBomb(row,col);
							clearTimeout(tid);},
						DROPBOMB_DELAY);
					}
				}
			}
		}
		// 键盘事件(松开)
		private function OnKeyUp(e:KeyboardEvent):void{
			if(e.keyCode == 65){ e.keyCode = 37 } 
			else if(e.keyCode == 87){ e.keyCode = 38 } 
			else if(e.keyCode == 68){ e.keyCode = 39 } 
			else if(e.keyCode == 83){ e.keyCode = 40 }
			// 我的角色
			var role:Role = argRole[nMyIndex - 1];
			var direction:int;
			// 方向键
			if(e.keyCode >= 37 && e.keyCode <= 40){
				// 主方向放开
				if(nD1 == e.keyCode){
					// 发送事件通知其他玩家
					TE.broadcastButThis(GameEvent.MOVETO + _G.SPLIT + role.x + _G.SPLIT + role.y);
					// 本地即时动作
					role.argLine.push([GameEvent.MOVETO,role.x,role.y]);
					// 是否有副方向
					if(nD2){
						nD1 = nD2;	// 使用副方向
						nD2 = null;				
						// 得到键值
						direction = nD1 - 36;
						// 发送事件
						TE.broadcastButThis(GameEvent.MOVE + _G.SPLIT + direction);
						// 本地动作
						role.argLine.push([GameEvent.MOVE,direction]);
					}
					else{	
						nD1 = null;	// 清空方向
					}
	
				}
				// 副方向放开
				else if(nD2 == e.keyCode){
					nD2 = null;		// 清空方向
				}
			}
			// 空格键
			else if(e.keyCode == 32){
				nBombTime -= this.BOMB_FROST_TIME;
			}
		}
		// 是否游戏结束
		private function isGameOver(index:int):void{
			// 减少人数
			-- nCurPlayerNum;
			// 游戏结束
			if(nCurPlayerNum == 1){
				var end:TheEnd = new TheEnd;
				addChild(end);
				var str:String = '';
				var role:Role;
				for(var i:int = 0;i < argRole.length;++i){
					role = argRole[i];
					if(!role){
						continue;
					}
					if(role.bResult == true){
						str += '[胜利]' + (i+1) + '.' + role.getName();
					}
					else{
						str += '[失败]' + (i+1) + '.' +  role.getName();
					}
					str += '\n';
				}
				end['tfResult'].text = str;
			}
		}
		// 接收消息事件
		private function OnMessage(e:TEvent):void{
			// 临时对象
			var temp:*;
			var tid:int;
			// 解析数据
			var data:Array = e.data.split(_G.SPLIT);
			// 获取角色对象
			var role:Role = argRole[e.fromIndex - 1];
			// 获取事件
			var ge:String = data[0];
			// 移动
			if(ge == GameEvent.MOVE || ge == GameEvent.MOVETO){
				role.argLine.push(data);
			}
			// 丢炸弹
			if(ge == GameEvent.DROP_BOMB){
				temp = this.DROPBOMB_DELAY - e.delay;
				if(temp <= 0){ 
					role.dropBomb(parseInt(data[1]),parseInt(data[2])); // 已经超时,立马放弹
				}
				else{
					tid = setTimeout(function():void{
						role.dropBomb(parseInt(data[1]),parseInt(data[2]));
						clearTimeout(tid);},
					temp);
				}
			}
			// 被炸到
			else if(ge == GameEvent.BE_FIRE){e.delay
				role.BeFire(parseInt(data[1]),parseInt(data[2]));
			}
			// 结束
			else if(ge == GameEvent.OVER){
				role.over();
				isGameOver(role.nIndex);	// 检查是否游戏结束
			}
			// 显示延时
			root['tfDelay'].text = e.delay;
		}
		// 断线事件
		private function OnOffLine(e:TEvent):void{
			var role:Role = argRole[e.fromIndex - 1];
			role.bResult = false;
			role.setName('(断线)' + role.getName());
			isGameOver(e.fromIndex);
		}
	}
}