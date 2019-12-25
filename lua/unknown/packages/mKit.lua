me = { }
--[[
    std::string md5ofstring(std::string str);
    std::string md5ofile(std::string path);
    Node* seekNodeByName(Node* root, const std::string& name);
    Node* seekNodeByTag(Node* root, int tag);
]]
me.winSize = cc.Director:getInstance():getVisibleSize()
me.Helper = mHelper:getInstance()
targetPlatform = cc.Application:getInstance():getTargetPlatform()
--[[
    decode
    encode
]]
me.cjson = require "cjson"
me.toStr = tostring
me.toNum = tonumber
me.Scheduler = cc.Director:getInstance():getScheduler()
me.showMemory = function()
    collectgarbage("collect")
    local t = me.Helper:CachedTextureTotalBytes() / 1024
    local l = collectgarbage("count")
    local s = "total memory %.2f mb texture %.2f mb lua %.2f mb"
    s = string.format(s,(t + l) / 1024, t / 1024, l / 1024)
    -- cc.Director:getInstance():getTextureCache():dumpCachedTextureInfo()
    print(s)
    return s
end
-- 加载plist 图片到缓冲下e4a84a 上ffffda
me.addSpriteWithFile = function(plist)
    cc.SpriteFrameCache:getInstance():addSpriteFrames(plist)
end
-- 异步加载动画
me.mAddArmatureFileInfoAsync = function(ani, callfunc)
    print("load ani " .. ani)
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfoAsync(ani, callfunc)
end
me.mAddArmatureFileInfo = function(ani)
    local path = cc.FileUtils:getInstance():fullPathForFilename(ani)
    if path then
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(path)
    else
        showErrorMsg("not find "..ani)
    end
end
me.mod = function(num, t)
    local a = 1
    if num < 0 then
        a = -1
    end
    num = math.abs(num)
    return a *(num % t)
end
-- 异步加载plist
me.addSpriteWithFileSync = function(plist, callback)
    local function loadend(textrue)
        me.addSpriteWithFile(plist .. ".plist")
        print(plist .. "- loaded")
        if callback then
            callback(plist)
        end
    end
    if cc.FileUtils:getInstance():isFileExist(plist .. ".png") then
        cc.Director:getInstance():getTextureCache():addImageAsync(plist .. ".png", loadend)
    else
        cc.Director:getInstance():getTextureCache():addImageAsync(plist .. ".pvr.ccz", loadend)
    end
end
-- 异步加载png
me.addImageAsync = function(png, callback)
    local function call_(textrue)
        print(png .. "  loaded")
        if callback then
            callback(textrue, png)
        end
    end
    cc.Director:getInstance():getTextureCache():addImageAsync(png, call_)
end
me.removeImage = function(png)
    cc.Director:getInstance():getTextureCache():removeTextureForKey(png)
end
-- 删除plist图片从缓冲
me.removeSpriteWithFile = function(plist)
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(plist)
end

-- 获取系统时间 毫秒
me.sysTime = function()
   if CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
      if server and server.Cross_sysoffset then
         return socket.gettime() * 1000 + server.Cross_sysoffset or 0
      end
   else     
      if server and server.sysoffset then
         return socket.gettime() * 1000 + server.sysoffset or 0
      end
   end
    return socket.gettime() * 1000
end
me.createNode = function(csb)
    return cc.CSLoader:createNode(csb)
end
me.doLayout = function(node, size)
    node:setContentSize(size)
    ccui.Helper:doLayout(node)
end
--回车，ASCII码13
--换行，ASCII码10
--空格，ASCII码32
function me.filter_spec_chars(s)
    local ss = {}
    local k = 1
    while true do
        if k > #s then break end
        local c = string.byte(s,k)
        if not c then break end
        if c~= 13 and c~=10 then           
            table.insert(ss, string.char(c))               
        end
         print(c,string.char(c),k)
         k = k + 1
    end
    return table.concat(ss)
end
me.dispatchCustomEvent = function(eName, data)
    local event = cc.EventCustom:new(eName)
    event._userData = data
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:dispatchEvent(event)
end
-- 监听自定义事件
me.RegistCustomEvent = function(eName, fuc)    
    local ce = cc.EventListenerCustom:create(eName, fuc)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(ce, 1)
    if jnmocustom == nil then
        jnmocustom = { }
    end
    jnmocustom[eName] = ce
    return ce
end

-- 监听自定义事件
me.RegistCustomEventAnother = function(eName, fuc)
    local ce = cc.EventListenerCustom:create(eName, function(evt)
        fuc(evt._userData)
    end)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(ce, 1)
    if jnmocustom == nil then
        jnmocustom = { }
    end
    jnmocustom[eName] = ce
    return ce
end

-- 删除自定义事件
me.RemoveCustomEvent = function(ce)
    if ce then
        local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
        eventDispatcher:removeEventListener(ce)
    end
end
me.RemoveCustomEventByName = function(eName)
    if jnmocustom and jnmocustom[eName] then
        local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
        eventDispatcher:removeEventListener(jnmocustom[eName])
    end
end
function me.roundOff(num, n)
    if n > 0 then
        local scale = math.pow(10, n - 1)
        return math.floor(num / scale + 0.5) * scale
    elseif n < 0 then
        local scale = math.pow(10, n)
        return math.floor(num / scale + 0.5) * scale
    elseif n == 0 then
        return num
    end
end
function me.urlEncode(s)
     s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end
function me.urlDecode(s)
    s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
    return s
end
me.convert3Color_ = function(xStr)
    local function toTen(v)
        return tonumber("0x" .. v)
    end
    local b = string.sub(xStr, -2, -1)
    local g = string.sub(xStr, -4, -3)
    local r = string.sub(xStr, -6, -5)
    local red = toTen(r)
    local green = toTen(g)
    local blue = toTen(b)
    return cc.c3b(red, green, blue)
end
me.convert4Color_ = function(xStr, aplh)
    local function toTen(v)
        return tonumber("0x" .. v)
    end
    local b = string.sub(xStr, -2, -1)
    local g = string.sub(xStr, -4, -3)
    local r = string.sub(xStr, -6, -5)
    local red = toTen(r)
    local green = toTen(g)
    local blue = toTen(b)
    return cc.c4b(red, green, blue, aplh or 255)
end

--  table中删除指定元素(非根据索引)
--  @param  array 要操作的容器
--  @param  value 删除value值
--  @param  removeadll 是否删除所有相同的值
--  @return 返回删除值的个数
me.removebyvalue = function(array, value, removeadll)
    --  deleteNum用于接收/返回删除个数; i/max 构成控制while循环
    local deleteNum, i, max = 0, 1, #array
    while i <= max do
        if array[i] == value then
            --  通过索引操作表的删除元素
            table.remove(array, i)
            --  标记删除次数
            deleteNum = deleteNum + 1
            i = i - 1
            --  控制while循环操作
            max = max - 1
            --  判断是否删除所有相同的value值
            if not removeadll then break end
        end
        i = i + 1
    end
    --  返回删除次数
    return deleteNum
end
--  table中删除指定元素(与table[key] == value)
--  @param  array 要操作的容器
--  @param  value 删除value值
--  @param  removeadll 是否删除所有相同的值
--  @return 返回删除值的个数
me.removebyvalue = function(array, key, value, removeadll)
    --  deleteNum用于接收/返回删除个数; i/max 构成控制while循环
    local deleteNum, i, max = 0, 1, #array
    while i <= max do
        if array[i][key] == value then
            --  通过索引操作表的删除元素
            table.remove(array, i)
            --  标记删除次数
            deleteNum = deleteNum + 1
            i = i - 1
            --  控制while循环操作
            max = max - 1
            --  判断是否删除所有相同的value值
            if not removeadll then break end
        end
        i = i + 1
    end
    --  返回删除次数
    return deleteNum
end
--- 深复制table
me.copyTab = function(st)
    local tab = { }
    for k, v in pairs(st or { }) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = me.copyTab(v)
        end
    end
    return tab
end
me.assignWidget = function(parent, name)
    assert(parent, "assignWidget parent is nil")
    return mUIHelper:getInstance():seekNodeByName(parent, name)
end
-- 为名字为name的控件注册触摸事件，并返回控件
me.registGuiTouchEventByName = function(parent, name, callfuc, tag)
    -- body
    local widget = me.assignWidget(parent, name)
    if widget then
        assert(widget.addTouchEventListener, "is not widget")
        widget:setTouchEnabled(true)
        widget:addTouchEventListener(callfuc)
        if tag then
            widget:setTag(tag)
        end
        return widget
    end
    return nil
end
-- 为名字为name的控件注册触摸事件，并返回控件
me.registGuiClickEventByName = function(parent, name, callfuc, tag)
    -- body
    local widget = me.assignWidget(parent, name)
    if widget then
        assert(widget.addTouchEventListener, "isnot widget")
        widget:setTouchEnabled(true)
        widget:addClickEventListener(callfuc)
        if tag then
            widget:setTag(tag)
        end
        return widget
    end
    return nil
