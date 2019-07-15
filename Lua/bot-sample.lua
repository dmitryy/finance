-- (c) https://quikluacsharp.ru/
-- Вводим свои параметры
Account    = "*******"    -- Торговый счет
Class_Fut  = "SPBFUT"     -- Класс фьючерса
Sec_Fut    = "SiU6"       -- Код фьючерса
Class_Opt  = "SPBOPT"     -- Класс опциона
 
Short_Call = "Si75000BG6" -- Код опциона Short_Call
Long_Call  = "Si74000BG6" -- Код опциона Long_Call
Long_Put   = "Si63000BS6" -- Код опциона Long_Put
Short_Put  = "Si62000BS6" -- Код опциона Short_Put
 
Num_Lots   = 3            -- Кол-во лот, объем = 1
Step_Fut   = 250          -- Профит опциона на Step_Fut
Year       = 366          -- Число дней в году
Commission = 5            -- Комиссия (биржа + брокер на "круг" по 1-му лоту)
 
-- Здесь не меняем
SC_Open    = 0  -- Открыть
SC_Num     = 0  -- Текущий номер заявки
SC_Lin     = 0  -- Исходный номер заявки
SC_Volume  = 0  -- Общий объем
SC_Price   = {} -- Цена сделки
SC_Close   = 0  -- Закрыть
SC_Num_Cl  = {} -- Текущий номер заявки
SC_Lin_Cl  = {} -- Исходный номер заявки
 
LC_Open    = 0  -- Открыть
LC_Num     = 0  -- Текущий номер заявки
LC_Lin     = 0  -- Исходный номер заявки
LC_Volume  = 0  -- Общий объем
LC_Price   = {} -- Цена сделки
 
LP_Open    = 0  -- Открыть
LP_Num     = 0  -- Текущий номер заявки
LP_Lin     = 0  -- Исходный номер заявки
LP_Volume  = 0  -- Общий объем
LP_Price   = {} -- Цена сделки
 
SP_Open    = 0  -- Открыть
SP_Num     = 0  -- Текущий номер заявки
SP_Lin     = 0  -- Исходный номер заявки
SP_Volume  = 0  -- Общий объем
SP_Price   = {} -- Цена сделки
SP_Close   = 0  -- Закрыть
SP_Num_Cl  = {} -- Текущий номер заявки
SP_Lin_Cl  = {} -- Исходный номер заявки
 
History    = 0  -- Заработанный профит
 
trans_id   = os.time() -- Текущие дата и время в секундах хорошо подходят для уникальных номеров транзакций
IsRun      = true -- Флаг поддержания работы скрипта
 
