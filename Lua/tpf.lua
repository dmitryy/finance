--[[
*******************************************************************
 Функция для сохранения произвольной таблицы (инструменты, сделки,
 заявки и т.п.) в файл. В качестве параметра принимает тэг, хендл
 файла (после открытия с помощью io.open) и таблицу.
 Пример вызова функции:
	table_save("orders", file, trans_result)
*******************************************************************
]]

function exportstring( s )
	return string.format("%q", s)
end

function table_save( tag, file, tbl)
	local charS,charE = "   ","\n"
	local tables,lookup = { tbl },{ [tbl] = 1 }
	file:write( charE ..tag .. "{"..charE )

	for idx,t in ipairs( tables ) do
		file:write( "-- Table: {"..idx.."}"..charE )
		file:write( "{"..charE )
		local thandled = {}

		for i,v in ipairs( t ) do
			thandled[i] = true
            local stype = type( v )
            if stype == "table" then
               if not lookup[v] then
                  table.insert( tables, v )
                  lookup[v] = #tables
               end
               file:write( charS.."{"..lookup[v].."},"..charE )
            elseif stype == "string" then
               file:write(  charS..exportstring( v )..","..charE )
            elseif stype == "number" then
               file:write(  charS..tostring( v )..","..charE )
            end
         end

         for i,v in pairs( t ) do
            if (not thandled[i]) then

               local str = ""
               local stype = type( i )
               if stype == "table" then
                  if not lookup[i] then
                     table.insert( tables,i )
                     lookup[i] = #tables
                  end
                  str = charS.."[{"..lookup[i].."}]="
               elseif stype == "string" then
                  str = charS.."["..exportstring( i ).."]="
               elseif stype == "number" then
                  str = charS.."["..tostring( i ).."]="
               end

               if str ~= "" then
                  stype = type( v )
                  if stype == "table" then
                     if not lookup[v] then
                        table.insert( tables,v )
                        lookup[v] = #tables
                     end
                     file:write( str.."{"..lookup[v].."},"..charE )
                  elseif stype == "string" then
                     file:write( str..exportstring( v )..","..charE )
                  elseif stype == "number" then
                     file:write( str..tostring( v )..","..charE )
                  end
               end
            end
         end
         file:write( "},"..charE )
      end
      file:write( "}"..charE )
end