end
-- 注册widget对象触摸事件
me.registGuiTouchEvent = function(widget, callfuc)
    -- body
    assert(widget.addTouchEventListener, "isnot widget")
    widget:setTouchEnabled(true)
    widget:addTouchEventListener(callfuc)
end
me.registGuiClickEvent = function(widget, callfuc)
    assert(widget.addClickEventListener, "isnot widget")
    widget:setTouchEnabled(true)
    widget:addClickEventListener(callfuc)
end
me.turnNode = function(node, show)
    if node and show then
        local orb90 = cc.OrbitCamera:create(0.6, 1, 0, 0, 90, 0, 0)
        local orb180 = cc.OrbitCamera:create(0.6, 1, 0, 90, 90, 0, 0)
        local function call90(args)
            show:setVisible(true)
        end
        local function call180(args)

        end
        local seq = cc.Sequence:create(orb90, cc.CallFunc:create(call90), orb180, cc.CallFunc:create(call180))
        node:runAction(seq)
    end
end
--- 一般 anchor 用cc.p(0,2)  
-- @Anchor.x 表示是采用上中下对齐还是 下对齐距离绝对值
-- Anchor.x 0表示采用对齐 y 1 表示上 2表示中 3 表示下
me.putNodeOnLeft = function(tagNode, putNode, padding, Anchor)
    local rect_ = tagNode:getBoundingBox()
    local rect2_ = putNode:getBoundingBox()
    local putNodePos = nil
    if Anchor.x == 0 then
        if Anchor.y == 1 then
            putNodePos = cc.p(rect_.x - padding - rect2_.width, cc.rectGetMaxY(rect_) - rect2_.height)
        end
        if Anchor.y == 2 then
            putNodePos = cc.p(rect_.x - padding - rect2_.width, cc.rectGetMinY(rect_) +(rect_.height - rect2_.height) / 2)
        end
        if (Anchor.y == 3) then
            putNodePos = cc.p(rect_.x - padding - rect2_.width, cc.rectGetMinY(rect_))
        end
    else
        if Anchor.x == 1 then
            putNodePos = cc.p(rect_.x - padding - rect2_.width, cc.rectGetMinY(rect_) + Anchor.y)
        end
    end
    putNodePos.x = putNodePos.x + putNode:getAnchorPoint().x * rect2_.width
    putNodePos.y = putNodePos.y + putNode:getAnchorPoint().y * rect2_.height
    putNode:setPosition(putNodePos);
end
-- @Anchor.x 表示是采用上中下对齐还是 下对齐距离绝对值
-- Anchor.x 0表示采用对齐 y 1 表示上 2表示中 3 表示下
me.putNodeOnRight = function(tagNode, putNode, padding, Anchor)
    local rect_ = tagNode:getBoundingBox()
    local rect2_ = putNode:getBoundingBox()
    local putNodePos = nil
    if Anchor.x == 0 then
        if Anchor.y == 1 then
            putNodePos = cc.p(cc.rectGetMaxX(rect_) + padding, cc.rectGetMaxY(rect_) - rect2_.height)
        end
        if Anchor.y == 2 then
            putNodePos = cc.p(cc.rectGetMaxX(rect_) + padding, cc.rectGetMinY(rect_) +(rect_.height - rect2_.height) / 2)
        end
        if (Anchor.y == 3) then
            putNodePos = cc.p(cc.rectGetMaxX(rect_) + padding, cc.rectGetMinY(rect_))
        end
    else
        if Anchor.x == 1 then
            putNodePos = cc.p(cc.rectGetMaxX(rect_) + padding, cc.rectGetMinY(rect_) + Anchor.y)
        end
    end
    putNodePos.x = putNodePos.x + putNode:getAnchorPoint().x * rect2_.width
    putNodePos.y = putNodePos.y + putNode:getAnchorPoint().y * rect2_.height
    putNode:setPosition(putNodePos);
end
-- @Anchor.x 0表示是采用左中右对齐还是 1左对齐距离绝对值
-- Anchor.x 0 表示采用对齐 y 1 表示左 2表示中 3 表示右
me.putNodeOnTop = function(tagNode, putNode, padding, Anchor)
    local rect_ = tagNode:getBoundingBox()
    local rect2_ = putNode:getBoundingBox()
    local putNodePos = nil
    if Anchor.x == 0 then
        if Anchor.y == 1 then
            putNodePos = cc.p(cc.rectGetMinX(rect_), cc.rectGetMinY(rect_) - padding - rect2_.height)
        end
        if Anchor.y == 2 then
            putNodePos = cc.p(cc.rectGetMinX(rect_) +(rect_.width - rect2_.width) / 2, cc.rectGetMaxY(rect_) + padding)
        end
        if (Anchor.y == 3) then
            putNodePos = cc.p(cc.rectGetMinX(rect_) + rect_.width, cc.rectGetMaxY(rect_) + padding)
        end
    else
        if Anchor.x == 1 then
            putNodePos = cc.p(cc.rectGetMinX(rect_) + Anchor.y, cc.rectGetMaxY(rect_) + padding)
        end
    end
    putNodePos.x = putNodePos.x + putNode:getAnchorPoint().x * rect2_.width
    putNodePos.y = putNodePos.y + putNode:getAnchorPoint().y * rect2_.height
    putNode:setPosition(putNodePos);
end
me.putNodeOnCenter = function(tagNode, putNode)
    tagNode:addChild(putNode, 100)
    putNode:setPosition(tagNode:getContentSize().width / 2 + putNode:getAnchorPoint().x * putNode:getContentSize().width - putNode:getContentSize().width / 2,
    putNode:getAnchorPoint().y * putNode:getContentSize().height + tagNode:getContentSize().height / 2 - putNode:getContentSize().height / 2)
end
-- @Anchor.x 表示是采用左中右对齐还是 左对齐距离绝对值
-- Anchor.x 0表示采用对齐 y 1 表示左 2表示中 3 表示右
me.putNodeOnBottom = function(tagNode, putNode, padding, Anchor)
    local rect_ = tagNode:getBoundingBox()
    local rect2_ = putNode:getBoundingBox()
    local putNodePos = nil
    if Anchor.x == 0 then
        if Anchor.y == 1 then
            putNodePos = cc.p(cc.rectGetMinX(rect_), cc.rectGetMinY(rect_) - padding - rect2_.height)
        end
        if Anchor.y == 2 then
            putNodePos = cc.p(cc.rectGetMinX(rect_) +(rect_.width - rect2_.width) / 2, cc.rectGetMinY(rect_) - rect2_.height - padding)
        end
        if (Anchor.y == 3) then
            putNodePos = cc.p(cc.rectGetMinX(rect_) + rect_.width, cc.rectGetMinY(rect_) - padding - rect2_.height)
        end
    else
        if Anchor.x == 1 then
            putNodePos = cc.p(cc.rectGetMinX(rect_) + Anchor.y, cc.rectGetMinY(rect_) - padding - rect2_.height)
        end
    end
    putNodePos.x = putNodePos.x + putNode:getAnchorPoint().x * rect2_.width
    putNodePos.y = putNodePos.y + putNode:getAnchorPoint().y * rect2_.height
    putNode:setPosition(putNodePos);
end
function me.contains(node, x, y)
    local point = cc.p(x, y)
    local pRect = cc.rect(0, 0, node:getContentSize().width, node:getContentSize().height)
    local locationInNode = node:convertToNodeSpace(point)
    -- 世界坐标转换成节点坐标
    return cc.rectContainsPoint(pRect, locationInNode)
end
function me.formatnumberthousands(num)
	local function checknumber(value)
		return tonumber(value) or 0
	end
	local formatted = tostring(checknumber(num))
	local k
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		print(formatted,k)
		if k == 0 then 
			break end
		end
	return formatted
end
-- 队列实现
--
-- local nqueue = Queue.new()
-- Queue.push(nqueue,"gagag")
-- Queue.push(nqueue,2)
-- print("quque =======",Queue.pop(nqueue))
--
Queue = { }
function Queue.new()
    return { first = 0, last = - 1 }
end
-- 插入
function Queue.insert(Q, index, value)
    local newQueue = { }
    for i = 0, Q.last do
        if index == i then
            newQueue[index] = value
            newQueue[index + 1] = Q[index]
        elseif i > index then
            newQueue[i + 1] = Q[i]
        elseif i < index then
            newQueue[i] = Q[i]
        end
    end
    newQueue.first = Q.first
    newQueue.last = Q.last + 1
    return newQueue
end
-- 反转
function Queue.reverse(Q)
    local reverseQueue = { }
    for i = 0, Q.last do
        reverseQueue[i] = Q[Q.last - i]
    end
    reverseQueue.first = Q.first
    reverseQueue.last = Q.last
    return reverseQueue
end
-- 压入
function Queue.push(Q, value)

    local last = Q.last + 1

    Q.last = last

    Q[last] = value

end
-- 弹出
function Queue.pop(Q)

    local first = Q.first

    if first > Q.last then error("Q is empty") end

    local value = Q[first]

    Q[first] = nil

    Q.first = Q.first + 1
    return value
