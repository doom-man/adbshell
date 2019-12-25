-- 国家介绍
raceInfoLayer = class("raceInfoLayer", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return me.assignWidget(arg[1], arg[2])
    end
end )
raceInfoLayer.__index = raceInfoLayer
function raceInfoLayer:create(...)
    local layer = raceInfoLayer.new(...)
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
function raceInfoLayer:ctor()
    me.registGuiClickEventByName(self, "raceInfoBox", function(node)
        self:close()
    end )
    self.pCountryId = 0
end

function raceInfoLayer:close()
    -- me.hideLayer(self,true,"shopbg")
    if self.pCountryId == 1 then  -- 北欧
       mAudioMusic:stopPalyEffect(MUSIC_TYPE.MUSIC_EFFECT_N_EUROPE)
    elseif self.pCountryId ==2 then  -- 西欧
       mAudioMusic:stopPalyEffect(MUSIC_TYPE.MUSIC_EFFECT_W_EUROPE)
    elseif self.pCountryId == 3 then  -- 阿拉伯
       mAudioMusic:stopPalyEffect(MUSIC_TYPE.MUSIC_EFFECT_ARAB)
    elseif self.pCountryId == 4 then -- 亚洲
       mAudioMusic:stopPalyEffect(MUSIC_TYPE.MUSIC_EFFECT_ASIAN)
    elseif self.pCountryId == 5 then -- 美洲
       mAudioMusic:stopPalyEffect(MUSIC_TYPE.MUSIC_EFFECT_AMERICA)
    end

    local pBuidInfoListView = me.assignWidget(self, "infolist")
    pBuidInfoListView:removeAllItems();
    for var = 1, 4 do
        local pbuidIcon = me.assignWidget(self, "Image_buid_" .. var)
        pbuidIcon:setVisible(false)
        local pBuidName = me.assignWidget(self, "Text_buid_name_" .. var)
        pBuidName:setVisible(false)
    end
    self:setVisible(false)
    --   cfg[CfgType.COUNTRY][1]
    --    local item = me.assignWidget(globalItems,"raceInfoItem")
    --    local txt = me.assignWidget(item,"txt")
    --    txt:setString("1-----")

end
function raceInfoLayer:init()
    self:loadRaceInfoData()
    return true
end
function raceInfoLayer:loadRaceInfoData()
    initCfg(CfgType.COUNTRY, "country.json")
    initCfg(CfgType.BUILDING, "building.json") 

end
-- 填充UI数据
function raceInfoLayer:setCountryData(CountryId)
    if CountryId ~= nil then
        local globalItems = me.createNode("Node_raceInfoItem.csb")
        self.pCountryId = CountryId
        self:playCountryMusic(CountryId)
        local pCountryData = cfg[CfgType.COUNTRY][CountryId]
        -- 获取国家记录
        local pCountryName = me.assignWidget(self, "raceName")
        pCountryName:setString(pCountryData.name)

        local pBuidInfoListView = me.assignWidget(self, "infolist")
        local pCountryIntroduction = cfg[CfgType.COUNTRY][CountryId]["desces"]
        -- 文明的描述
        for key, var in pairs(pCountryIntroduction) do
            local pData = pCountryIntroduction[key]
            local pItem = me.assignWidget(globalItems, "raceInfoItem")
            local pLabel = me.assignWidget(pItem, "txt")
            pLabel:setString(pData)
            pBuidInfoListView:setItemModel(pItem)
            pBuidInfoListView:pushBackDefaultItem()
        end
        local pCountryBuid = cfg[CfgType.COUNTRY][CountryId]["qijiID"]
        --[[
        -- 获取国家建筑物的ID
        if pCountryBuid then
            local pCBuidStr = me.split(pCountryBuid, ',')
            if pCBuidStr ~= nil then
                for key, var in pairs(pCBuidStr) do
                    local pBuidData = cfg[CfgType.BUILDING][me.toNum(var)]
                    local pbuidIcon = me.assignWidget(self, "Image_buid_" .. key)
                    pbuidIcon:loadTexture(buildIcon(pBuidData), me.plistType)
                    pbuidIcon:setVisible(true)
                    local pBuidName = me.assignWidget(self, "Text_buid_name_" .. key)
                    pBuidName:setString(pBuidData.name)
                    pBuidName:setVisible(true)
                end
            end
        end
        ]]
    end

end
function raceInfoLayer:playCountryMusic(pCountry)
    if pCountry == 1 then  -- 北欧
       mAudioMusic:setPlayEffect(MUSIC_TYPE.MUSIC_EFFECT_N_EUROPE,true)
    elseif pCountry ==2 then  -- 西欧
       mAudioMusic:setPlayEffect(MUSIC_TYPE.MUSIC_EFFECT_W_EUROPE,true)
    elseif pCountry == 3 then  -- 阿拉伯
       mAudioMusic:setPlayEffect(MUSIC_TYPE.MUSIC_EFFECT_ARAB,true)
    elseif pCountry == 4 then -- 亚洲
       mAudioMusic:setPlayEffect(MUSIC_TYPE.MUSIC_EFFECT_ASIAN,true)
    elseif pCountry == 5 then -- 美洲
       mAudioMusic:setPlayEffect(MUSIC_TYPE.MUSIC_EFFECT_AMERICA,true)
    end
end
function raceInfoLayer:onEnter()
    -- me.doLayout(self,me.winSize)
end
function raceInfoLayer:onExit()

end