function OnInit() -- Функция вызывается терминалом QUIK перед вызовом функции main()
   local f = io.open(getScriptPath().."//Spread_1.txt","r+") -- Пытается открыть файл состояния в режиме "чтения/записи"
   if f ~= nil then -- Если файл существует, перебирает строки файла, считывает содержимое в соответствующие переменные
      local Count = 0 -- Счетчик строк
      for line in f:lines() do
         Count = Count + 1
         if     Count == 1                                          then Arr = Lines(line); SC_Open = Arr.e1; SC_Num = Arr.e2; SC_Lin = Arr.e3; SC_Volume = Arr.e4; SC_Close = Arr.e5
         elseif Count >  1              and Count <= 1 +   Num_Lots then Arr = Lines(line); SC_Price[Count - 1] = Arr.e1; SC_Num_Cl[Count - 1] = Arr.e2; SC_Lin_Cl[Count - 1] = Arr.e3
         elseif Count == 2 +   Num_Lots                             then Arr = Lines(line); LC_Open = Arr.e1; LC_Num = Arr.e2; LC_Lin = Arr.e3; LC_Volume = Arr.e4
         elseif Count >  2 +   Num_Lots and Count <= 2 + 2*Num_Lots then Arr = Lines(line); LC_Price[Count - 2 - Num_Lots] = Arr.e1
         elseif Count == 3 + 2*Num_Lots                             then Arr = Lines(line); LP_Open = Arr.e1; LP_Num = Arr.e2; LP_Lin = Arr.e3; LP_Volume = Arr.e4
         elseif Count >  3 + 2*Num_Lots and Count <= 3 + 3*Num_Lots then Arr = Lines(line); LP_Price[Count - 3 - 2*Num_Lots] = Arr.e1
         elseif Count == 4 + 3*Num_Lots                             then Arr = Lines(line); SP_Open = Arr.e1; SP_Num = Arr.e2; SP_Lin = Arr.e3; SP_Volume = Arr.e4; SP_Close = Arr.e5
         elseif Count >  4 + 3*Num_Lots and Count <= 4 + 4*Num_Lots then Arr = Lines(line); SP_Price[Count - 4 - 3*Num_Lots] = Arr.e1; SP_Num_Cl[Count - 4 - 3*Num_Lots] = Arr.e2; SP_Lin_Cl[Count - 4 - 3*Num_Lots] = Arr.e3
         elseif Count == 5 + 4*Num_Lots                             then History = tonumber(line)
         end
      end
      f:close() -- Закрывает файл
   else
      for i = 1, Num_Lots, 1 do
         SC_Price[i] = 0; SC_Num_Cl[i] = 0; SC_Lin_Cl[i] = 0; LC_Price[i] = 0; LP_Price[i] = 0; SP_Price[i] = 0; SP_Num_Cl[i] = 0; SP_Lin_Cl[i] = 0
      end
   end
   -- Создает таблицу
   t_id = AllocTable() -- Получает доступный id для создания
   -- Добавляет колонки
   AddColumn(t_id, 0, "Опцион", true, QTABLE_STRING_TYPE, 15)
   AddColumn(t_id, 1, "Теоретическая", true, QTABLE_INT_TYPE, 7)
   AddColumn(t_id, 2, "Объем", true, QTABLE_INT_TYPE, 4)
   AddColumn(t_id, 3, "Цена", true, QTABLE_INT_TYPE, 7)
   AddColumn(t_id, 4, "Профит", true, QTABLE_INT_TYPE, 9)
   AddColumn(t_id, 5, "Profit", true, QTABLE_INT_TYPE, 7)
   AddColumn(t_id, 6, "P/L", true, QTABLE_INT_TYPE, 10)
   t = CreateWindow(t_id) -- Создает таблицу
   SetWindowCaption(t_id, "Spread_1") -- Устанавливает заголовок
   SetWindowPos(t_id, 000, 501, 349, 128) -- Задает положение и размеры окна таблицы
   for i = 1, 5, 1 do InsertRow(t_id, i) end -- Добавляет строки
   -- Добавляет значения в ячейки
   SetCell(t_id, 1, 0, Short_Call); SetCell(t_id, 2, 0, Long_Call); SetCell(t_id, 3, 0, Long_Put); SetCell(t_id, 4, 0, Short_Put)
   SetCell(t_id, 5, 2, tostring(Num_Lots)); Gray(5, 2) -- Кол-во лот
   SetCell(t_id, 5, 5, tostring(Step_Fut)); Gray(5, 5) -- Профит опциона на Step_Fut
end
 