end
-- 获取最下端
function Queue.back(Q)
    local last = Q.last
    if last < Q.first then return nil end

    local value = Q[last]
    return vlue
end
-- 获取最上端
function Queue.front(Q)
    local first = Q.first

    if first > Q.last then error("Q is empty") end

    local value = Q[first]
    return value
end
-- 清除
function Queue.clear(Q)
    while not Queue.isEmpty(Q) do
        Queue.pop(Q)
    end
    Q.first = 0
    Q.last = -1

end
-- 是否为空
function Queue.isEmpty(Q)
    if Q then
        local first = Q.first
        return first > Q.last
    else
        Q = Queue.new()
        return true
    end
end
-- 数量
function Queue.count(Q)
    if Q then
        return Q.last - Q.first + 1
    else
        Q = Queue.new()
        return 0
    end
end

-- 获取1-n的随机整数
me.getRandom = function(n1, n2, n3)
    -- body
    if n2 and n3 then
        math.randomseed(math.random(tonumber(tostring(socket.gettime()):reverse():sub(tonumber(n2), tonumber(n3)))))
    else
        math.randomseed(math.random(tonumber(tostring(socket.gettime()):reverse():sub(1, 6))))
    end
    return math.random(n1)
end

local tconcat = table.concat
local tinsert = table.insert
local srep = string.rep
local type = type
local pairs = pairs
local tostring = tostring
local next = next
me.LogTable = function(root)
    local traceback = string.split(debug.traceback("", 2), "\n")
    print("Log table: " .. string.trim(traceback[3]))
    local cache = { [root] = "." }
    local function _dump(t, space, name)
        local temp = { }
        for k, v in me.pairs(t) do
            local key = tostring(k)
            if cache[v] then
                tinsert(temp, "+" .. key .. " {" .. cache[v] .. "}")
            elseif type(v) == "table" then
                local new_key = name .. "." .. key
                cache[v] = new_key
                tinsert(temp, "+" .. key .. _dump(v, space ..(next(t, k) and "|" or " ") .. srep(" ", #key), new_key))
            else
                tinsert(temp, "+" .. key .. " [" .. tostring(v) .. "]")
            end
        end
        return tconcat(temp, "\n" .. space)
    end
    print(_dump(root, "", ""))
end
me.leftOut = function(node)
    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(me.winSize.width, me.winSize.height))
    layout:setTouchEnabled(true)
    node:getParent():addChild(layout)

    local function callback(node)
        node:setVisible(false)
        if layout then
            layout:removeFromParentAndCleanup(true)
        end
    end
    local a = cc.MoveTo:create(0.1, cc.p(- node:getContentSize().width / 2, node:getPositionY()))
    node:runAction(cc.Sequence:create(a, cc.CallFunc:create(callback)))
end
me.RightIn = function(node)
    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(me.winSize.width, me.winSize.height))
    layout:setTouchEnabled(true)
    node:getParent():addChild(layout)

    node:setPosition(me.winSize.width + node:getContentSize().width / 2, node:getPositionY())
    node:setVisible(true)

    local function callback(node)
        node:setPosition(cc.p(me.winSize.width / 2, node:getPositionY()))
        if layout then
            layout:removeFromParentAndCleanup(true)
        end
    end
    local a = cc.MoveTo:create(0.5, cc.p(me.winSize.width / 2, node:getPositionY()))
    node:runAction(cc.Sequence:create(cc.EaseElasticOut:create(a), cc.CallFunc:create(callback)))
end
me.leftOutRightIn = function(outNode, inNode)
    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(me.winSize.width, me.winSize.height))
    layout:setTouchEnabled(true)
    outNode:getParent():addChild(layout)

    local a1 = cc.MoveTo:create(0.4, cc.p(- outNode:getContentSize().width / 2, outNode:getPositionY()))
    local function a1callback(node)
        node:setVisible(false)
    end
    outNode:runAction(cc.Sequence:create(a1, cc.CallFunc:create(a1callback)))

    local a2 = cc.MoveTo:create(0.5, cc.p(me.winSize.width / 2, inNode:getPositionY()))
    local function a2callback(node)
        if layout then
            layout:removeFromParentAndCleanup(true)
        end
    end
    inNode:setPosition(me.winSize.width + inNode:getContentSize().width / 2, inNode:getPositionY())
    inNode:setVisible(true)
    inNode:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.EaseElasticOut:create(a2), cc.CallFunc:create(a2callback)))
end
me.split2 = function (str, split_char)
    if str == nil or split_char == nil then
        print("split str is nil or key is nil")
        return nil
    end
    local res = { }
    while (true) do
        local pos = string.find(str, split_char)
        if (not pos) then
            if string.len(str) > 0 then
                table.insert(res, str)
            end
            break
        end
        local splitLen = string.len(split_char)
        if pos - 1 > 0 then
            local sub_str = string.sub(str, 1, pos - 1)
            table.insert(res, sub_str)
            local t = string.len(str)
            str = string.sub(str, pos + splitLen, t)
        else
            table.insert(res, "流浪")
            local t = string.len(str)
            str = string.sub(str, pos + splitLen, t)
        end
    end
    return res;
end

-- 参数:待分割的字符串,分割字符
-- 返回:子串表.(含有空串)
me.split = function(str, split_char)
    if str == nil or split_char == nil then
        print("split str is nil or key is nil")
        return nil
    end
    local res = { }
    while (true) do
        local pos = string.find(str, split_char);
        if (not pos) then
            if string.len(str) > 0 then
                table.insert(res, str)
            end
            break;
        end
        local splitLen = string.len(split_char)
        if pos - 1 > 0 then
            local sub_str = string.sub(str, 1, pos - 1);
            if me.isValidStr(sub_str) == false then
                sub_str = " "
            end
            table.insert(res, sub_str);
            local t = string.len(str);
            str = string.sub(str, pos + splitLen, t);
        else
            break
        end
    end
    return res;
end

function me.aroundNodeMove(node, targetNode)
    local ap = targetNode:getAnchorPoint()
    local box = targetNode:getBoundingBox()
    node:setPosition(cc.p(box.x, box.y + box.height))
    local a1 = cc.MoveTo:create(1, cc.p(box.x + box.width, box.y + box.height))
    local a2 = cc.MoveTo:create(1, cc.p(box.x + box.width, box.y))
    local a3 = cc.MoveTo:create(1, cc.p(box.x, box.y))
    local a4 = cc.MoveTo:create(1, cc.p(box.x, box.y + box.height))
    local seq = cc.Sequence:create(a1, a2, a3, a4)
    local repeatForever = cc.RepeatForever:create(seq)
    node:runAction(repeatForever)
end
-- 去掉table中为nil的
me.tablefilter = function(data)
    if data == nil then
        print("core.print data is nil");
    end

    if (type(data) == "table") then
        local num = 0
        local dkey = { }
        for k, v in pairs(data) do
            if (type(v) == "table") then
                tablefilter(v);
            elseif v == "nil" then

                print(k .. "-value = nil")

                -- table.remove(data,k+num)
                if type(k) == "number" then
                    table.insert(dkey, k + num)
                    num = num - 1
                    print("num = ", num)
                else
                    print("del v")
                    data[k] = nil
                end
            end
        end
        for key, var in pairs(dkey) do
            table.remove(data, var)
        end
        -- LogTable(data)
    end
end
-- -1   Not an array
-- 0    Empty table
-- >0   Highest index in the array
me.is_array = function(table)
    local max = 0
    local count = 0
    for k, v in pairs(table) do
        if type(k) == "number" then
            if k > max then max = k end
            count = count + 1
        else
            return -1
        end
    end
    if max > count * 2 then
        return -1
    end
    return max
end
me.setWidgetCanTouchDelay = function(button, time)
    local t = time or 0.3
    local function call_(node)
        button:setTouchEnabled(true)
    end
    local a = cc.DelayTime:create(t)
    local a1 = cc.CallFunc:create(call_)
    local function call2(node)
        button:setFocused(false)
        button:setTouchEnabled(false)
    end
    local a2 = cc.DelayTime:create(0.01)
    local a3 = cc.CallFunc:create(call2)
    button:runAction(cc.Sequence:create(a3, a, a1))
end
me.setButtonDisable = function(button, b)   
    if  button.setBright then
         button:setTouchEnabled(b)
         button:setBright(b)   
         if b then 
              local chs = button:getChildren()
              for key, var in pairs(chs) do
                   if var.getDescription and  var:getDescription() == "TextBMFont" then
                       local renderer = var:getVirtualRenderer()
                       me.revokeSprite(renderer)
                   elseif var.getDescription and  var:getDescription() == "ImageView" then
                       local renderer = var:getVirtualRenderer()
                       me.revokeSprite(renderer)
                   end
              end              
         else
            local chs = button:getChildren()
              for key, var in pairs(chs) do
                   if var.getDescription and  var:getDescription() == "TextBMFont" then
                       local renderer = var:getVirtualRenderer()                      
                       me.graySprite(renderer)
                   elseif var.getDescription and  var:getDescription() == "ImageView" then
                       local renderer = var:getVirtualRenderer()
                       me.graySprite(renderer)
                   end
              end    
         end   
    end
