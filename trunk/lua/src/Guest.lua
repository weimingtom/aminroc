-- 游客状态
_G[NODE.STATUS.GUEST] = {

	-- 请求进入
	[AEvent.REQUEST_TO .. USER.POS.FREE] = function(user,dataEx)
		-- 得到明文
		local cyp,msg = KEYER.make();
		-- 1.更新属性
		user.msg = msg;
		user.pos = USER.POS.VALIDATE;
		-- 2.发送消息
		CNetSend(user.socket,AEvent.REQUEST_TO .._EN_.. cyp);
	end,

	-- 验证身份
	[AEvent.VALIDATE_ID .. USER.POS.VALIDATE] = function(user,dataEx)
		local arg = dataEx:split(_1_);
		-- 检验明文
		if user.msg ~= arg[1] then
			CNetSend(user.socket,AEvent.ERROR_MSG);
			return 1;
		end
		-- 检验名字
		if not arg[2] or string.len(arg[2]) > MAX_USER_NAME_LEN then
			CNetSend(user.socket,AEvent.ERROR_USER_NAME);
			return 1;
		end
		-- 1.更新属性
		user.pos = USER.POS.WAIT;
		user.name = arg[2];
		-- 2.发送消息
		CNetSend(user.socket,AEvent.VALIDATE_ID);
	end,

	-- 进入空间
	[AEvent.JOIN_ZONE .. USER.POS.WAIT] = function(user,dataEx)
		local zone = ROOT:getChildByName(dataEx);
		-- 没此空间
		if not zone then
			CNetSend(user.socket,AEvent.NOTEXIST_ZONE);
			return;
		end
		-- 空间满人
		if zone:isMaxOnline() then
			CNetSend(user.socket,AEvent.OVERFLOW_SOCKETS);
			return;
		end
		-- 1.更新属性
		user.pos = USER.POS.ZONE;
		user.tree = zone;
		-- 2.监听事件
		user:addEventListener(TreeEvent.ZONE_UPDATE);
		-- 3.发送消息
		CNetSend(user.socket,AEvent.JOIN_ZONE .._EN_.. zone.maxTeam);
	end,

	-- 读取队伍列表
	[AEvent.TEAM_LIST .. USER.POS.ZONE] = function(user,dataEx)
		-- 调试所用
		-- CNetSend(user.socket,"2232153asd1452789c1000245211c100b34510cvb44511cvb14512cvb24513cvb34514cvb14515cvb44516cvb14517cvb14518cvb145219cvb14520cvb14521cvb14522cvb1455000end34");
		CNetSend(user.socket,AEvent.TEAM_NUMBER .._EN_.. user.tree.numChildren .._CB_.. AEvent.TEAM_LIST .._EN_.. user.tree.style);
	end,

	-- 创建队伍
	[AEvent.CREATE_TEAM .. USER.POS.ZONE] = function(user,dataEx)
		-- 名字是否太长
		if not dataEx or string.len(dataEx) > MAX_TEAM_NAME_LEN then
			CNetSend(user.socket,AEvent.CREATE_TEAM_2);
			return;
		end
		-- 得到对象
		local zone = user.tree;
		-- zone的队伍数量是否达到上限
		if zone:isAppendChild() then
			CNetSend(user.socket,AEvent.OVERFLOW_TEAM);
			return;
		end
		-- 创建对象
		local team = Team:new();
		-- 1.更新属性
		team.name = dataEx;
		team.minUserForTeam = zone.minUserForTeam;
		team.maxUserForTeam = zone.maxUserForTeam;
		team.time = CGetTime();
		team.state = NODE.STATE.WAIT;
		team.owner = 1;	-- 拥有者
		-- 2.初始化
		team:init();

		-- 1.添加结点
		zone:appendChild(team);
		-- 2.自动加入队伍
		_G[user.status][AEvent.JOIN_TEAM .. USER.POS.ZONE](user,team.index);
		-- 3.派发新的队伍数量
		zone:dispatchEvent(TreeEvent.ZONE_UPDATE,AEvent.TEAM_NUMBER .._EN_.. zone.numChildren);
	end,

	-- 加入队伍
	[AEvent.JOIN_TEAM .. USER.POS.ZONE] = function(user,dataEx)

		-- 得到对象
		local zone = user.tree;
		local team = zone:getChildByIndex(tonumber(dataEx));

		-- 无此队伍
		if not team then
			CNetSend(user.socket,AEvent.NOTEXIST_TEAM);
			return;
		end
		-- 队员溢出
		if team:isAppendChild() then
			CNetSend(user.socket,AEvent.OVERFLOW_USER);
			return;
		end
		-- 1.解除监听事件
		user:removeEventListener(TreeEvent.ZONE_UPDATE);
		-- 2.更新属性
		user.pos = USER.POS.TEAM;
		user.state = NODE.STATE.WAIT;
		-- 3.添加结点
		team:appendChild(user);
		-- 4.发送消息
		CNetSend(user.socket,AEvent.JOIN_TEAM .._EN_.. team.index .._1_.. user.index .._1_.. team.minUserForTeam .._1_.. team.maxUserForTeam .._1_.. team.name .._1_.. team.owner);

		-- 1.格式化消息
		local msg = user:toString();
		-- 2.更新显示
		user:updateDisplay(msg,1);
		-- 3.广播事件
		team:broadcastButThis(user,AEvent.USER_LIST .._EN_.. msg);

		-- 1.格式化消息
		msg = team:toString();
		-- 2.更新显示
		team:updateDisplay(msg,1);
		-- 3.派发事件
		zone:dispatchEvent(TreeEvent.ZONE_UPDATE,AEvent.TEAM_LIST .._EN_.. msg);
	end,

	-- 退出队伍
	[AEvent.EXIT_TEAM .. USER.POS.TEAM] = function(user,dataEx)

		local zone = user.tree;
		local team = user.parentNode;

		-- 1.更新属性
		user.state = NODE.STATE.RELEASE;
		-- 2.格式化消息
		local msg = user:toString();
		-- 3.更新显示
		user:updateDisplay(nil,1);
		-- 4.删除节点
		team:removeChild(user);
		-- 5.广播事件
		team:broadcast(AEvent.USER_LIST .._EN_.. msg);

		-- 是否拥有者
		if team.owner == user.index and team.numChildren ~= 0 then
			team.owner = team:firstChild().index;
			team:broadcast(AEvent.SWITCH_OWNER .._EN_.. team.owner);
		end

		-- 1.等待队伍
		if team.state == NODE.STATE.WAIT then

			-- 1.队伍为空
			if team.numChildren == 0 then
				-- 1.更新属性
				team.state = NODE.STATE.RELEASE;
				-- 2.格式化消息
				msg = team:toString();
				-- 3.更新显示(清空)
				team:updateDisplay(nil,1);
				-- 4.删除结点
				zone:removeChild(team);
				-- 5.派发合并事件
				local es = AEvent.TEAM_NUMBER .._EN_.. zone.numChildren .._CB_.. AEvent.TEAM_LIST .._EN_.. msg;
				zone:dispatchEvent(TreeEvent.ZONE_UPDATE,es);

			-- 2.队伍剩余人已全部准备好
			elseif team:isAll(NODE.STATE.READY) and team.numChildren >= team.minUserForTeam then
				-- 1.更新所有子结点
				team:setAllChildState(NODE.STATE.PLAY);
				team:setAllChildPos(USER.POS.GAME);
				-- 2.广播事件
				team:broadcast(AEvent.PLAY);

				-- 1.更新属性
				team.state = NODE.STATE.HIDDEN;
				-- 2.格式化消息
				msg = team:toString();
				-- 3.更新显示
				team:updateDisplay(nil,1);
				-- 4.分派事件
				zone:dispatchEvent(TreeEvent.ZONE_UPDATE,AEvent.TEAM_LIST .._EN_.. msg);

			-- 3.更新显示
			else
				-- 1.格式化消息
				msg = team:toString();
				-- 2.更新显示
				team:updateDisplay(msg,1);
				-- 3.派发事件
				zone:dispatchEvent(TreeEvent.ZONE_UPDATE,AEvent.TEAM_LIST .._EN_.. msg);
			end

		-- 2.游戏队伍
		elseif team.state == NODE.STATE.HIDDEN then

			-- 1.队伍为空
			if team.numChildren == 0 then
				-- 1.更新显示(清空)
				team:updateDisplay(nil,1);
				-- 2.删除结点
				zone:removeChild(team);
				-- 3.派发队伍数量事件
				zone:dispatchEvent(TreeEvent.ZONE_UPDATE,AEvent.TEAM_NUMBER .._EN_.. zone.numChildren);

			-- 2.游戏结束
			elseif team:isAllNot(NODE.STATE.PLAY) then
				-- 1.更新属性
				team.state = NODE.STATE.WAIT;
				-- 2.格式化消息
				msg = team:toString();
				-- 3.更新显示
				team:updateDisplay(msg,1);
				-- 4.分派事件
				zone:dispatchEvent(TreeEvent.ZONE_UPDATE,AEvent.TEAM_LIST .._EN_.. msg);
			end
		end

		-- 返回空间
		if user.network == NODE.NETWORK.NORMAL then
			CNetSend(user.socket,AEvent.EXIT_TEAM);
			user.pos = USER.POS.ZONE;
			user:addEventListener(TreeEvent.ZONE_UPDATE);
		end
	end,

	-- 用户列表
	[AEvent.USER_LIST .. USER.POS.TEAM] = function(user,dataEx)
		CNetSend(user.socket,AEvent.USER_LIST .._EN_.. user.parentNode.style);
	end,

	-- 拥有权转换
	[AEvent.SWITCH_OWNER .. USER.POS.TEAM] = function(user,dataEx)
		local team = user.parentNode;
		if user.index == team.owner then
			local index = tonumber(dataEx);
			if index then
				team.owner = index;
				team:broadcast(AEvent.SWITCH_OWNER .._EN_.. team.owner);
			end
		else
			CNetSend(user.socket,AEvent.DENY_SWITCH_OWNER);
		end
	end,

	-- 准备
	[AEvent.READY .. USER.POS.TEAM] = function(user,dataEx)
		local zone = user.tree;
		local team = user.parentNode;

		if user.state ~= NODE.STATE.WAIT then
			CNetSend(user.socket,AEvent.ISNOT_WAIT_STATUS);
			return;
		end

		-- 1.更新属性
		user.state = NODE.STATE.READY;
		-- 2.格式化消息
		local msg = user:toString();
		-- 3.更新显示
		user:updateDisplay(msg,1);
		-- 4.广播事件
		team:broadcast(AEvent.USER_LIST .._EN_.. msg);
		-- 5.发送消息
		CNetSend(user.socket,AEvent.READY);

		-- 队伍剩余人已全部准备好
		if team:isAll(NODE.STATE.READY) and team.numChildren >= team.minUserForTeam then
			-- 1.更新所有子结点
			team:setAllChildState(NODE.STATE.PLAY);
			team:setAllChildPos(USER.POS.GAME);
			-- 2.广播事件
			team:broadcast(AEvent.PLAY);

			-- 1.更新属性
			team.state = NODE.STATE.HIDDEN;
			-- 2.格式化消息
			msg = team:toString();
			-- 3.更新显示
			team:updateDisplay(nil,1);
			-- 4.分派事件
			zone:dispatchEvent(TreeEvent.ZONE_UPDATE,AEvent.TEAM_LIST .._EN_.. msg);
		end
	end,

	-- 取消
	[AEvent.CANCEL .. USER.POS.TEAM] = function(user,dataEx)
		local team = user.parentNode;

		if user.state ~= NODE.STATE.READY then
			CNetSend(user.socket,AEvent.ISNOT_READY_STATUS);
			return;
		end

		-- 1.更新属性
		user.state = NODE.STATE.WAIT;
		-- 2.格式化消息
		local msg = user:toString();
		-- 3.更新显示
		user:updateDisplay(msg,1);
		-- 4.广播事件
		team:broadcast(AEvent.USER_LIST .._EN_.. msg);
		-- 5.发送消息
		CNetSend(user.socket,AEvent.CANCEL);
	end,

	-- 聊天
	[AEvent.CHAT .. USER.POS.TEAM] = function(user,dataEx)
		if not dataEx or string.len(dataEx) > MAX_TEAM_CHAT_LEN then
			CNetSend(user.socket,AEvent.ERROR_CHAT_DATA);
			return;
		end
		local team = user.parentNode;
		team:broadcast(AEvent.CHAT .._EN_.. user.index .._1_.. dataEx);
	end,

	-- 指定聊天
	[AEvent.CHAT_TO .. USER.POS.TEAM] = function(user,dataEx)
		local team = user.parentNode;
		local arg = dataEx:split(_1_);
		-- 无内容
		if not arg[2] or string.len(arg[2]) > MAX_TEAM_CHAT_LEN then
			CNetSend(user.socket,AEvent.ERROR_CHAT_DATA);
			return;
		end
		-- 无对象
		local goal = team:getChildByIndex(tonumber(arg[1]));
		if not goal then
			CNetSend(user.socket,AEvent.NOTEXIST_CHAT_OBJECT .._EN_.. arg[2]);
			return;
		end
		-- 相等
		if goal == user then
			CNetSend(user.socket,AEvent.ERROR_CHAT_OBJECT);
			return;
		end
		CNetSend(user.socket,AEvent.CHAT_TO .._EN_.. user.index .._1_.. goal.index .._1_.. arg[2]);
		CNetSend(goal.socket,AEvent.CHAT_TO .._EN_.. user.index .._1_.. goal.index .._1_.. arg[2]);
	end,

	-- 踢除用户
	[AEvent.REMOVE .. USER.POS.TEAM] = function(user,dataEx)
		local team = user.parentNode;
		local index = tonumber(dataEx);
		if not index or index == user.index then
			CNetSend(user.socket,AEvent.DENY_REMOVE);
			return;
		end
		if user.index ~= team.owner then
			CNetSend(user.socket,AEvent.DENY_REMOVE);
			return;
		end
		local goal = team:getChildByIndex(index);
		if not goal then
			CNetSend(user.socket,AEvent.DENY_REMOVE);
			return;
		end
		_G[goal.status][AEvent.EXIT_TEAM .. USER.POS.TEAM](goal,nil);

	end,

	-- 广播
	[AEvent.BROADCAST .. USER.POS.GAME] = function(user,dataEx)
		if not dataEx then
			CNetSend(user.socket,AEvent.ERROR_BROADCAST_DATA);
			return;
		end
		local team = user.parentNode;
		team:broadcastByState(AEvent.BROADCAST .._EN_.. (CGetTime() - team.time) .._1_.. user.index .._1_.. dataEx,NODE.STATE.PLAY);
	end,

	-- 广播(除了发送人)
	[AEvent.BROADCAST_BUT_THIS .. USER.POS.GAME] = function(user,dataEx)
		if not dataEx then
			CNetSend(user.socket,AEvent.ERROR_BROADCAST_DATA);
			return;
		end
		local team = user.parentNode;
		team:broadcastByStateButThis(user,AEvent.BROADCAST_BUT_THIS .._EN_.. (CGetTime() - team.time) .._1_.. user.index .._1_.. dataEx,NODE.STATE.PLAY);
	end,

	-- 指定发送
	[AEvent.SEND_TO .. USER.POS.GAME] = function(user,dataEx)
		local team = user.parentNode;
		local arg = dataEx:split(_1_);
		-- 无内容
		if not arg[2] then
			CNetSend(user.socket,AEvent.ERROR_SENDTO_DATA);
			return;
		end
		local range = arg[1]:split(_2_);
		local err = {};
		for i=1,#range do
			local goal = team:getChildByIndex(tonumber(range[i]));
			if (not goal) or (goal.state ~= NODE.STATE.PLAY) then
				table.insert(err,range[i]);
			else
				CNetSend(goal.socket,AEvent.SEND_TO .._EN_.. (CGetTime() - team.time) .._1_.. user.index .._1_.. arg[2]);
			end
		end
		-- 是否有错误
		if #err ~= 0 then
			CNetSend(user.socket,AEvent.NOTEXIST_SENDTO_OBJECT .._EN_.. table.concat(err,','));
		end
	end,

	-- 指定发送(且抄送给发送人)
	[AEvent.SEND_TO_AND_CC_THIS .. USER.POS.GAME] = function(user,dataEx)
		local team = user.parentNode;
		local arg = dataEx:split(_1_);
		-- 无内容
		if not arg[2] then
			CNetSend(user.socket,AEvent.ERROR_SENDTO_DATA);
			return;
		end
		local range = arg[1]:split(_2_);
		-- 加入发送人
		table.insert(range,tostring(user.index));
		local err = {};
		for i=1,#range do
			local goal = team:getChildByIndex(tonumber(range[i]));
			if (not goal) or (goal.state ~= NODE.STATE.PLAY) then
				table.insert(err,range[i]);
			else
				CNetSend(goal.socket,AEvent.SEND_TO_AND_CC_THIS .._EN_.. (CGetTime() - team.time) .._1_.. user.index .._1_.. arg[2]);
			end
		end
		-- 是否有错误
		if #err ~= 0 then
			CNetSend(user.socket,AEvent.NOTEXIST_SENDTO_OBJECT .._EN_.. table.concat(err,','));
		end
	end,

	-- 退出游戏
	[AEvent.EXIT_GAME .. USER.POS.GAME] = function(user,dataEx)
		local zone = user.tree;
		local team = user.parentNode;

		if user.state ~= NODE.STATE.PLAY then
			CNetSend(user.socket,AEvent.ISNOT_PLAY_STATUS);
			return;
		end

		-- 1.更新属性
		user.state = NODE.STATE.WAIT;
		user.pos = USER.POS.TEAM;
		-- 2.格式化消息
		local msg = user:toString();
		-- 3.更新显示
		user:updateDisplay(msg,1);
		-- 4.发送事件
		CNetSend(user.socket,AEvent.EXIT_GAME);
		-- 5.广播事件
		team:broadcastButThis(user,AEvent.USER_LIST .._EN_.. msg);

		if team:isAllNot(NODE.STATE.PLAY) then
			-- 1.更新属性
			team.state = NODE.STATE.WAIT;
			-- 2.格式化消息
			msg = team:toString();
			-- 3.更新显示
			team:updateDisplay(msg,1);
			-- 4.分派事件
			zone:dispatchEvent(TreeEvent.ZONE_UPDATE,AEvent.TEAM_LIST .._EN_.. msg);
		end
	end,

	-- 同步服务器时间
	[AEvent.SYNC_SERVER_TIME .. USER.POS.GAME] = function(user,dataEx)
		local team = user.parentNode;
		CNetSend(user.socket,AEvent.SYNC_SERVER_TIME .._EN_.. (CGetTime() - team.time));
	end,
}
