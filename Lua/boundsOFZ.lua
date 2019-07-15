--переменные
keyRateCB = 7.5
classCode = "TQOB"

function CreateTable()
    t_id = AllocTable()
    AddColumn(t_id, 0, "Бумага", true, QTABLE_STRING_TYPE, 15)
    AddColumn(t_id, 1, "Цена", true, QTABLE_DOUBLE_TYPE, 15)
    AddColumn(t_id, 2, "Доходность, %", true, QTABLE_DOUBLE_TYPE, 15)
    AddColumn(t_id, 3, "Дюрация, лет", true, QTABLE_DOUBLE_TYPE, 15)
    AddColumn(t_id, 4, "Купон, %", true, QTABLE_DOUBLE_TYPE, 15)
    AddColumn(t_id, 5, "Премия к ЦБ, бп", true, QTABLE_INT_TYPE, 15)
    AddColumn(t_id, 6, "Погашение", true, QTABLE_STRING_TYPE, 15)
    t = CreateWindow(t_id)
    SetWindowCaption(t_id, "ОФЗ")
end

function string.split(str, sep)
    local fields = {}
    str:gsub(string.format("([^%s]+)", sep), function(f_c) fields[#fields + 1] = f_c end)
    return fields
end

function getParamNumber(code, param)
    return tonumber(getParamEx(classCode, code, param).param_value)
end

function formatData(prm)
    return string.format("%02d.%02d.%04d", prm%100, (prm%10000)/100, prm/10000)
end

CreateTable()

arr = {}
sec_list = getClassSecurities(classCode)
sec_listTable = string.split(sec_list, ',')
j = 0
for i = 1, #sec_listTable do
    secCode = sec_listTable[i]
    securityInfo = getSecurityInfo(classCode, secCode)
    short_name = securityInfo.short_name
    if short_name:find("ОФЗ 26") ~= nil then
        j = j + 1
        r = {}
        r["short_name"] = short_name
        r["price"] = getParamNumber(securityInfo.code, "PREVPRICE")
        r["yield"] = getParamNumber(securityInfo.code, "YIELD")
        r["duration"] = getParamNumber(securityInfo.code, "DURATION")/365
        couponvalue = getParamNumber(securityInfo.code, "COUPONVALUE")
        couponperiod = getParamNumber(securityInfo.code, "COUPONPERIOD")
        r["coupon"] = ((365/couponperiod) * couponvalue)/10
        r["bonus"] = (r["yield"] - keyRateCB)*100
        r["mat_date"] = getParamNumber(securityInfo.code, "MAT_DATE")
        table.insert(arr, j, r)
    end
end

table.sort(arr, function(a,b) return a["duration"] < b["duration"] end)

for j = 1, #arr do
    row = InsertRow(t_id, -1)
    SetCell(t_id, row, 0, arr[j]["short_name"])
    price = arr[j]["price"]
    SetCell(t_id, row, 1, string.format("%.2f", price), price)
    yield = arr[j]["yield"]
    SetCell(t_id, row, 2, string.format("%.2f", yield), yield)
    duration = arr[j]["duration"]
    SetCell(t_id, row, 3, string.format("%.2f", duration), duration)
    coupon = arr[j]["coupon"]
    SetCell(t_id, row, 4, string.format("%.2f", coupon), coupon)
    bonus = arr[j]["bonus"]
    SetCell(t_id, row, 5, string.format("%.0f", bonus), bonus)
    mat_date = arr[j]["mat_date"]
    SetCell(t_id, row, 6, formatData(mat_date), mat_date)
end