end
me.hideLayer = function(layer, bclearn, actNodename)
    local a1 = cc.ScaleTo:create(0.06, 1.05)
    local a2 = cc.ScaleTo:create(0.08, 0.95)
    local a3 = cc.ScaleTo:create(0.05, 1.05)
    local a4 = cc.ScaleTo:create(0.05, 0.01)
    local function popcallback(node)
        if (layer.setTouchEnabled) then
            layer:setTouchEnabled(false)
        end
        layer:setVisible(false)
        node:setScale(1)
        if bclearn then
            print("remove child")
            layer:removeFromParentAndCleanup(true)

        end
    end
    if actNodename then
        local aninode = me.assignWidget(layer, actNodename)
        aninode:runAction(cc.Sequence:create(a1, a2, a3, cc.CallFunc:create(popcallback)))
    else
        layer:runAction(cc.Sequence:create(a1, a2, a3, cc.CallFunc:create(popcallback)))
    end
    -- layer:runAction(cc.Sequence:create(cc.CallFunc:create(popcallback)))
end
me.showLayer = function(layer, actNodename)
    layer:setVisible(true)
    if (layer.setTouchEnabled) then
        layer:setTouchEnabled(false)
    end
    local a1 = cc.ScaleTo:create(0.06, 1.05)
    local a2 = cc.ScaleTo:create(0.08, 0.95)
    local a3 = cc.ScaleTo:create(0.05, 1.0)
    local function popcallback(node)
        if (layer.setTouchEnabled) then
            layer:setTouchEnabled(true)
        end
    end
    if actNodename then
        local aninode = me.assignWidget(layer, actNodename)
        aninode:setScale(1)
        aninode:runAction(cc.Sequence:create(a1, a2, a3, cc.CallFunc:create(popcallback)))
    else
        layer:setScale(1)
        layer:runAction(cc.Sequence:create(a1, a2, a3, cc.CallFunc:create(popcallback)))
    end
end
me.popLayer = function(layer, anode)
    local s = me.runningScene()
    s:addChild(layer, me.MAXZORDER)
    if anode then
        local a = cc.ScaleTo:create(0.5, 1)
        local b = cc.EaseBounceOut:create(a)
        local aninode = me.assignWidget(layer, anode)
        aninode:setScale(0.5)
        aninode:runAction(b)
    end
end
-- 创建消息框
-- @str 消息内容
-- @eName 


me.removeAllianceTechCoolDownDialog = function(str, callfuc)
    local box = MessageBox:create("MessageBox_AllianceTechCoolDown.csb")
    box:setText(str, color or nil, fontsize or nil)
    box:register(callfuc or nil)
    cc.Director:getInstance():getRunningScene():addChild(box, MESSAGE_ORDER)
    me.showLayer(box, "msgBox")
end

-- 移除据点的特殊对话框
me.removeStrongHoldDialog = function(str, callfuc)
    local box = MessageBox:create("MessageBox_StrongHold.csb")
    box:setText(str, color or nil, 20)
    box:register(callfuc or nil)
    me.assignWidget(box.closeBtn, "text_title_btn"):setString(TID_COMMON_CANCEL)
    cc.Director:getInstance():getRunningScene():addChild(box, MESSAGE_ORDER)
    me.showLayer(box, "msgBox")
end
me.showMessageDialog = function(str, callfuc, mode, color, fontsize)
    local box = MessageBox:create("MessageBox.csb")
    box:setText(str, color or nil, fontsize or nil)
    box:register(callfuc or nil)
    box:setButtonMode(mode or nil)
    cc.Director:getInstance():getRunningScene():addChild(box, MESSAGE_ORDER)
    me.showLayer(box, "msgBox")
end
me.reconnectDialog = function(str, callfuc)
    local box = MessageBox:create("MessageBox.csb")
    box:setText(str, color or nil, fontsize or nil)
    box:register(callfuc or nil)
    me.assignWidget(box.closeBtn,"title"):setString(TID_EIXT_GAME)
    cc.Director:getInstance():getRunningScene():addChild(box, MESSAGE_ORDER)
    me.showLayer(box, "msgBox")
    return box
end
me.runScene = function(layer, time)
    local s = cc.Scene:create()
    s:addChild(layer)
    if time then
        cc.Director:getInstance():replaceScene(cc.TransitionFade:create(time or 1, s))
    else
        cc.Director:getInstance():replaceScene(s)
    end
end

-- 为node添加点击特效
me.addClickEffect = function(node, particleName)
    if not node or not particleName or particleName == "" then
        print("layer为空 或者 粒子特效名称为空")
        return
    end
    if not cc.FileUtils:getInstance():isFileExist(particleName) then
        print("粒子文件不存在")
    end
    local touchLayer = ccui.Layout:create()
    touchLayer:setContentSize(node:getContentSize())
    touchLayer:setTouchEnabled(true)
    touchLayer:setSwallowTouches(false)
    node:addChild(touchLayer, me.MAXZORDER * 3)
    local function onTouchBegan(touch, event)
        --print("Touch Begin")
        return true
    end
    local function onTouchMoved(touch, event)
        --print("Touch Moved")
    end
    local function onTouchEnded(touch, event)
        --print("Touch Ended")
        local cItem = cc.ParticleSystemQuad:create(particleName)
        cItem:setPosition(touchLayer:convertToNodeSpace(touch:getLocation()))
        touchLayer:addChild(cItem)
        local function arrive(node)
            node:removeFromParentAndCleanup(true)
        end
        local callback = cc.CallFunc:create(arrive)
        cItem:runAction(cc.Sequence:create(cc.DelayTime:create(1), callback))
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = touchLayer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, touchLayer)
end

me.runningScene = function()
    return cc.Director:getInstance():getRunningScene()
end
me.plistType = ccui.TextureResType.plistType
me.localType = ccui.TextureResType.localType
-- 是否为纯数字
me.isPureNumber = function(num_)
    if num_ == nil or string.len(num_) <= 0 then
        return false
    end

    local isNot = true
    for i = 1, string.len(num_) do
        if string.byte(num_, i) and not(string.byte(num_, i) >= 48 and string.byte(num_, i) <= 57) then
            isNot = false
            break
        end
    end
    return isNot
end

-- 判断有没有空字节
me.isSpaceChar = function(str_)
    for i = 1, string.len(str_) do
        if string.byte(str_, i) and string.byte(str_, i) == 32 then
            return true
        end
    end
    return false
end
me.isValidStr = function(str_)
    if str_ == nil then
        return false
    end
    if str_ and string.len(str_) > 0 then
        return true
    end
    return false
end
me.DelayRun = function(fuc, time, node)
    local t = time or 0.05
    local a = cc.DelayTime:create(t)
    local call = cc.CallFunc:create(fuc)
    local seq = cc.Sequence:create(a, call)
    if node then
        node:runAction(seq)
    else
        cc.Director:getInstance():getRunningScene():runAction(seq)
    end
end
me.MAXZORDER = 9999
me.GUIDEZODER = me.MAXZORDER + 999 -- 引导界面层级
me.POPUPZODER = me.MAXZORDER + 100 -- 奖励物品，提示等的弹窗层级
me.ANIMATION = me.MAXZORDER + 200 -- 特效层，所有层之上
--[[
 self.cthread =   coroutine.create(function ()
            --这里为调用的方法 然后在该方法中加入coroutine.yield()
            this:initForBuild()
       end)
 me.coroStart(self.cthread)
]]
me.coroStart = function(t, time_, callBack_)
    local schid = nil
    local function update(dt)
        if not coroutine.resume(t) then
            if schid then
                me.Scheduler:unscheduleScriptEntry(schid)
            end
            if callBack_ then
                callBack_()
            end
        end
    end
    schid = me.Scheduler:scheduleScriptFunc(update, time_ or 0, false)
    return schid
end
me.coroClear = function(s)
    if s then
        me.Scheduler:unscheduleScriptEntry(s)
    end
end
-- 添加输入框 父节点，位置X,Y  宽 高 背景图片名字，回调，占位文本，输入模式。cc.EDITBOX_INPUT_MODE_ANY
me.addInputBox = function(width, height, fontSize, bgName, callfunc, editbox_input_mode, placeHolder)
    local function editBoxTextEventHandle(strEventName, pSender)
        --            local edit = pSender
        --            local strFmt
        --            if strEventName == "began" then
        --                strFmt = string.format("editBox %p DidBegin !", edit)
        --                print(strFmt)
        --            elseif strEventName == "ended" then
        --                strFmt = string.format("editBox %p DidEnd !", edit)
        --                print(strFmt)
        --            elseif strEventName == "return" then
        --                strFmt = string.format("editBox %p was returned !", edit)
        --                print(strFmt)
        --            elseif strEventName == "changed" then
        --                strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
        --                print(strFmt)
        --            end
        if callfunc and me.isTargetPlatform_IOS() then
            callfunc(strEventName, pSender)
        end
    end
    if bgName==nil then
        bgName="default.png"
    end
    local EditEmail = cc.EditBox:create(cc.size(width, height), cc.Scale9Sprite:create(bgName))
    EditEmail:setAnchorPoint(cc.p(0.5, 0.5))
    EditEmail:setPlaceHolder(placeHolder or "")
    EditEmail:setInputMode(editbox_input_mode or cc.EDITBOX_INPUT_MODE_ANY)
    EditEmail:registerScriptEditBoxHandler(editBoxTextEventHandle)
    EditEmail:setFontSize(fontSize)
    EditEmail:setPlaceholderFontSize(fontSize)    
    EditEmail:setPlaceholderFontColor(cc.c3b (88,89,93))
    EditEmail:setFontColor(cc.c3b(182,168,113))
    --    EditEmail:setTouchEnabled(me.isTargetPlatform_IOS())
    return EditEmail
