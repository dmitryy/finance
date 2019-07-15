--[[
*******************************************************************
������ ������ � ������������ � �������. ������ ��������� ��������
� ���������� count ���������� ������, ���������� �� ���������
� ������� ������, ����� ������� �� �������, ������� ���� ��������
� ������� OnTransReply().
��� ���������� ����� ��������� ������� ������� tpf.lua
*******************************************************************
]]


dofile("tpf.lua")

trans_result = {}
orders = {}
orders_to_kill={}
i=0

-- ���������� ���������� ��� ��������� ������ �� ����� ���������� �� �������
function OnTransReply( tr )
	tr.local_time = os.clock()
	trans_result[i] = tr
	orders_to_kill[tr.ordernum] = 1
	i=i+1
end

j=0

-- ��� �� �������� ����� ������
function OnOrder(order)
	order.local_time = os.clock()
	if not orders[order.ordernum] then
		orders[order.ordernum] = order
		j= j +1
	end
end

function main()
	--�������-��������� ��� ����������, ��������� ���� ����� 
	-- ���������� � ������������ � �����
	-- ����� ����� �������������������. 
	transaction={
					["CLASSCODE"]="EQBR",
					["ACTION"]="NEW_ORDER",
					["ACCOUNT"]="L01-00000F00",
					["OPERATION"] = "S",
					["SECCODE"] = "LKOH",
					["PRICE"] = tostring(2005.00),
					["QUANTITY"] = tostring(1)

				}
	start_time = os.clock()
	count = 2
	for x=1,count do
		-- �����!!! ��� �������� ����� � ���������� ������ ���� ����������
		-- ���� ������ ���� ������������ ������� � ��������� �������� �
		-- ��������� �����������
		transaction.TRANS_ID = tostring(x)
		transaction.COMMENT = "LUA ".. tostring(x)
		transaction.price= tostring(math.random(2000, 3000))
		res = sendTransaction(transaction)
		--message(res, 3)
	end
	end_time = os.clock()
	while i~=count and j ~= count do
		sleep(100)
	end
	file = io.open("out.txt", "w+t")
	table_save("transactions", file, trans_result)
	table_save("orders", file, orders)
	table_save("orders_to_kill", file, orders_to_kill)

	file:write("---killing orders\n")
	kill_order_trans = {
						["CLASSCODE"]="EQBR",
						["SECCODE"] = "LKOH",
						["ACTION"] = "KILL_ORDER"}
	file:write("orders to kill ".. #orders_to_kill .. "\n")
	for k,v in pairs(orders_to_kill) do
		kill_order_trans.TRANS_ID = tostring(k)
		kill_order_trans.order_key = tostring(k)
		sendTransaction(kill_order_trans)
	end
	file:close()

end
