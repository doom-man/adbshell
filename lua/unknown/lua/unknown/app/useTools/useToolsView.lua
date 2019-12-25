useToolsView = class("useToolsView ", function(csb)
    return cc.CSLoader:createNode(csb)
end )
useToolsView._index = useToolsView

function useToolsView:create(csb)
    local layer = useToolsView.new(csb)
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                end
            end )
            return layer
        end
    end
    return nil
end

function useToolsView:ctor()
    self.cellViews = {}
    self.curData = nil
    self.bid = nil
    self.toolsType = nil
    self.cellWidth = 0
    self.time = nil
    self.maxTime = nil
    self.timer = nil 
end

function useToolsView:init()
    self.ScrollView_conent = me.assignWidget(self, "ScrollView_conent")
    self.Text_workNum = me.assignWidget(self, "Text_workNum")
    self.Button_use = me.assignWidget(self, "Button_use")
    self.Text_time_decr = me.assignWidget(self, "Text_time_decr")
    self.Slider_worker = me.assignWidget(self, "Slider_worker")
    self.Button_leftGo = me.assignWidget(self, "Button_leftGo")
    self.Button_rightGo = me.assignWidget(self, "Button_rightGo")
    self.LoadingBar_process = me.assignWidget(self, "LoadingBar_process")
    self.Text_process =  me.assignWidget(self, "Text_process")
    self.Image_Process = me.assignWidget(self, "Image_Process")
    self.fastTimeTxt = me.assignWidget(self, "fastTimeTxt")
    self.txt2 = me.assignWidget(self, "txt2")

    -- 注册点击事件
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    me.registGuiClickEventByName(self, "Button_use", function(node)
        self:btnUseOnClicked()
    end )
    me.registGuiClickEventByName(self, "btn_reduce", function(node)
        self:btnGoOnClicked(1)
    end )
    me.registGuiClickEventByName(self, "btn_add", function(node)
        self:btnGoOnClicked(2)
    end )
    me.registGuiClickEventByName(self, "Button_leftGo", function(node)
        self:btnScrollOnClicked(1)
    end )
    me.registGuiClickEventByName(self, "Button_rightGo", function(node)
        self:btnScrollOnClicked(2)
    end )

    me.registGuiClickEventByName(self, "fastTimeBtn", function(node)
        if #self.useitemlist==0 then 
            showTips("没有加速道具")
            return
        end
        local tmpView = useToolsQuick:create("useToolsQuick.csb")
        me.runningScene():addChild(tmpView, me.MAXZORDER)
        me.showLayer(tmpView, "bg")

        local spareTime=nil
        if self.maxTime then
            spareTime = self.maxTime-self.time-self.relatedObj:getFreeTime()
        else
            spareTime = self.time-self.relatedObj:getFreeTime()
        end
        tmpView:setData(self:calc(1), self.relatedObj:getFreeTime(),spareTime, self.bid)
    end )

    self.curIndex=1
    
    --self.cthread = coroutine.create(function ()
    --        self:initCellViews()
    --end)
    --self.schid = me.coroStart(self.cthread)

    --监听滑动条信息
    local function sliderEvent(sender, eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            local percent = sender:getPercent() / 100
            local pUseNum = math.floor(percent*self.curData.count)
            self.Text_workNum:setString(pUseNum)
            local def = cfg[CfgType.ETC][me.toNum(self.curData.defid)]
            self.Text_time_decr:setString("加速时间："..me.formartSecTime(me.toNum(def.seeEffect*pUseNum)))
            me.buttonState(self.Button_use,me.toNum(pUseNum)>0)
        end
    end
    self.Slider_worker:addEventListener(sliderEvent)
    self.ScrollView_conent:setScrollBarEnabled(false)
    me.buttonState(self.Button_use,false)
    return true
end

function useToolsView:update(msg)
    if checkMsg(msg.t, MsgCode.CITY_BUILDING_FARMERCHANGE) or checkMsg(msg.t, MsgCode.CITY_P_SOLDIER_FINISH) then
        me.DelayRun(function()
            disWaitLayer()
            me.clearTimer(self.timer)
            if self.schid then
                me.Scheduler:unscheduleScriptEntry(self.schid)    
                self.schid = nil
            end

            if self.relatedObj==nil then
                if self.close then
                    self:close()
                end
                return
            end

            local time, maxTime = self.relatedObj:getAccelerateTime()
            local spareTime = time
            if maxTime then
                spareTime = maxTime-time
            end
            if spareTime==nil then
                spareTime=0
            end
            if self.relatedObj:getFreeTime()>=spareTime then
                self:close()
                return
            end

            --self.cthread = coroutine.create(function ()
            --        self:initCellViews()
            --end)
            --self.schid = me.coroStart(self.cthread)
            self:setTime(time,maxTime, 1)
        end, 0.1)
    end
end
function useToolsView:onEnter()
    print("useToolsView:onEnter()")
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end )
    me.doLayout(self,me.winSize)  