end
me.buttonState = function(button, b)
    button:setTouchEnabled(b)
    button:setBright(b)
    local title = me.assignWidget(button, "title")
    if title then
        if b then
            title:setColor(me.convert3Color_("f1d2b5"))
        else
            title:setColor(me.convert3Color_("f0df99"))
        end
    end
end
-- 转换成string
me.serialize = function(obj)
    local lua = ""
    local t = type(obj)
    if t == "number" then
        lua = lua .. obj
    elseif t == "boolean" then
        lua = lua .. tostring(obj)
    elseif t == "string" then
        lua = lua .. string.format("%q", obj)
    elseif t == "table" then
        lua = lua .. "{\n"
        for k, v in pairs(obj) do
            lua = lua .. "[" .. me.serialize(k) .. "]=" .. me.serialize(v) .. ",\n"
        end
        local metatable = getmetatable(obj)
        if metatable ~= nil and type(metatable.__index) == "table" then
            for k, v in pairs(metatable.__index) do
                lua = lua .. "[" .. me.serialize(k) .. "]=" .. me.serialize(v) .. ",\n"
            end
        end
        lua = lua .. "}"
    elseif t == "nil" then
        return nil
    else
        error("can not serialize a " .. t .. " type.")
    end
    return lua
end
-- 转换成table
me.unserialize = function(lua)
    local t = type(lua)
    if t == "nil" or lua == "" then
        return nil
    elseif t == "number" or t == "string" or t == "boolean" then
        lua = tostring(lua)
    else
        error("can not unserialize a " .. t .. " type.")
    end
    lua = "return " .. lua
    local func = loadstring(lua)
    if func == nil then
        return nil
    end
    return func()
end
-- 去掉table中为nil的
function me.tablefilter(data)
    if data == nil then
        print("core.print data is nil");
    end
    if (type(data) == "table") then
        local num = 0
        local dkey = { }
        for k, v in pairs(data) do
            if (type(v) == "table") then
                me.tablefilter(v);
            elseif v == "nil" then

                print(k .. "-value = nil")

                -- table.remove(data,k+num)
                if type(k) == "number" then
                    table.insert(dkey, k + num)
                    num = num - 1
                    print("num = ", num)
                else
                    print("del v")
                    data[k] = nil
                end
            elseif v == "" then
                print(k .. "-value = nil")

                -- table.remove(data,k+num)
                if type(k) == "number" then
                    table.insert(dkey, k + num)
                    num = num - 1
                    print("num = ", num)
                else
                    print("del v")
                    data[k] = nil
                end
            end
        end
        for key, var in pairs(dkey) do
            table.remove(data, var)
        end
        -- LogTable(data)
    end
    return data
end
-- 加载json配置文件
me.parserJson = function(jsonfile)
    print("load " .. jsonfile)
    local str = me.Helper:readjson(jsonfile)
    return me.cjson.decode(str)
    -- return me.tablefilter(me.cjson.decode(str))
end
me.formartSecTime = function(sec)
    sec = me.toNum(sec)
    sec = math.max(sec, 0)
    if sec == 0 then
        return "00:00:00"
    end
    local day = math.floor(sec /(60 * 60 * 24))
    local hour = math.floor((sec %(60 * 60 * 24)) /(60 * 60))
    local min = math.floor((sec %(60 * 60)) / 60)
    local sec_ = math.floor(sec % 60)
    if hour < 10 then
        hour = "0" .. hour
    end
    if min < 10 then
        min = "0" .. min
    end
    if sec_ < 10 then
        sec_ = "0" .. sec_
    end
    if day > 0 then
        day = day .. "d"
    else
        day = ""
    end
    return day .. " " .. hour .. ":" .. min .. ":" .. sec_
end
me.formartSecTimeHour = function(sec)
    sec = me.toNum(sec)
    sec = math.max(sec, 0)
    if sec == 0 then
        return "00:00:00"
    end
    local day = math.floor(sec /(60 * 60 * 24))
    local hour = math.floor((sec %(60 * 60 * 24)) /(60 * 60))
    local min = math.floor((sec %(60 * 60)) / 60)
    local sec_ = math.floor(sec % 60)
    
    if min < 10 then
        min = "0" .. min
    end
    if sec_ < 10 then
        sec_ = "0" .. sec_
    end
    if day > 0 then         
        hour = hour + day*24
    end
    if hour < 10 then
        hour = "0" .. hour
    end
    return  hour .. ":" .. min .. ":" .. sec_
end
me.formartServerTime = function(sec)
    local tsec = me.toNum(sec)
    local pTab = os.date("*t", tsec)
    local hour = pTab.hour
    local min = pTab.min
    local sec_ = pTab.sec
    if hour < 10 then
        hour = "0" .. hour
    end
    if min < 10 then
        min = "0" .. min
    end
    if sec_ < 10 then
        sec_ = "0" .. sec_
    end
    return hour .. ":" .. min .. ":" .. sec_
end
-- 返回 时:分
me.formartServerTime2 = function(sec)
    local tsec = me.toNum(sec)
    local pTab = os.date("*t", tsec)
    local hour = pTab.hour
    local min = pTab.min
    local sec_ = pTab.sec
    if hour < 10 then
        hour = "0" .. hour
    end
    if min < 10 then
        min = "0" .. min
    end
    if sec_ < 10 then
        sec_ = "0" .. sec_
    end
    return hour .. ":" .. min
end
-- 返回国库记录的时间
me.GetSecTime_Foundation = function (sec)
    sec = me.toNum(sec)
    local pTab = os.date("*t", sec)
    local year = pTab.year
    local month = pTab.month
    local day = pTab.day
    local hour = pTab.hour
    local min = pTab.min
    local sec_ = pTab.sec
    if month < 10 then
        month = "0" .. month
    end
    if day < 10 then
        day = "0" .. day
    end
    if hour < 10 then
        hour = "0" .. hour
    end
    if min < 10 then
        min = "0" .. min
    end
    if sec_ < 10 then
        sec_ = "0" .. sec_
    end
    return year .. "-" .. month .. "-" .. day , hour .. ":" .. min .. ":" .. sec_
end
-- 返回时间日期 格式 2015-12-12 10:21:22
me.GetSecTime = function(sec, pType)
    if pType ~= nil then
        sec = me.toNum(sec)
    else
        sec = me.toNum(sec / 1000)
    end
    local pTab = os.date("*t", sec)
    local year = pTab.year
    local month = pTab.month
    local day = pTab.day
    local hour = pTab.hour
    local min = pTab.min
    local sec_ = pTab.sec
    if month < 10 then
        month = "0" .. month
    end
    if day < 10 then
        day = "0" .. day
    end
    if hour < 10 then
        hour = "0" .. hour
    end
    if min < 10 then
        min = "0" .. min
    end
    if sec_ < 10 then
        sec_ = "0" .. sec_
    end

    return year .. "-" .. month .. "-" .. day .. " " .. hour .. ":" .. min .. ":" .. sec_
end 

-- 返回时间日期 格式 2015-12-12 10:21:22
me.GetSecRankTime = function(sec, pType)
    if pType ~= nil then
        sec = me.toNum(sec)
    else
        sec = me.toNum(sec / 1000)
    end
    local pTab = os.date("*t", sec)
    local year = pTab.year
    local month = pTab.month
    local day = pTab.day
    local hour = pTab.hour
    local min = pTab.min
    local sec_ = pTab.sec
    if month < 10 then
        month = "0" .. month
    end
    if day < 10 then
        day = "0" .. day
    end
    if hour < 10 then
        hour = "0" .. hour
    end
    if min < 10 then
        min = "0" .. min
    end
    if sec_ < 10 then
        sec_ = "0" .. sec_
    end

    return year .. "-" .. month .. "-" .. day
end 
-- 返回时间日期 格式 2015年12月12日 10:21:22
--noYear：不显示年， 返回格式 12月12日 10:21:22
me.GetInSecTime = function(sec, noYear)
    sec = me.toNum(sec)
    local pTab = os.date("*t", sec)
    local year = pTab.year
    local month = pTab.month
    local day = pTab.day
    local hour = pTab.hour
    local min = pTab.min
    local sec_ = pTab.sec
    if month < 10 then
        month = "0" .. month
    end
    if day < 10 then
        day = "0" .. day
    end
    if hour < 10 then
        hour = "0" .. hour
    end
    if min < 10 then
        min = "0" .. min
    end
    if sec_ < 10 then
        sec_ = "0" .. sec_
    end
    if noYear then
        return month .. "月" .. day .. "日" .. hour .. ":" .. min .. ":" .. sec_
    end
    return year .. "年" .. month .. "月" .. day .. "日   " .. hour .. ":" .. min .. ":" .. sec_
