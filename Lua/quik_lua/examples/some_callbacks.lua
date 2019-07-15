--[[
*******************************************************************
Пример работы с функциями обратного вызова и анализа битовых
флагов на заявке. Скрипт работает до тех пор, пока он не будет
остановлен из диалога управления скриптами.
Для исполнения также требуется наличие скрипта tpf.lua
и файла bit.dll (поставляется комплекте пакета Lua for Windows).
*******************************************************************
]]

dofile("tpf.lua")
local bit = require"bit"

f=nil
stopped = false


--функция возвращает true, если бит [index] установлен в 1
function bit_set( flags, index )
        local n=1
        n=bit.lshift(1, index)
        if bit.band(flags, n) ~=0 then
                return true
        else
                return false
        end
end

function orderflags2table(flags)

	local t={}
	if bit_set(flags, 0) then
		t["active"]=1
	else
		t["active"] = 0
	end
	if bit_set(flags, 2) then
		t["sell"]=1
	else
		t["buy"] = 1
	end

	if bit_set(flags, 3) then
		t["limit"]=1
	else
		t.market = 1
	end
	table_save("flags", f, t)
	return t
end

-- функция возвращает путь из полного пути с именем файла.
-- например C:\temp\1\1.txt ->C:\temp\1

function dirname(file_name)
	local dir = file_name:match"^(.*)[/\\][^/\\]*$"
	return dir or "."
end

-- функция записывает в лог строчку с временем и датой
function myLog(str)
	if f~=nil then
		f:write(os.date() .. " ".. str .. "\n")
	end
end

--колбек вызывается при получении нового стакана
function OnQoute(class, sec )

	if class =="SPBFUT" and sec == "RIZ2" then

		ql2 = getQuoteLevel2(class, sec)
	end
end

-- вызывается терминалом при изменении параметра ТТП по классу-бумаге
function OnParam( class, sec  )
	if class =="SPBFUT" and sec == "RIZ2" then
		tbid = getParamEx(class, sec, "bid")
		if tbid.param_value >=130000 then
			message("price >= 130000", 3)
		end
	end
end

-- функция инициализации. Вызывается терминалом перед запуском скрипта
function OnInit(path)
	message("in init", 1)
	f = io.open("all_entity.txt", "w+t")
	myLog("script path is " .. dirname(path))
	myLog("in OnInit. script path = " .. path)
	local td = GetTradeDate()
	table_save("trade date", f, td)
	cl_list = getClassesList()
	optevn_class = getClassInfo("SPBFUT")
	table_save("class_info", f, optevn_class)
	myLog(cl_list)
	sec_list = getClassSecurities("SPBFUT")
	money = getMoney("Q9/1", "NC0038900000", "EQTV", "SUR")
	table_save("money", f, money)

	depo = getDepo("Q9/1", "NC0038900000", "SBER", "L01-00000F00")
	table_save("depo", f, depo)

	ql2 = getQuoteLevel2("SPBFUT", "RIZ2")
	table_save("ql2", f, ql2)



	myLog("secs in SPBFUT " .. sec_list)
	myLog("initialization finished")
end

--колбек на получение новой обезличенной сделки. Записывает структуру
-- со сделкой в файл
function OnAllTrade( trade )
 	if not stopped then
 		table_save("all trade from callback", f, trade)
 		f:flush()
 	end
end

--колбек на изменение заявки. Записывает структуру
-- с заявкой в файл

function OnOrder( order )

 	if not stopped then
 		order.flag_table = orderflags2table(order.flags)
 		table_save("order from callback", f, order)
 		f:flush()
 	end
end

-- вызывается при нажатии кнопки "остановить" в диалоге
function OnStop(signal)
	stopped = true
end

-- крутится в отдельном потоке, ничего не делает. после нажатия кнопки остановить 
-- закрывает файл
function main(  )
	while not stopped do
		sleep(100)
	end
	f:close()
end