function main() -- Функция, реализующая основной поток выполнения в скрипте
   while IsRun do -- Цикл будет выполнятся, пока IsRun == true
      SC = Options(Short_Call); LC = Options(Long_Call); LP = Options(Long_Put); SP = Options(Short_Put) -- Считаем параметры
      SC_Pr = 0; LC_Pr = 0; LP_Pr = 0; SP_Pr = 0 -- Средняя цена позиции
      for i = 1, Num_Lots, 1 do SC_Pr = SC_Pr + SC_Price[i]; LC_Pr = LC_Pr + LC_Price[i]; LP_Pr = LP_Pr + LP_Price[i]; SP_Pr = SP_Pr + SP_Price[i] end
      if SC_Volume > 0 then SC_Pr = round(SC_Pr / SC_Volume, 2) end; if LC_Volume > 0 then LC_Pr = round(LC_Pr / LC_Volume, 2) end; if LP_Volume > 0 then LP_Pr = round(LP_Pr / LP_Volume, 2) end; if SP_Volume > 0 then SP_Pr = round(SP_Pr / SP_Volume, 2) end
 
      SetCell(t_id, 1, 1, tostring(SC.Exchang)); SC_Profit = SC_Volume * (SC_Pr - SC.Exchang); Position(1, -SC_Volume, SC_Pr, SC_Profit); if SC_Open == -1 then Gray(1, 0) end
      SetCell(t_id, 2, 1, tostring(LC.Exchang)); LC_Profit = LC_Volume * (LC.Exchang - LC_Pr); Position(2,  LC_Volume, LC_Pr, LC_Profit); if LC_Open == -1 then Gray(2, 0) end
      SetCell(t_id, 3, 1, tostring(LP.Exchang)); LP_Profit = LP_Volume * (LP.Exchang - LP_Pr); Position(3,  LP_Volume, LP_Pr, LP_Profit); if LP_Open == -1 then Gray(3, 0) end
      SetCell(t_id, 4, 1, tostring(SP.Exchang)); SP_Profit = SP_Volume * (SP_Pr - SP.Exchang); Position(4, -SP_Volume, SP_Pr, SP_Profit); if SP_Open == -1 then Gray(4, 0) end
      SetCell(t_id, 5, 3, tostring(History)); Str(5, 4, SC_Profit + LC_Profit + LP_Profit + SP_Profit)
      SetCell(t_id, 5, 0, tostring(tonumber(getParamEx(Class_Opt, Long_Call, "days_to_mat_date").param_value)).." / "..os.date("%X")) -- Число дней до погашения, время компьютера
      Str(5, 1, - SC_Volume * SC.Theta_C + LC_Volume * LC.Theta_C + LP_Volume * LP.Theta_P - SP_Volume * SP.Theta_P) -- Тетта
      SetCell(t_id, 1, 5, tostring(SC.Profit_C)); SetCell(t_id, 2, 5, tostring(LC.Profit_C)); SetCell(t_id, 3, 5, tostring(LP.Profit_P)); SetCell(t_id, 4, 5, tostring(SP.Profit_P)) -- Профит опциона на Step_Fut
 
      Le_C = SC_Volume * SC_Pr - LC_Volume * LC_Pr; Str(2, 6, Le_C) -- Убыток спрэда Call
      Le_P = SP_Volume * SP_Pr - LP_Volume * LP_Pr; Str(4, 6, Le_P) -- Убыток спрэда Put
      Le_CP = Le_C + Le_P; Str(3, 6, Le_CP) -- Убыток спрэда Call + Put
      Step_Strike = tonumber(string.sub(Short_Call, 3, #Short_Call - 3)) - tonumber(string.sub(Long_Call, 3, #Long_Call - 3))
      if SC_Volume > 0 and SC_Volume == LC_Volume then Pr_C = (SC_Volume + LC_Volume) / 2 * Step_Strike + Le_CP; Str(1, 6, Pr_C) -- Профит спрэда Call
      elseif SC_Volume < LC_Volume then SetCell(t_id, 1, 6, "~"); Green(1, 6)
      else SetCell(t_id, 1, 6, ""); White(1, 6) end
      Step_Strike = tonumber(string.sub(Long_Put, 3, #Long_Put - 3)) - tonumber(string.sub(Short_Put, 3, #Short_Put - 3))
      if SP_Volume > 0 and SP_Volume == LP_Volume then Pr_P = (SP_Volume + LP_Volume) / 2 * Step_Strike + Le_CP; Str(5, 6, Pr_P) -- Профит спрэда Put
      elseif SP_Volume < LP_Volume then SetCell(t_id, 5, 6, "~"); Green(5, 6)
      else SetCell(t_id, 5, 6, ""); White(5, 6) end
 
      if tonumber(getParamEx(Class_Fut, Sec_Fut, "status").param_value) == 1 then -- Торговля разрешена или нет
         Green(5, 0)
         ---------------------------------------------------------------------------------
         -- Открыть Long_Call
         if LC_Open == 0 and LC_Num == 0 then -- Заявки Long_Call нет
            iLC_Pr = 0; for i = Num_Lots, 1, -1 do if LC_Price[i] == 0 then iLC_Pr = i end; end
            if iLC_Pr == 1 or (iLC_Pr > 1 and LC.Exchang < LC_Price[iLC_Pr - 1] - LC.Profit_C - Commission) then
               Transaction("Покупка", Long_Call, LC.Exchang)
            end
         end
         -- Снять Long_Call
         if LC_Open > 0 and LC_Num > 0 then -- Заявка Long_Call есть
            if LC.Exchang ~= LC_Open then
               Kill(Long_Call, LC_Num)
            end
         end
         ---------------------------------
         -- Открыть, снять Short_Call
         for i = 1, Num_Lots, 1 do
            if SC_Price[i] == 0 and LC_Price[i] > 0 then -- Сделки Short_Call нет
               if SC.Exchang > LC_Price[i] + Commission or (LC.Exchang > LC_Price[i] + LC.Profit_C + Commission and SC.Exchang > SC.Profit_C + Commission) then
                  if SC_Open == 0 and SC_Num == 0 then -- Заявки Short_Call нет
                     Transaction("Продажа", Short_Call, SC.Exchang) -- Открыть Short_Call
                  end
                  if SC_Open > 0 and SC_Num > 0 then -- Заявка Short_Call есть
                     if SC.Exchang ~= SC_Open then
                        Kill(Short_Call, SC_Num) -- Снять Short_Call
                     end
                  end
               end
            end
         end
         -- Закрыть Short_Call
         for i = 1, Num_Lots, 1 do
            if SC_Price[i] > 0 and SC_Price[i] - LC_Price[i] < 0 then -- Сделка Short_Call есть и убыток спрэда Call < 0
               if SC_Close == 0 and SC_Num_Cl[i] == 0 then -- Заявки Short_Call нет
                  Transaction("Покупка", Short_Call, SC_Price[i] - SC.Profit_C)
               end
            end
         end
         ---------------------------------------------------------------------------------
         -- Открыть Long_Put
         if LP_Open == 0 and LP_Num == 0 then -- Заявки Long_Put нет
            iLP_Pr = 0; for i = Num_Lots, 1, -1 do if LP_Price[i] == 0 then iLP_Pr = i end; end
            if iLP_Pr == 1 or (iLP_Pr > 1 and LP.Exchang < LP_Price[iLP_Pr - 1] - LP.Profit_P - Commission) then
               Transaction("Покупка", Long_Put, LP.Exchang)
            end
         end
         -- Снять Long_Put
         if LP_Open > 0 and LP_Num > 0 then -- Заявка Long_Put есть
            if LP.Exchang ~= LP_Open then
               Kill(Long_Put, LP_Num)
            end
         end
         --------------------------------
         -- Открыть, снять Short_Put
         for i = 1, Num_Lots, 1 do
            if SP_Price[i] == 0 and LP_Price[i] > 0 then -- Сделки Short_Put нет
               if SP.Exchang > LP_Price[i] + Commission or (LP.Exchang > LP_Price[i] + LP.Profit_P + Commission and SP.Exchang > SP.Profit_P + Commission) then
                  if SP_Open == 0 and SP_Num == 0 then -- Заявки Short_Put нет
                     Transaction("Продажа", Short_Put, SP.Exchang) -- Открыть Short_Put
                  end
                  if SP_Open > 0 and SP_Num > 0 then -- Заявка Short_Put есть
                     if SP.Exchang ~= SP_Open then
                        Kill(Short_Put, SP_Num) -- Снять Short_Put
                     end
                  end
               end
            end
         end
         -- Закрыть Short_Put
         for i = 1, Num_Lots, 1 do
            if SP_Price[i] > 0 and SP_Price[i] - LP_Price[i] < 0 then -- Сделка Short_Put есть и убыток спрэда Put < 0
               if SP_Close == 0 and SP_Num_Cl[i] == 0 then -- Заявки Short_Put нет
                  Transaction("Покупка", Short_Put, SP_Price[i] - SP.Profit_P)
               end
            end
         end
         ---------------------------------------------------------------------------------
      else
         Red(5, 0)
      end
      sleep(100)
   end
end
 
function OnStop() -- Функция вызывается терминалом QUIK при остановке скрипта из диалога управления
   SaveCurrentState()
   IsRun = false
end
 
function SaveCurrentState() -- Функция сохраняет текущее состояние в файл
   local f = io.open(getScriptPath().."//Spread_1.txt","w") -- Создает файл в режиме "записи"
   -- Записывает в файл текущее состояние
   f:write(SC_Open..";"..SC_Num..";"..SC_Lin..";"..SC_Volume..";"..SC_Close.."\n")
   for i = 1, Num_Lots, 1 do f:write(SC_Price[i]..";"..SC_Num_Cl[i]..";"..SC_Lin_Cl[i].."\n") end
   f:write(LC_Open..";"..LC_Num..";"..LC_Lin..";"..LC_Volume.."\n")
   for i = 1, Num_Lots, 1 do f:write(LC_Price[i].."\n") end
   f:write(LP_Open..";"..LP_Num..";"..LP_Lin..";"..LP_Volume.."\n")
   for i = 1, Num_Lots, 1 do f:write(LP_Price[i].."\n") end
   f:write(SP_Open..";"..SP_Num..";"..SP_Lin..";"..SP_Volume..";"..SP_Close.."\n")
   for i = 1, Num_Lots, 1 do f:write(SP_Price[i]..";"..SP_Num_Cl[i]..";"..SP_Lin_Cl[i].."\n") end
   f:write(History.."\n")
   f:flush() -- Сохраняет изменения в файле
   f:close() -- Закрывает файл
end
function Lines(line) -- Функция читает строку в файле состояния
   local i = 0 -- Счетчик элементов строки
   for str in line:gmatch("[^;^\n]+") do
      i = i + 1
      if     i == 1 then e1 = tonumber(str)
      elseif i == 2 then e2 = tonumber(str)
      elseif i == 3 then e3 = tonumber(str)
      elseif i == 4 then e4 = tonumber(str)
      elseif i == 5 then e5 = tonumber(str)
      end
   end
   return {["e1"] = e1,
           ["e2"] = e2,
           ["e3"] = e3,
           ["e4"] = e4,
           ["e5"] = e5}
end
 
function Str(line, column, profit) -- Функция выводит и окрашивает переданный профит в таблицу
   SetCell(t_id, line, column, tostring(profit)) -- Выводит значение в таблицу
   if profit == 0 then White(line, column) elseif profit > 0 then Green(line, column) else Red(line, column) end -- Окрашивает ячейку в зависимости от значения профита
end
function Position(line, volume, price, profit) -- Функция выводит и окрашивает переданный volume, price, profit
   if volume ~= 0 then
      SetCell(t_id, line, 2, tostring(volume)); SetCell(t_id, line, 3, tostring(price)); SetCell(t_id, line, 4, tostring(profit))
      if profit == 0 then White(line, 0); White(line, 1); White(line, 2); White(line, 3); White(line, 4)
      elseif profit > 0 then Green(line, 0); Green(line, 1); Green(line, 2); Green(line, 3); Green(line, 4)
      else Red(line, 0); Red(line, 1); Red(line, 2); Red(line, 3); Red(line, 4) end
   else White(line, 0); White(line, 1); SetCell(t_id, line, 2, ""); White(line, 2); SetCell(t_id, line, 3, ""); White(line, 3); SetCell(t_id, line, 4, ""); White(line, 4) end
end
 
-- Функции по раскраске ячеек таблицы
function White(line, column) -- Белый
   SetColor(t_id, line, column, RGB(255,255,255), RGB(0,0,0), RGB(255,255,255), RGB(0,0,0))
end
function Green(line, column) -- Зеленый
   SetColor(t_id, line, column, RGB(165,227,128), RGB(0,0,0), RGB(165,227,128), RGB(0,0,0))
end
function Red(line, column) -- Красный
   SetColor(t_id, line, column, RGB(255,168,164), RGB(0,0,0), RGB(255,168,164), RGB(0,0,0))
end
function Gray(line, column) -- Серый
   SetColor(t_id, line, column, RGB(208,208,208), RGB(0,0,0), RGB(208,208,208), RGB(0,0,0))
end
 
function Options(sec) -- Функция считает параметры опциона
   local P = tonumber(getParamEx(Class_Fut, Sec_Fut, "settleprice").param_value) -- Текущая цена фьючерса
   local S = tonumber(string.sub(sec, 3, #sec - 3)) -- Страйк опциона
   local V = tonumber(getParamEx(Class_Opt, sec, "volatility").param_value) / 100 -- Волатильность опциона в долях
   local D = tonumber(getParamEx(Class_Opt, sec, "days_to_mat_date").param_value) / Year -- Число дней до погашения в долях года
   local d1 = (math.log(P / S) + V * V * D / 2) / (V * math.sqrt(D))
   local d2 = d1 - V * math.sqrt(D)
   local Exchang = tonumber(getParamEx(Class_Opt, sec, "theorprice").param_value) -- Теоретическая цена биржи
   local Theta = (-P * V * math.exp(-D) * pN(d1)) / (2 * math.sqrt(D))
   local Theta_C = round((Theta - (S * math.exp(-D) * N(d2)) + P * math.exp(-D) * N(d1)) / Year, 0) -- Тетта Call
   local Theta_P = round((Theta + (S * math.exp(-D) * N(-d2)) - P * math.exp(-D) * N(-d1)) / Year, 0) -- Тетта Put
   local Delta_C = round(math.exp(-D) * N(d1), 2) -- Дельта Call
   local Profit_C = round(Step_Fut * Delta_C, 0) -- Профит для Call
   local Delta_P = -round(-math.exp(-D) * N(-d1), 2) -- Дельта Put
   local Profit_P = round(Step_Fut * Delta_P, 0) -- Профит для Put
   return {["Exchang"] = Exchang,
           ["Theta_C"] = Theta_C,
           ["Theta_P"] = Theta_P,
           ["Profit_C"] = Profit_C,
           ["Profit_P"] = Profit_P}
end
function N(x) -- Функция нормального среднего
   if x > 10 then return 1
   elseif x < -10 then return 0
   else
      local t = 1 / (1 + 0.2316419 * math.abs(x))
      local p = 0.3989423 * math.exp(-0.5 * x * x) * t * ((((1.330274 * t - 1.821256) * t + 1.781478) * t - 0.3565638) * t + 0.3193815)
      if x > 0 then p = 1 - p end
      return p
   end
end
function pN(x) -- Функция, производная от нормального среднего
   return math.exp(-0.5 * x * x) / math.sqrt(2 * math.pi)
end
function round(num, idp) -- Функция округляет до указанного количества знаков
   local mult = 10^idp
   return math.floor(num * mult + 0.5) / mult
end
 
function Transaction(bs, sec, open) -- Функция отправляет транзакцию
   trans_id = trans_id + 1 -- Получает ID для транзакции
   if sec == Short_Call then if bs == "Продажа" then SC_Open = trans_id else SC_Close = trans_id end; end -- Short_Call
   if sec == Long_Call  then LC_Open = trans_id end -- Long_Call
   if sec == Long_Put   then LP_Open = trans_id end -- Long_Put
   if sec == Short_Put  then if bs == "Продажа" then SP_Open = trans_id else SP_Close = trans_id end; end -- Short_Put
   local Transaction           = { -- Заполняет структуру для отправки транзакции
      ["TRANS_ID"]             = tostring(trans_id);
      ["CLASSCODE"]            = Class_Opt;
      ["ACTION"]               = "Ввод заявки";
      ["Торговый счет"]        = Account;
      ["К/П"]                  = bs;
      ["Тип"]                  = "Лимитированная";
      ["Класс"]                = Class_Opt;
      ["Инструмент"]           = sec;
      ["Цена"]                 = tostring(open);
      ["Количество"]           = "1";
      ["Условие исполнения"]   = "Поставить в очередь";
      ["Комментарий"]          = "";
      ["Проверять лимит цены"] = "Да";
      ["Переносить заявку"]    = "Да";
      ["Дата экспирации"]      = tostring(tonumber(getParamEx(Class_Opt, sec, "mat_date").param_value));}
   local res = sendTransaction(Transaction) -- Отправляет транзакцию
   if res ~= "" then message("Ошибка отправки транзакции: "..res) end
end
 
function Kill(sec, num) -- Функция снимает заявку по номеру
   trans_id = trans_id + 1 -- Получает ID для транзакции
   if sec == Short_Call then SC_Open = 0 end -- Short_Call
   if sec == Long_Call  then LC_Open = 0 end -- Long_Call
   if sec == Long_Put   then LP_Open = 0 end -- Long_Put
   if sec == Short_Put  then SP_Open = 0 end -- Short_Put
   local Transaction = { -- Заполняет структуру для отправки транзакции
      ["TRANS_ID"]   = tostring(trans_id);
      ["CLASSCODE"]  = Class_Opt;
      ["SECCODE"]    = sec;
      ["ACTION"]     = "KILL_ORDER";
      ["ORDER_KEY"]  = tostring(num);}
   local res = sendTransaction(Transaction) -- Отправляет транзакцию
end
 
function OnTransReply(trans_reply) -- Функция вызывается терминалом, когда с сервера приходит новая информация о транзакциях
   -- Выставляем заявку Long_Call
   if LC_Open > 0 and LC_Num == 0 and LC_Open == trans_reply.trans_id then -- Если пришла информация по нашей транзакции Long_Call
      if trans_reply.status == 3 then -- Транзакция Long_Call выполнена
         LC_Open = trans_reply.price
         LC_Num = trans_reply.order_num
         LC_Lin = trans_reply.order_num
      elseif trans_reply.status == 4 then -- Нет денег
         LC_Open = -1
      elseif trans_reply.status > 4 then -- Произошла ошибка
         LC_Open = 0
      end
   end
   -- Снимаем заявку Long_Call
   if LC_Open == 0 and LC_Num > 0 and LC_Num == trans_reply.order_num then -- Если пришла информация по нашей транзакции Long_Call
      if trans_reply.status == 3 then -- Транзакция Long_Call выполнена
         LC_Num = 0
         LC_Lin = 0
      elseif trans_reply.status > 3 then -- Произошла ошибка
         LC_Open = trans_reply.price
      end
   end
   -- Выставляем заявку Short_Call
   if SC_Open > 0 and SC_Num == 0 and SC_Open == trans_reply.trans_id then -- Если пришла информация по нашей транзакции Short_Call
      if trans_reply.status == 3 then -- Транзакция Short_Call выполнена
         SC_Open = trans_reply.price
         SC_Num = trans_reply.order_num
         SC_Lin = trans_reply.order_num
      elseif trans_reply.status == 4 then -- Нет денег
         SC_Open = -1
      elseif trans_reply.status > 4 then -- Произошла ошибка
         SC_Open = 0
      end
   end
   -- Снимаем заявку Short_Call
   if SC_Open == 0 and SC_Num > 0 and SC_Num == trans_reply.order_num then -- Если пришла информация по нашей транзакции Short_Call
      if trans_reply.status == 3 then -- Транзакция Short_Call выполнена
         SC_Num = 0
         SC_Lin = 0
      elseif trans_reply.status > 3 then -- Произошла ошибка
         SC_Open = trans_reply.price
      end
   end
   -- Выставляем заявку закрыть Short_Call
   if SC_Close > 0 and SC_Close == trans_reply.trans_id then -- Если пришла информация по нашей транзакции Short_Call
      if trans_reply.status == 3 then -- Транзакция Short_Call выполнена
         for i = 1, Num_Lots, 1 do
            if SC_Price[i] > 0 and SC_Num_Cl[i] == 0 then
               SC_Num_Cl[i] = trans_reply.order_num
               SC_Lin_Cl[i] = trans_reply.order_num
               SC_Close = 0
            end
         end
      elseif trans_reply.status == 4 then -- Нет денег
         SC_Close = -1
      elseif trans_reply.status > 4 then -- Произошла ошибка
         SC_Close = 0
      end
   end
   ---------------------------------------------------------------------------------
   -- Выставляем заявку Long_Put
   if LP_Open > 0 and LP_Num == 0 and LP_Open == trans_reply.trans_id then -- Если пришла информация по нашей транзакции Long_Put
      if trans_reply.status == 3 then -- Транзакция Long_Put выполнена
         LP_Open = trans_reply.price
         LP_Num = trans_reply.order_num
         LP_Lin = trans_reply.order_num
      elseif trans_reply.status == 4 then -- Нет денег
         LP_Open = -1
      elseif trans_reply.status > 4 then -- Произошла ошибка
         LP_Open = 0
      end
   end
   -- Снимаем заявку Long_Put
   if LP_Open == 0 and LP_Num > 0 and LP_Num == trans_reply.order_num then -- Если пришла информация по нашей транзакции Long_Put
      if trans_reply.status == 3 then -- Транзакция Long_Put выполнена
         LP_Num = 0
         LP_Lin = 0
      elseif trans_reply.status > 3 then -- Произошла ошибка
         LP_Open = trans_reply.price
      end
   end
   -- Выставляем заявку Short_Put
   if SP_Open > 0 and SP_Num == 0 and SP_Open == trans_reply.trans_id then -- Если пришла информация по нашей транзакции Short_Put
      if trans_reply.status == 3 then -- Транзакция Short_Put выполнена
         SP_Open = trans_reply.price
         SP_Num = trans_reply.order_num
         SP_Lin = trans_reply.order_num
      elseif trans_reply.status == 4 then -- Нет денег
         SP_Open = -1
      elseif trans_reply.status > 4 then -- Произошла ошибка
         SP_Open = 0
      end
   end
   -- Снимаем заявку Short_Put
   if SP_Open == 0 and SP_Num > 0 and SP_Num == trans_reply.order_num then -- Если пришла информация по нашей транзакции Short_Put
      if trans_reply.status == 3 then -- Транзакция Short_Put выполнена
         SP_Num = 0
         SP_Lin = 0
      elseif trans_reply.status > 3 then -- Произошла ошибка
         SP_Open = trans_reply.price
      end
   end
   -- Выставляем заявку закрыть Short_Put
   if SP_Close > 0 and SP_Close == trans_reply.trans_id then -- Если пришла информация по нашей транзакции Short_Put
      if trans_reply.status == 3 then -- Транзакция Short_Put выполнена
         for i = 1, Num_Lots, 1 do
            if SP_Price[i] > 0 and SP_Num_Cl[i] == 0 then
               SP_Num_Cl[i] = trans_reply.order_num
               SP_Lin_Cl[i] = trans_reply.order_num
               SP_Close = 0
            end
         end
      elseif trans_reply.status == 4 then -- Нет денег
         SP_Close = -1
      elseif trans_reply.status > 4 then -- Произошла ошибка
         SP_Close = 0
      end
   end
   SaveCurrentState()
end
 
function OnOrder(order) -- Функция вызывается терминалом QUIK при получении новой заявки или при изменении параметров существующей заявки
   if LC_Lin > 0 and LC_Lin == order.linkedorder then -- Новый номер Long_Call
      LC_Num = order.order_num
   end
   if SC_Lin > 0 and SC_Lin == order.linkedorder then -- Новый номер Short_Call
      SC_Num = order.order_num
   end
   for i = 1, Num_Lots, 1 do
      if SC_Lin_Cl[i] > 0 and SC_Lin_Cl[i] == order.linkedorder then -- Новый номер закрыть Short_Call
         SC_Num_Cl[i] = order.order_num
      end
   end
   ---------------------------------------------------------------------------------
   if LP_Lin > 0 and LP_Lin == order.linkedorder then -- Новый номер Long_Put
      LP_Num = order.order_num
   end
   if SP_Lin > 0 and SP_Lin == order.linkedorder then -- Новый номер Short_Put
      SP_Num = order.order_num
   end
   for i = 1, Num_Lots, 1 do
      if SP_Lin_Cl[i] > 0 and SP_Lin_Cl[i] == order.linkedorder then -- Новый номер закрыть Short_Put
         SP_Num_Cl[i] = order.order_num
      end
   end
   SaveCurrentState()
end
 
function OnTrade(trade) -- Функция вызывается терминалом QUIK при получении сделки
   if LC_Num == trade.order_num then -- Сделка Long_Call
      LC_Open = 0
      LC_Num = 0
      LC_Lin = 0
      LC_Volume = LC_Volume + trade.qty
      for i = Num_Lots, 1, -1 do if LC_Price[i] == 0 then iLC_Pr = i end; end
      LC_Price[iLC_Pr] = trade.price + Commission
   end
   if SC_Num == trade.order_num then -- Сделка Short_Call
      SC_Open = 0
      SC_Num = 0
      SC_Lin = 0
      SC_Volume = SC_Volume + trade.qty
      for i = Num_Lots, 1, -1 do if SC_Price[i] == 0 then iSC_Pr = i end; end
      SC_Price[iSC_Pr] = trade.price - Commission
   end
   for i = 1, Num_Lots, 1 do -- Сделка закрыть Short_Call
      if SC_Num_Cl[i] == trade.order_num then
         LC_Price[i] = LC_Price[i] - SC_Price[i] + trade.price
         History = History + SC_Price[i] - trade.price
         SC_Volume = SC_Volume - trade.qty
         SC_Price[i] = 0
         SC_Num_Cl[i] = 0
         SC_Lin_Cl[i] = 0
      end
   end
   ---------------------------------------------------------------------------------
   if LP_Num == trade.order_num then -- Сделка Long_Put
      LP_Open = 0
      LP_Num = 0
      LP_Lin = 0
      LP_Volume = LP_Volume + trade.qty
      for i = Num_Lots, 1, -1 do if LP_Price[i] == 0 then iLP_Pr = i end; end
      LP_Price[iLP_Pr] = trade.price + Commission
   end
   if SP_Num == trade.order_num then -- Сделка Short_Put
      SP_Open = 0
      SP_Num = 0
      SP_Lin = 0
      SP_Volume = SP_Volume + trade.qty
      for i = Num_Lots, 1, -1 do if SP_Price[i] == 0 then iSP_Pr = i end; end
      SP_Price[iSP_Pr] = trade.price - Commission
   end
   for i = 1, Num_Lots, 1 do -- Сделка закрыть Short_Put
      if SP_Num_Cl[i] == trade.order_num then
         LP_Price[i] = LP_Price[i] - SP_Price[i] + trade.price
         History = History + SP_Price[i] - trade.price
         SP_Volume = SP_Volume - trade.qty
         SP_Price[i] = 0
         SP_Num_Cl[i] = 0
         SP_Lin_Cl[i] = 0
      end
   end
   SaveCurrentState()
end