end
local seed = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', 'a', 'b', 'c', 'c', 'd', 'e', 'f' }
function me.guid()
    local tb = { }
    for i = 1, 32 do
        table.insert(tb, seed[math.random(1, 16)])
    end
    local sid = table.concat(tb)
    return string.format("%s-%s-%s-%s-%s"
    , string.sub(sid, 1, 8)
    , string.sub(sid, 9, 12)
    , string.sub(sid, 13, 16)
    , string.sub(sid, 17, 20)
    , string.sub(sid, 21, 32)
    )
end
function me.setSafeAnchor(node, anchorX, anchorY)
    local diffX = anchorX * node:getContentSize().width *(node:getScaleX() -1)
    local diffY = anchorY * node:getContentSize().height *(node:getScaleY() -1)

    node:setAnchorPoint(anchorX, anchorY)
    node:setPositionX(node:getPositionX() + diffX)
    node:setPositionY(node:getPositionY() + diffY)
end
_mTimers = { }
mTimer = class("mTimer")
mTimer.__index = mTimer
function mTimer:ctor(t, callfunc, d)
    self.time = t
    self.curtime = 0
    self.startTime = me.sysTime()
    self.looptime = self.startTime
    local function timeUpdate(dt)
        self.looptime = me.sysTime()
        local xtime =(self.looptime - self.startTime) / 1000
        self.startTime = me.sysTime()
        if xtime > dt + 1 then
            dt = xtime
        end
        if self.time == -1 then
            callfunc(dt)
            return
        end
        if self.curtime + dt < self.time then
            self.curtime = self.curtime + dt
            callfunc(dt, false)
        else
            self.curtime = self.time
            callfunc(dt, true)
            if self.schId then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schId)
            end
            self.schId = nil
            self = nil
        end
    end
    self.schId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(timeUpdate, d, false)
end
me.fixFontWidth = function(node, w)
    while node:getContentSize().width > w do
        node:setFontSize(node:getFontSize() -1)
    end
end
function mTimer:clear()
    if self.schId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schId)
        self.schId = nil
        self = nil
    end
end
-- 删除指定的某个timer
me.clearTimer = function(mt)
    if mt then
        mt:clear()
        -- mt = nil
    end
end
me.clearAllTimer = function()
    for key, var in pairs(_mTimers) do
        me.clearTimersBygName(key)
    end
end
-- gName为timer 的组关键字 可以删除该名字的所有timer
me.clearTimersBygName = function(gName)
    if gName then
        if _mTimers[gName] then
            for key, var in pairs(_mTimers[gName]) do
                var:clear()
            end
        end
    end
end

-- time 为-1的话就是一直循环 为大于0的话就是循环time的时间
-- callback 为每循环一次的回调
-- d 为每次循环的间隔
-- gName为timer 的组关键字 可以删除该名字的所有timer
me.registTimer = function(time, callback, d, gName)
    local guid = me.guid()
    if gName then
        if _mTimers[gName] == nil then
            _mTimers[gName] = { }
        end
        _mTimers[gName][guid] = mTimer.new(time, callback, d or 0)
        return _mTimers[gName][guid]
    else
        if _mTimers["system_timer"] == nil then
            _mTimers["system_timer"] = { }
        end
        _mTimers["system_timer"][guid] = mTimer.new(time, callback, d or 0)
        return _mTimers["system_timer"][guid]
    end
end
-- 获取随机数
function me.rand()
    return me.Helper:getRand() + me.getRandom(me.sysTime())