end

function useToolsView:onExit()
    print("useToolsView:onExit()")
    if self.schid then
        me.Scheduler:unscheduleScriptEntry(self.schid)    
        self.schid = nil
    end
    UserModel:removeLisener(self.modelkey)
end

function useToolsView:btnScrollOnClicked(status)
    local curIndex = self.curData.index
    if status == 1 then
        curIndex = curIndex-1
    elseif status == 2 then
        curIndex=curIndex+1
    end
    self:setToolsInfoByIndex(curIndex,true)
end

function useToolsView:setRelatedObj(obj)
    self.relatedObj = obj
end

function useToolsView:setTime(time_,maxTime_,from)
    self.time = time_
    self.maxTime = maxTime_

    --加载cell子控件
    self:initCellViews()

    self:setProcessInfo(0,from)
    self.timer = me.registTimer(-1,function ()
        self:setProcessInfo(1,1)
    end,1)


end

function useToolsView:showQuickTime(time, from)
    time=math.modf(time)
    if time%300==0 or from==nil then
        local totaltime = self:calc(0)
        self.fastTimeTxt:setString(me.formartSecTime(totaltime))
        self.txt2:setPositionX(self.fastTimeTxt:getPositionX()+self.fastTimeTxt:getContentSize().width+10)
    end
end

function useToolsView:setProcessInfo(reduceTime_,from)
    if self.time == nil and self.maxTime == nil then
        return
    end
    if self.maxTime then
        self.time = self.time+reduceTime_
        if self.time >= self.maxTime then
            self.time = self.maxTime
        end
        self.Text_process:setString(me.formartSecTime(self.maxTime-self.time))
        self.LoadingBar_process:setPercent(self.time/self.maxTime*100)
        self:showQuickTime(self.maxTime-self.time,from)
    else
        self.time = self.time-reduceTime_
        self.Text_process:setString(me.formartSecTime(self.time))
        self:showQuickTime(self.time,from)
    end
end
function useToolsView:btnGoOnClicked(status)
    local tmpNum = me.toNum(self.Text_workNum:getString())
    if status == 1 then
        if me.toNum(tmpNum) <= 0 then
            return
        else
          tmpNum = tmpNum - 1
        end
    elseif status == 2 then
        if me.toNum(tmpNum) >= me.toNum(self.curData.count) then
            return
        else
          tmpNum = tmpNum + 1
        end
    end
    self.Text_workNum:setString(tmpNum) 
    local def = cfg[CfgType.ETC][me.toNum(self.curData.defid)]
    self.Text_time_decr:setString("加速时间："..me.formartSecTime(me.toNum(def.seeEffect*tmpNum)))
    self.Slider_worker:setPercent(tmpNum / self.curData.count * 100)
    me.buttonState(self.Button_use,me.toNum(tmpNum)>0)
end

function useToolsView:btnUseOnClicked()
    local num = me.toNum(self.Text_workNum:getString())
    if num <= 0 then
        return  
    end
    if self.curData==nil then
        return
    end
    local def = cfg[CfgType.ETC][me.toNum(self.curData.defid)]
    local leftTime = self.time
    if self.maxTime then
        leftTime = self.maxTime-self.time
    end
    if (def.seeEffect*num - leftTime) >= 300 then --超过5分钟弹窗确认
        me.showMessageDialog("领主大人，加速时间远超剩余时间，是否继续使用？",function (args)
            if args == "ok" then                
                NetMan:send(_MSG.buildQuickItem(self.bid, self.curData.defid, num))
                showWaitLayer()
                --self:close()            
            end
        end)
    else --直接使用
        NetMan:send(_MSG.buildQuickItem(self.bid, self.curData.defid, num))
        showWaitLayer()
        --self:close()
    end        
end

function useToolsView:close()
    me.clearTimer(self.timer)
    self:removeFromParentAndCleanup(true)
end

--设置道具类型
function useToolsView:setToolsType(type_, bid_)
    self.bid = bid_
    self.toolsType = type_
end

