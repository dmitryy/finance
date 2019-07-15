dofile("tpf.lua")

function main( ... )

    file = io.open("1.txt", "w+t")
    --classes = getClassesList()
    --sec_list = getClassSecurities("SPBOPT") -- returns all possible options
    --option = getParamEx("SPBOPT", "Si63500BG9", "theorprice")

    option = getSecurityInfo("SPBOPT", "Si63500BG9") -- get option info
    quotes = getQuoteLevel2("SPBOPT", "Si63500BG9") -- returns quotes

    table_save( "option", file, option)
    table_save( "quotes", file, quotes)
    --file:write(option)
    file:close()
    
end