-- Կ�׹�����
KEYER = {
	-- ����Կ�׶�
	make = function()
		local s = KEYER.encrypt();
		return s,KEYER.decrypt(s);
	end,

	-- ����
	encrypt = function()
		local nCyp = 0;

		math.randomseed(os.time())
		for i=1,8 do
			nCyp = nCyp * 10 + math.random(1,9);
		end

		return tostring(nCyp);
	end,

	-- ����
	decrypt = function(cyp)
		local nMsg = tonumber(cyp);
		return tostring(nMsg + 12 * 3 - 4 * 5);
	end
}