--设置ScrollView偏移量
function useToolsView:moveScrollViewByIndex(index,needScroll_)
    local offX = 0
    if index <= 3 then
        offX = 0
    elseif index >= #self.cellViews then
        offX = -(#self.cellViews-3)*self.cellWidth
    else 
        offX = -(index-3)*self.cellWidth
    end
    if needScroll_ then
        self.ScrollView_conent:setInnerContainerPosition(cc.p(offX,0))
    end
    
    local curIndex = 0
    if index <= 1 then
        curIndex = 1
    elseif index >= #self.cellViews then
        curIndex = #self.cellViews
    else
        curIndex = index
    end
    self.curIndex=index
    if self.cellViews[me.toNum(curIndex)] then
        self.cellViews[me.toNum(curIndex)]:setLightStatus(true)
        local oldData = self.curData
        local percent = 100
        self.curData = self.cellViews[me.toNum(curIndex)]:getItemData()
        local showNums = self.curData.count
        if oldData and oldData.defid~=self.curData.defid then --切换了不同道具，不用记录便用数量
            oldData=nil
        end

        local def = cfg[CfgType.ETC][me.toNum(self.curData.defid)]
        if self.time then 
            local restTime = self.time
            if self.maxTime then
                restTime = self.maxTime - self.time
            end
            local needNum = math.ceil(restTime / me.toNum(def.seeEffect))
            if needNum<1 then needNum=1 end
            print(needNum)
            if me.toNum(self.curData.count) >= needNum then 
              self.curData.count = needNum 
            end
            if needNum>1 and self.curData.count*me.toNum(def.seeEffect)>restTime then
                showNums = self.curData.count-1
                percent = math.floor((showNums/self.curData.count)*100)
            else
                showNums = self.curData.count
            end
            local num = me.toNum(self.Text_workNum:getString())
            if oldData and num<showNums  then --恢复上一次的便用数量
                showNums=num
                percent = math.floor((showNums/self.curData.count)*100)
            end
        end         
        self.Text_workNum:setString(showNums)
        self.Text_time_decr:setString("加速时间："..me.formartSecTime(me.toNum(def.seeEffect*showNums)))       
        me.buttonState(self.Button_use,me.toNum(showNums)>0)
        self.Slider_worker:setPercent(percent)
    else
        __G__TRACKBACK__("get cellView is nil index = "..curIndex)
    end
end

--初始化滑条和当前工人数等数据
function useToolsView:setToolsInfoByIndex(index,needScroll_)
    for key, var in pairs(self.cellViews) do
        var:setLightStatus(false)
    end
    self:moveScrollViewByIndex(index,needScroll_)
end

function useToolsView:cellCallBack(index,needScroll_)
    self:setToolsInfoByIndex(index,needScroll_)
end

function useToolsView:initCellViews()
   if self.toolsType == nil then
        __G__TRACKBACK__("toolsType is nil !!!")
    end
    self.ScrollView_conent:removeAllChildren()
    self.cellViews={}
    local scrollW = 0
    local index = 1
    local tarPkg = getBackpackDatasByType(self.toolsType)
    self.useitemlist = tarPkg
    for key, var in ipairs(tarPkg) do
        local data = {}
        local tmpCell = useToolsCellView:create("useToolsItem.csb")
        data.count, data.defid, data.index = var["count"],var["defid"],index
        self.ScrollView_conent:addChild(tmpCell)
        self.cellViews[me.toNum(index)] = tmpCell
        tmpCell:setItemInfo(data)
        tmpCell:setBtnCallBack(function (index)
            self:cellCallBack(index,false)
        end)
        tmpCell:setAnchorPoint(cc.p(0,0))
        tmpCell:setPosition(cc.p(scrollW,0))
        scrollW = scrollW + tmpCell:getContentSize().width
        index = index + 1
        --coroutine.yield()
    end    
    if scrollW > self.ScrollView_conent:getContentSize().width then
        self.ScrollView_conent:setInnerContainerSize(cc.size(scrollW, self.ScrollView_conent:getContentSize().height))    
    end
    if self.curIndex>#self.cellViews then
        self.curData=nil
        self.curIndex=1
    elseif self.cellViews[me.toNum(self.curIndex)] and self.curData then
        local curData = self.cellViews[me.toNum(self.curIndex)]:getItemData()
        if self.curData.defid~=curData.defid then
            self.curData=nil
            self.curIndex=1
        end
    end
    if self.cellViews[self.curIndex] then
        self.cellWidth = self.cellViews[self.curIndex]:getContentSize().width
        self:setToolsInfoByIndex(self.curIndex)
    end    
end

function useToolsView:calc(mode)
    if #self.useitemlist==0 then
        if mode==0 then
            return 0
        else
            return {}
        end
    end
    local tmpList = { }
    for key, var in pairs(self.useitemlist) do
        local def = var:getDef()
        if me.toNum(def.useType) == USETYPE_ALL.key then

            --if tonumber(def.useEffect)==7200 then var.count=0 end  --测试使用
            --if tonumber(def.useEffect)==14400 then var.count=0 end  --测试使用

            if tmpList[def.useEffect] then
                table.insert(tmpList[def.useEffect],1,{data=var, count=var.count, useEffect=tonumber(def.useEffect)})
            else
                tmpList[def.useEffect]={{data=var, count=var.count, useEffect=tonumber(def.useEffect)}}
            end
        else
            --if tonumber(def.useEffect)<=7200 then  --测试使用
            --if tonumber(def.useEffect)==7200 then var.count=1 end  --测试使用
            --if tonumber(def.useEffect)==3600 then var.count=0 end  --测试使用
            --if tonumber(def.useEffect)==1800 then var.count=4 end  --测试使用
            --if tonumber(def.useEffect)==300 then var.count=200 end  --测试使用

            if tmpList[def.useEffect] then
                table.insert(tmpList[def.useEffect], {data=var, count=var.count, useEffect=tonumber(def.useEffect)})
            else
                tmpList[def.useEffect]={{data=var, count=var.count, useEffect=tonumber(def.useEffect)}}
            end

            --end
        end
    end

    local function comp(a, b)
        return a[1].useEffect < b[1].useEffect
    end
    tmpList=table.values(tmpList)
    table.sort(tmpList, comp)

    local useItemList={}
    for _, v in ipairs(tmpList) do
        for _, v1 in ipairs(v) do
            table.insert(useItemList, v1)
        end
    end
    tmpList=nil

    local freeTime=0
    if self.relatedObj then
        freeTime=self.relatedObj:getFreeTime()
    end
    local spareTime=nil
    if self.maxTime then
        spareTime = math.modf(self.maxTime-self.time-freeTime)
    else
        spareTime = math.modf(self.time-freeTime)
    end


    local srcSpareTime = spareTime
    local totalTime=0
    local overTime = 0
    local rs = {}
    local isFind=false
    local immediatelyBreak=false
    while true do
        if immediatelyBreak==true then break end
        if isFind==false then
            local len = #useItemList
            local minFlag=false
            while len>0 do
                local v = useItemList[len]
                local t=tonumber(v.useEffect)
                if t<=spareTime and v.count>0 then
                    local count=0
                    for i=1, v.count do
                        if t<=spareTime then
                            spareTime=spareTime-t
                            count=count+1
                        else
                            break
                        end
                    end
                    v.count=v.count-count
                    if v.count==0 then
                        table.remove(useItemList, len)
                    elseif t-spareTime<300 and spareTime>0 then  --小于5分钟
                        count=count+1
                        v.count=v.count-1
                        if v.count==0 then
                            table.remove(useItemList, len)
                        end
                        immediatelyBreak=true --提前完成查找
                        overTime=t-spareTime
                    elseif spareTime==0 then
                        immediatelyBreak=true --提前完成查找
                    end
                    
                    totalTime=totalTime+count*t

                    if rs[v.data.uid] then
                        rs[v.data.uid].useCount=rs[v.data.uid].useCount+count
                    else
                        v.useCount=count
                        rs[v.data.uid]=v
                    end
                    minFlag=true
                    if immediatelyBreak==true then
                        break
                    end
                elseif t-spareTime<300 and v.count>0 then  --小于5分钟
                    if rs[v.data.uid] then
                        rs[v.data.uid].useCount=rs[v.data.uid].useCount+1
                    else
                        v.useCount=1
                        rs[v.data.uid]=v
                    end
                    v.count=v.count-1
                    if v.count==0 then
                        table.remove(useItemList, len)
                    end

                    totalTime=totalTime+t
                    overTime=t-spareTime
                    print("剩余时间:"..overTime)
                    immediatelyBreak=true --提前完成查找
                    break
                end
                len=len-1
            end
            if minFlag==false then
                isFind=true
            end
        else
            for k, v in ipairs(useItemList) do
                local t=tonumber(v.useEffect)
                if t>=spareTime and v.count>0 then
                    overTime=t-spareTime
                    print("剩余时间:"..overTime)
                    if rs[v.data.uid] then
                        rs[v.data.uid].useCount=rs[v.data.uid].useCount+1
                    else
                        v.useCount=1
                        rs[v.data.uid]=v
                    end
                    totalTime=totalTime+t
                    v.count=v.count-1
                    if v.count==0 then
                        table.remove(useItemList, k)
                    end
                    break
                end
            end
            break
        end
    end

    if overTime>300 then  --优化  查找是否能去除多余的
        for k, v in pairs(rs) do
            for i=1, v.useCount do
                if totalTime-v.useEffect>srcSpareTime then
                    v.useCount=v.useCount-1
                    totalTime=totalTime-v.useEffect
                end
            end
            if v.useCount==0 then
                rs[k]=nil
            end
        end            
    end
    if mode==0 then
        return totalTime
    end
    --if 1==1 then return rs end
    local len = #useItemList
    while len>0 do
        local v = useItemList[len]
        local def = v.data:getDef()
        if me.toNum(def.useType) == USETYPE_ALL.key then
            table.remove(useItemList, len)
        end
        len=len-1
    end
    local function comp1(a, b)
        return a.useEffect < b.useEffect
    end
    table.sort(useItemList, comp1)


    local tmpRs={}
    for key, var in pairs(rs) do
        local def = var.data:getDef()
        if me.toNum(def.useType) == USETYPE_ALL.key then
            local has,r = self:replaceType(useItemList, var)
            if has==true then
                table.insert(tmpRs, {list=r, uid=var.data.uid})
            end
        end
    end
    local tmp={}
    for _, v in ipairs(tmpRs) do
        rs[v.uid]=nil
        for k2, v2 in pairs(v.list) do
            if rs[k2] and tmp[k2]==nil then
                tmp[k2]=1
                if v2.useCount1 then
                    rs[k2].useCount=rs[k2].useCount+v2.useCount1
                end
            elseif tmp[k2]==nil then
                if v2.useCount1 then
                    v2.useCount=v2.useCount1
                end
                tmp[k2]=1
                rs[k2]=v2
            end
        end
    end

    return rs
end

function useToolsView:replaceType(useItemList, data)
    local rs={}

    local isFF=false
    local sTime=tonumber(data.useEffect)
    for k=#useItemList, 1 ,-1 do
        local v=useItemList[k]
        local t=tonumber(v.useEffect)
        local needCount=sTime/t
        if sTime%t==0 and needCount<=v.count then
            isFF=true
            local count=0
            for i=1, v.count do
                count=count+1
                if i%needCount==0 then
                    data.useCount=data.useCount-1
                    if v.count-i<needCount then  --不够替换
                        break
                    end
                end
                if data.useCount==0 then
                    break
                end
            end
            if v.useCount1==nil then
                v.useCount1=0
            end
            v.useCount1=v.useCount1+count
            v.count=v.count-count
            rs[v.data.uid]=v
            if data.useCount==0 then  --完全替换
                return true, rs
            end
        end
        if v.count==0 then
            table.remove(useItemList, k)
        end
    end
    local tmp={}
    local tmp1={}
    local replaceNums=0
    for k=#useItemList, 1 ,-1 do
        local v=useItemList[k]
        local t=tonumber(v.useEffect)
        if t<=sTime then
            local count=0
            for i=1, v.count do
                if t<=sTime then
                    sTime=sTime-t
                    count=count+1
                    if sTime==0 and data.useCount>replaceNums+1 then
                        replaceNums=replaceNums+1
                        sTime=tonumber(data.useEffect)
                        if tmp1[v.data.uid] then
                             tmp1[v.data.uid].count=tmp1[v.data.uid].count+count
                        else
                            tmp1[v.data.uid]={data=v, count=count}
                        end
                        table.insert(tmp, tmp1)
                        count=0
                        tmp1={}
                    end
                else
                    break
                end
            end
            if tmp1[v.data.uid] then
                tmp1[v.data.uid].count=tmp1[v.data.uid].count+count
            else
                tmp1[v.data.uid]={data=v, count=count}
            end
            if sTime==0 then
                replaceNums=replaceNums+1
                table.insert(tmp, tmp1)
                break
            end
        end
    end

    local has=false
    if replaceNums>0 then
        data.useCount=data.useCount-replaceNums
        if data.useCount>0 then
            rs[data.data.uid]=data
        end
        for _, v in ipairs(tmp) do
            for k1, v1 in pairs(v) do
                if v1.data.useCount1==nil then
                    v1.data.useCount1=0
                end
                v1.data.useCount1=v1.data.useCount1+v1.count
                v1.data.count=v1.data.count-v1.count
                rs[k1]=v1.data
            end
        end
        has=true
    elseif isFF==true then  --替换了一定数量，还有剩余没有被替换
        rs[data.data.uid]=data
        has=true
    end
    return has, rs
end