end
--
function me.pairs(t)
    local a = { }
    for n in pairs(t) do
        a[#a + 1] = n
    end
    table.sort(a)
    -- orderByBubbling(a)
    local i = 0
    return function()
        i = i + 1
        return a[i], t[a[i]]
    end
end
-----圆轨迹
-- cp 圆心
-- r 半径
--- a 角度
function me.circular(cp, r, a)
    local p = { }
    p.x = cp.x + r * math.cos(a * math.pi / 180)
    p.y = cp.y + r * math.sin(a * math.pi / 180)
    return p
end
function me.oval(cp, rx, ry, a)
    local p = { }
    p.x = cp.x + rx * math.cos(a * math.pi / 180)
    p.y = cp.y + ry * math.sin(a * math.pi / 180)
    return p
end

-- 传入起始点，和终点的坐标，返回两点连线与x轴的夹角度数 顺时针
function me.getAngleWith2Pos(starPos, endPos)
    local p = cc.pSub(endPos, starPos)
    local r = math.atan2(p.x, p.y) * 180 / math.pi + 270
    return r
end
-- 逆时针
function me.getAngle(p1, p2)
    local p = cc.pSub(p2, p1)
    local r = math.atan2(p.x, p.y) * 180 / math.pi + 270
    print(r)
    return 360 - r
end  

-- 垂直
function me.getAngle90(p1, p2)
    local o = p1.x - p2.x
    local a = p1.y - p2.y
    local at = math.atan(o / a) / math.pi * 180.0

    if a < 0 then
        if o < 0 then
            at = 180 + math.abs(at)
        else
            at = 180 - math.abs(at)
        end
    end

    return at
end
function me.randInRect(center, width, height)
    return cc.p(center.x + me.rand() % width - width / 2, center.y + me.rand() % height - height / 2)
end
-- 定长
function me.randInCircle2(center, r)
    return me.circular(center, r, me.rand() % 360)
end
-- 不定长
function me.randInCircle(center, r)
    return me.circular(center, me.rand() % r, me.rand() % 360)
end
function me.clickAni(node)
    if node then

        --    local a1 = cc.ScaleTo:create(0.2, 1 + 0.03)
        --    local a2 = cc.ScaleTo:create(0.2, 1)
        --    node:runAction(cc.Sequence:create(a1, a2))
        -- me.Helper:grayImageView(node)
        node:stopAllActions()
        node:setColor(cc.c3b(255, 255, 255))
        local a1 = cc.TintBy:create(0.7, -100, -100, -100)
        local a2 = a1:reverse()
        local a3 = cc.Sequence:create(a1, a2)
        local a4 = cc.RepeatForever:create(a3)
        node:runAction(a4)

    end
end
function me.clickAni_(node, callf)
    if node then
        node:stopAllActions()
        node:setColor(cc.c3b(255, 255, 255))
        local a1 = cc.TintBy:create(2, -166, -126, -213)
        local a2 = a1:reverse()
        local a3 = cc.Sequence:create(a1, a2)
        local a4 = cc.Repeat:create(a3, 3)
        local a5 = cc.CallFunc:create(callf)
        node:runAction(cc.Sequence:create(a4, a5))
    end
end
function  me.clickAni4 (node)
    if node then
        node:stopAllActions()        
        local a1 = cc.ScaleTo:create(0.2,1,0.90)        
        local a3 = cc.ScaleTo:create(0.11  ,1.0,1.10)          
        local a5 = cc.ScaleTo:create(0.2,1.0,1.0)           
        node:runAction(cc.Sequence:create(a1,a3,a5))
    end
end
function  me.clickAni5 (node)
    if node then
        node:stopAllActions()        
        local a1 = cc.ScaleTo:create(0.2,0.95,0.95)        
        local a3 = cc.ScaleTo:create(0.11  ,1.05,1.05)          
        local a5 = cc.ScaleTo:create(0.2,1.0,1.0)     
        node:runAction(cc.Sequence:create(a1,a3,a5))
    end
end
function  me.clickAni6 (node)
    if node then
        node:stopAllActions()  
        local scale = node:getScale()      
        local a1 = cc.ScaleTo:create(0.2,scale - 0.05 ,scale - 0.05 )        
        local a3 = cc.ScaleTo:create(0.11  ,scale + 0.05, scale + 0.05)          
        local a5 = cc.ScaleTo:create(0.2,scale,scale)     
        node:runAction(cc.Sequence:create(a1,a3,a5))
    end
end
function me.tableClear(table_)
    if table_ then
        for key, var in pairs(table_) do
            table_[key] = nil
        end
    end
    table_ = nil
end

-- 一个数的取整
function me.getIntNum(num)
    local intNum = math.ceil(num)
    if intNum > num then
        intNum = intNum - 1
    end
    return intNum
end
-- 转换行列坐标为世界坐标 返回的是该tiled的中心点
function me.convertToScreenCoord(map, p)
    local mapSize = map:getMapSize()
    local tileSize = map:getTileSize()
    local tileWidth = map:boundingBox().width / mapSize.width
    local tileHeight = map:boundingBox().height / mapSize.height
    local v1 =(p.x + mapSize.width / 2 - mapSize.height) * tileWidth * tileHeight
    local v2 =(- p.y + mapSize.width / 2 + mapSize.height) * tileWidth * tileHeight
    local px =(v1 + v2) / 2 / tileHeight
    local py =(v2 - v1) / 2 / tileWidth
    return cc.p(math.floor(px), math.floor(py - tileHeight / 2))
end
-- 转换触摸坐标为地图行列坐标
function me.convertToTiledCoord(map, p)
    local pos = cc.pSub(p, cc.p(map:getPositionX(), map:getPositionY()))
    local halfMapWidth = map:getMapSize().width * 0.5
    local mapHeight = map:getMapSize().height
    local tileWidth = map:getTileSize().width
    local tileHeight = map:getTileSize().height
    local tilePosDiv = cc.p(pos.x / tileWidth, pos.y / tileHeight)
    local inverseTileY = mapHeight - tilePosDiv.y
    local posX = math.floor(inverseTileY + tilePosDiv.x - halfMapWidth)
    local posY = math.floor(inverseTileY - tilePosDiv.x + halfMapWidth)
    posX = math.max(0, posX);
    posX = math.min(map:getMapSize().width - 1, posX);
    posY = math.max(0, posY);
    posY = math.min(map:getMapSize().height - 1, posY);
    return cc.p(posX, posY)
end
-- 世界坐标转换为地块坐标
function me.converScreenToTiledCoord(map, p)
    local pos = p
    local halfMapWidth = map:getMapSize().width * 0.5
    local mapHeight = map:getMapSize().height
    local tileWidth = map:getTileSize().width
    local tileHeight = map:getTileSize().height
    local tilePosDiv = cc.p(pos.x / tileWidth, pos.y / tileHeight)
    local inverseTileY = mapHeight - tilePosDiv.y
    local posX = math.floor(inverseTileY + tilePosDiv.x - halfMapWidth)
    local posY = math.floor(inverseTileY - tilePosDiv.x + halfMapWidth)
    return cc.p(posX, posY)
end
function me.isInMap(map, mp)
    local p = cc.p(me.winSize.width / 2, me.winSize.height / 2)
    local pos = cc.pSub(p, mp)
    local halfMapWidth = map:getMapSize().width * 0.5
    local mapHeight = map:getMapSize().height
    local tileWidth = map:getTileSize().width
    local tileHeight = map:getTileSize().height
    local tilePosDiv = cc.p(pos.x / tileWidth, pos.y / tileHeight)
    local inverseTileY = mapHeight - tilePosDiv.y
    local posX = math.floor(inverseTileY + tilePosDiv.x - halfMapWidth)
    local posY = math.floor(inverseTileY - tilePosDiv.x + halfMapWidth)
    if posX < 1 or posY < 1 or posX > map:getMapSize().width - 1 or posY > map:getMapSize().height - 1 then
        return false
    end
    return true
end
function me.centerTileMapOnTileCoord(map, p)
    local centerScreen = cc.p(me.winSize.width * 0.5, me.winSize.height * 0.5)
    local layer = map:getLayer("floor")
    p.y = p.y - 1
    local scrollPosition = layer:getPositionAt(p)
    scrollPosition = cc.pMul(scrollPosition, -1)
    scrollPosition = cc.pAdd(scrollPosition, centerScreen)
    local move = cc.MoveTo:create(0.2, scrollPosition)
    map:stopAllActions()
    map:runAction(move)
end
-- 根据地图行列坐标获取tiled
function me.getTiledByTileCoord(map, p)
    local layer = map:getLayer("floor")
    return layer:getTileAt(p)
end
function me.getScreenCenterTileCrood(map)
    local cp = cc.p(me.winSize.width / 2, me.winSize.height / 2)
    return me.convertToTiledCoord(map, cp)
end
function me.getNearTiles(map, center)
    local nearX = 50
    local nearY = 50
    local px = center.x - nearX
    local py = center.y - nearY
    px = math.min(0, px)
    py = math.min(0, py)
    local ex = center.x + nearX
    local ey = center.y + nearY
    ex = math.min(map:getMapSize().width - 1, ex);
    ey = math.min(map:getMapSize().height - 1, ey);
    return cc.p(px, py), cc.p(ex, ey)
end
function me.getFortIdByCoord(c)
    return c.x * 10000 + c.y
end
function me.getCoordByFortId(id)
    return cc.p(math.floor(id / 10000), id % 10000)
end
-- 获取
function me.getIdByCoord(c)
    local mapwidth = getWorldMapHeight()
    -- 地图宽的tile数
    return c.x + c.y * mapwidth
end
function me.converCoordbyId(id)
    local mapwidth = getWorldMapWidth()
    -- 地图宽的tile数
    return cc.p(id % mapwidth, math.floor(id / mapwidth))
end
function me.converDualId(c1, c2)
    local id1 = me.getIdByCoord(c1)
    local id2 = me.getIdByCoord(c2)
    local cp = cc.p(math.min(id1, id2), math.max(id1, id2))
    local idw = 10000000
    return cp.x + cp.y * idw
end
function me.converDualCrood(id)
    local idw = 10000000
    local id1 = id % idw
    local id2 = math.floor(id / idw)
    local c1 = me.converCoordbyId(id1)
    local c2 = me.converCoordbyId(id2)
    return c1, c2
end
function me.isFar(center, p)
    local far = 100
    return cc.pDistanceSQ(center, p) >(far * far)
end
function me.blink(node)
    local a1 = cc.FadeIn:create(0.7)
    local a2 = cc.FadeOut:create(0.7)
    local a3 = cc.Sequence:create(a1, a2)
    local a4 = cc.RepeatForever:create(a3)
    node:runAction(a4)
end
function me.CCOrbitCamera(node)
    local delay1 = cc.DelayTime:create((me.getRandom(200) + me.rand() + me.rand()) % 10)
    local action = CCOrbitCamera:create(2, 1, 0, 0, 180, 0, 0)
    local delay = cc.DelayTime:create((me.getRandom(10000) + me.rand() + me.rand()) % 10)
    local seq = cc.Sequence:create(delay1, action, delay)
    local ret = cc.RepeatForever:create(seq)
    node:runAction(ret)
end
-- 图片变灰
function me.graySprite(sprite_, vs, fs)
    if sprite_ == nil then
        return
    end

    vs = vs or "vs"
    fs = fs or "fs_gray"

    local function setUniform(node, table_)
        if table_ then
            for i = 1, #table_, 2 do
                local location = gl.getUniformLocation(prog:getProgram(), table_[i])
                if tolua.type(table_[i + 1]) == "cc.Texture2D" then
                    gl.activeTexture(gl.TEXTURE0 + table_[i])
                    gl.bindTexture(gl.TEXTURE_2D, table_[i + 1]:getName())
                    gl.activeTexture(gl.TEXTURE0)
                else
                    gl.uniform1f(location, table_[i + 1])
                end
            end
        end
    end

    local function setProgramWithVF(node, vpath, fpath, table_, upFunc)
        local cache = cc.GLProgramCache:getInstance()
        local cacheKey = vpath .. fpath
        local prog = cache:getGLProgram(cacheKey)
        if nil == prog then
            prog = cc.GLProgram:createWithByteArrays(require("res." .. vpath), require("res." .. fpath))
            prog:setUniformsForBuiltins()

            setUniform(node, table_)
            cache:addGLProgram(prog, cacheKey)
        end
        node:setGLProgram(prog)
        if upFunc then
            return node:schedule( function()
                node:getGLProgram():use()
                local table_ = upFunc()
                setUniform(node, table_)
            end , 0)
        end
    end
    setProgramWithVF(sprite_, vs, fs)
end   
-- 图片恢复原来样子
function me.revokeSprite(sprite_)
    if sprite_ == nil then
        return
    end
    local cache = cc.GLProgramCache:getInstance()
    local prog = cache:getGLProgram("ShaderPositionTextureColor_noMVP")
    sprite_:setGLProgram(prog)
end
function me.alliancedegree(pDegree)
    local pDegreeStr = ""
    if pDegree == 1 then
        pDegreeStr = "盟主"
    elseif pDegree == 2 then
        pDegreeStr = "副盟主"
    elseif pDegree == 3 then
        pDegreeStr = "官员"
    elseif pDegree == 4 then
        pDegreeStr = "成员"
    end
    return pDegreeStr
end
function me.GoodsSpecific(pNode, pIcon, pNum)
    local globalItems = me.createNode("Node_rewards_bg.csb")
    print("GoodsSpecific", pNode, pIcon, pNum)
    local pCell = me.assignWidget(globalItems, "rewards_bg"):clone():setVisible(true)

    local function arrive(node)
        node:removeFromParentAndCleanup(true)
    end

    -- local pRewards = me.assignWidget(pCell,"rewards_bg"):clone():setVisible(true)
    pCell:setPosition(cc.p(pNode:getContentSize().width / 2, pNode:getContentSize().height / 2))
    pNode:addChild(pCell)


    local pRewardsIcon = me.assignWidget(pCell, "rewards_icon")
    pRewardsIcon:loadTexture(pIcon, me.localType)
    local pRewardsNum = me.assignWidget(pCell, "rewards_num")
    pRewardsNum:setString("×" .. pNum)


    local pMoveBy = cc.MoveBy:create(0.8, cc.p(0, 90))
    local pFadeOut = cc.FadeOut:create(0.8)
    local pFadeOut1 = cc.FadeOut:create(0.8)
    local pFadeOut2 = cc.FadeOut:create(0.8)
    local pSpawn = cc.Spawn:create(pMoveBy, pFadeOut)

    local callback = cc.CallFunc:create(arrive)
    pRewardsIcon:runAction(pFadeOut1)
    pRewardsNum:runAction(pFadeOut2)
    pCell:runAction(cc.Sequence:create(pSpawn, callback))
end

function showWaitLayerWithOutAni()
end
waitTAG = 1231332
function showWaitLayer(bhttp)
    local scene = me.runningScene()
    if scene then
        local wait = scene:getChildByTag(waitTAG)
        if wait == nil then
            wait = waitLayer:create("netLoadingLayer.csb")
            wait:setTag(waitTAG)
            scene:addChild(wait, me.MAXZORDER + me.MAXZORDER)
        else
            wait:setVisible(true)
        end
        wait:hideAni(false)
        if bhttp then
            wait.bhttp = true
        else
            wait.bhttp = false
        end
    end
end
function disWaitLayer(bhttp) 
    local scene = me.runningScene()
    if scene then
        local wait = scene:getChildByTag(waitTAG)
        if wait then
            if bhttp then
                if wait.bhttp then
                    wait:setVisible(false)
                end
            else
                if not wait.bhttp then
                    wait:setVisible(false)
                end
            end
        end
    end
end
function getStringmRichSub(str)
    local pTab =me.split(str,"&")
    local pStr = ""
    for key, var in pairs(pTab) do
        var = var.."&"
        if string.find(var,">") then
           artPos, endPos, head, color, bodyText = string.find(var, "<(%w-),(%x-)>(.-)&")
        end    
        pStr = pStr ..bodyText
    end
    return pStr
end
function getStringCnLength(str)
    local cnLen = 0
    -- 中文按照2个字节长度
    
    local function isASCII_Code(i)
       if i > 127 then
            return true
       end
        return false
    end
    for i = 1, string.len(str) do            
        if string.byte(str, i) and isASCII_Code(string.byte(str, i)) then
            cnLen = cnLen + 1
        end
    end
    return cnLen
end
-- 判断字符长度
function getStringLength(str)
    local enLen = 1
    -- 英文按照1个字节长度
    local cnLen = 2
    -- 中文按照2个字节长度
    local cnNum = 0
    -- 中文数
    local enNum = 0
    -- 英文数
    local function isASCII_Code(i)
        if i >= 0 and i <= 127 then
            return true
        end
        return false
    end
    for i = 1, string.len(str) do
        if string.byte(str, i) and isASCII_Code(string.byte(str, i)) then
            enNum = enNum + 1
        elseif string.byte(str, i) then
            cnNum = cnNum + 1
        end
    end
    cnNum = math.floor(cnNum / 3)
    local totalLen = enNum * enLen + cnNum * cnLen
    return totalLen
end

function utf8sub(str, startChar, numChars)
    local function chsize(char)
        if not char then
            print("not char")
            return 0
        elseif char > 240 then
            return 4
        elseif char > 225 then
            return 3
        elseif char > 192 then
            return 2
        else
            return 1
        end
    end

    local startIndex = 1
    while startChar > 1 do
        local char = string.byte(str, startIndex)
        startIndex = startIndex + chsize(char)
        startChar = startChar - 1
    end
 
    local currentIndex = startIndex
 
    while numChars > 0 and currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + chsize(char)
        numChars = numChars -1
    end
    return str:sub(startIndex, currentIndex - 1)
end

-- 图片缩放
function me.resizeImage(img, w, h)
    img:ignoreContentAdaptWithSize(true)
    local sw = w / img:getContentSize().width
    local sh = h / img:getContentSize().height
    local fix = math.min(sw, sh) 
    if fix < 1 then
        img:ignoreContentAdaptWithSize(false)
        img:setContentSize(cc.size(img:getContentSize().width * fix, img:getContentSize().height * fix))
    end
end

-- ****************************************  http通信协议  ************************************************************
function me.getHttpString(url, callFunc, errorCallFunc, jsonDecode)
    print("http url = " .. url)
    local XMLHttp = cc.XMLHttpRequest:new()
    local httpTimer = nil
    local curHttpTime = 0
    local bshowWait = false
    XMLHttp.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    XMLHttp:open("GET", url)
    local function onReadyStateChange()
        print("XMLHttp.readyState = " .. XMLHttp.readyState)
        if XMLHttp.readyState == cc.XMLHTTPREQUEST_RESPONSE_JSON and(XMLHttp.status >= 200 and XMLHttp.status < 207) then
            -- 移除蒙板
            disWaitLayer(true)
            me.clearTimer(httpTimer)
            local response = nil
            if XMLHttp.response then
                response = XMLHttp.response
                if jsonDecode then
                    response = me.cjson.decode(XMLHttp.response)
                end
                dump(response)
                callFunc(response)
            end
        else
            disWaitLayer(true)
            if errorCallFunc then errorCallFunc() end
        end
    end
    XMLHttp:registerScriptHandler(onReadyStateChange)
    XMLHttp:send()
    -- 加通信蒙板
    curHttpTime = me.sysTime()
    httpTimer = me.registTimer(40, function(dt)
        if bshowWait then
            if me.sysTime() - curHttpTime > 30000 then
                disWaitLayer(true)
                curHttpTime = 0
                me.clearTimer(httpTimer)
                showTips("请求超时!")
                if errorCallFunc then errorCallFunc() end
                bshowWait = false
            end
        else
            if curHttpTime > 0 then
                if me.sysTime() - curHttpTime > 100 then
                    showWaitLayer(true)
                    curHttpTime = me.sysTime()
                    bshowWait = true
                end
            end
        end
    end , 0)
end 
function me.getHttpFile(url, callFunc, errorCallFunc, saveName)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("GET", url)
    print("http file "..url)
    local function onDownloadImage()
        print("xhr.readyState is:", xhr.readyState, "xhr.status is: ", xhr.status)
        if xhr.readyState == 4 and(xhr.status >= 200 and xhr.status < 207) then
            local fileData = xhr.response
            print(saveName)
            local f = io.open(saveName, "wb")
            f:write(fileData)
            f:close()
            if callFunc then callFunc(saveName) end
        else
            if errorCallFunc then errorCallFunc() end
        end
    end
    xhr:registerScriptHandler(onDownloadImage)
    xhr:send()
end
-- ****************************************  http通信协议  ************************************************************

function me.isTargetPlatform_IOS()
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or(cc.PLATFORM_OS_IPAD == targetPlatform) or(cc.PLATFORM_OS_MAC == targetPlatform) or(cc.PLATFORM_OS_WINDOWS == targetPlatform) then
        return true
    end
    return false
end
function me.setSpriteTexture(spr, png)
    local f = cc.SpriteFrameCache:getInstance():getSpriteFrameByName(png)
    if f then
        spr:setSpriteFrame(png)
    else
        spr:setTexture(png)
    end
end
function me.createSprite(png)
    local sp = nil
    local f = cc.SpriteFrameCache:getInstance():getSpriteFrameByName(png)
    if (f) then
        sp = cc.Sprite:createWithSpriteFrameName(png)
    else
        local b = cc.FileUtils:getInstance():isFileExist(png)
        if b then
            sp = cc.Sprite:create(png)
        end
    end
    return sp
end


---
-- 根据品质取颜色
-- 
--
function me.getColorByQuality(quality)
    if quality==1 then
        return cc.c3b(163, 163, 163), "#A3A3A3"
    elseif quality==2 then
        return cc.c3b(111, 212, 71),"#6FD447"
    elseif quality==3 then
        return cc.c3b(61, 191, 224),"#3DBFE0"
    elseif quality==4 then
        return cc.c3b(233, 53, 206),"#E935CE"
    elseif quality==5 then
        return cc.c3b(250, 211, 26),"#FAD31A"
    elseif quality==6 then
        return cc.c3b(255, 0, 0),"#FF0000"
    else
        return cc.c3b(163, 163, 163), "#A3A3A3"
    end
end
function me.getColorByQuality2(quality)
    if quality==1 then
        return "A3A3A3"
    elseif quality==2 then
        return "6FD447"
    elseif quality==3 then
        return "3DBFE0"
    elseif quality==4 then
        return "E935CE"
    elseif quality==5 then
        return  "FAD31A"
    elseif quality==6 then
        return "FF0000"
    else
        return  "A3A3A3"
    end
end
---
-- 多参数替换
--
function me.strReplace(input, delimiter, args)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return input end
    local pos,count,arr = 0, 1,{}
    -- for each divider found
    for st,sp in function() return string.find(input, delimiter, pos, false) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        table.insert(arr, args[count])
        pos = sp + 1
        count=count+1
    end
    if pos==0 then
        table.insert(arr, input)
    else
        table.insert(arr, string.sub(input, pos))
    end
    return table.concat(arr,"")
end