-- 主城动画

allAnimation = class("allAnimation", mAnimation)
allAnimation.__index = allAnimation
function allAnimation:createAnimation(aname)
   local layer = allAnimation.new(aname)
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
-- 通用特效
ALL_COMMON_SKIP_FORT = "texiao_zhi_zhanling.png"
ALL_COMMON_LEVELUP = "texiao_zhi_dengji_shengji.png" --玩家等级升级
ALL_COMMON_TASK = "texiao_zhi_renwu.png" -- 任务
ALL_COMMON_TIMES_FEUD = "texiao_zhi_shidai_fengjian.png" -- 封建时代
ALL_COMMON_TIMES_CASTE = "texiao_zhi_shidai_chengbao.png" -- 城堡时代
ALL_COMMON_TIMES_EMPEROR = "texiao_zhi_shidai_diwang.png" -- 帝王时代
ALL_COMMON_VICTORY = "texiao_zhi_shengli.png" -- 占领要塞，胜利
ALL_COMMON_FAILURE = "texiao_zhi_shibai.png" -- 占领失败
ALL_COMMON_VIPLEVELUP = "texiao_zhi_vip_shengji.png" --VIP升级
ALL_COMMON_HEROLEVELUP = "texiao_zhi_jinjie.png" --图鉴进阶成功
ALL_COMMON_OPEN_EXPER = "texiao_zhi_silian.png" --试炼开启
ALL_COMMON_ACHIEVENMENT = "texiao_zhi_chengjiu.png"--成就达成
ALL_COMMON_STRENGTH = "texiao_zhi_qianghua.png"--强化成功
ALL_COMMON_EXILE = "texiao_zhi_fangzhu.png"--放逐成功
ALL_COMMON_TUPO = "texiao_zhi_tupo.png"--突破成功
ALL_COMMON_SKIN = "texiao_skin_success.png" --装扮
ALL_COMMON_ZHAOHUAN = "texiao_zhaohuan_success.png" -- 召唤
ALL_COMMON_RUNE_CASE_ACTIVE = "texiao_rune_case_active.png" -- 圣物方案激活
ALL_COMMON_HEROLEVEL_SAODANG = "herolevel_saodang.png" -- 圣物方案激活
ALL_COMMON_PATROL = "texiao_zhi_patrol.png" -- 完成巡逻
ALL_COMMON_RESIST_VICTORY = "texiao_zhi_resist_ok.png" -- 抵御蛮族成功
ALL_COMMON_RESIST_FAILURE = "texiao_zhi_resist_failure.png" -- 抵御蛮族失败
ALL_COMMON_LEVELSTAR = "texiao_zhi_shengxing.png" --升星成功
ALL_COMMON_LEVELUP_COMPLETE = "texiao_zhi_levelup_complete.png" --升星
ALL_COMMON_WORLD_TASK = "texiao_tianxia.png" --升星
ALL_COMMON_AWAKEN = "texiao_zhi_juexing.png"--圣物觉醒成功
ALL_COMMON_BATTLE_START = "battle_start.png"
ALL_COMMON_HERO_LEVELUP = "texiao_zhi_jinsheng.png"


function allAnimation:ctor()   
--    print("allAnimation ctor") 
    self.mCountDown = 0  -- 倒计时
    self.mPoint = 1 -- 节点数
    
end
function allAnimation:init()   
  
    return true
end
function allAnimation:setfishData(pNode,pCountDown,pPoint)
      
    self.mPoint = pPoint
    self.mCountDown = pCountDown
    local pStr = "fish_"..pPoint
    me.assignWidget(pNode,pStr):addChild(self)

    self:fishPaly("idle") 
end
function allAnimation:setCountDown(pTime)
   if self.mCountDown >0 then
        self.mCountDown = self.mCountDown - pTime
    else
        self.mCountDown = 0
   end
       
end
function allAnimation:getCountDown()
     return self.mCountDown
end
function allAnimation:getfishPoint()
    return self.mPoint
end

-- 修道院伤兵
function allAnimation:WoundedSoldier(justOnce_) 
    self:getAnimation():setSpeedScale(0.5)
    self:fishPaly("scene_build_work")  
    if justOnce_ ~= nil then    
       local function animationEvent(armatureBack,movementType,movementID)
            if movementType == ccs.MovementEventType.loopComplete then
                self:removeFromParentAndCleanup(true)
            end
        end
        self:getAnimation():setMovementEventCallFunc(animationEvent)
    end 
end
 -- 王座
function allAnimation:Throne()
   --  self:getAnimation():setSpeedScale(1.0)
     --self:fishPaly("Animation1") 
     self:getAnimation():playWithIndex(0,4,5)
end
-- 主城城镇火
function allAnimation:CityCenter()
     self:getAnimation():setSpeedScale(1.0)
     self:fishPaly("idle")      
end
-- 要塞试炼
function allAnimation:FortExper()
  --   self:getAnimation():setSpeedScale(1.0)
     self:fishPaly("idle")      
end
-- 空闲状态
function allAnimation:CitySleep()
     self:getAnimation():setSpeedScale(0.6)
     self:fishPaly("scene_uild_sleep")      
end
-- 升级
function allAnimation:UpGarde()
     self:fishPaly("idle") 
     local function animationEvent(armatureBack,movementType,movementID)
            if movementType == ccs.MovementEventType.complete then
               self:removeFromParentAndCleanup(true)
            end
     end
     self:getAnimation():setMovementEventCallFunc(animationEvent)
end
-- 合成
function allAnimation:archCompound()
     self:fishPaly("ui_item_get") 
     local function animationEvent(armatureBack,movementType,movementID)
            if movementType == ccs.MovementEventType.complete then
           --    self:removeFromParentAndCleanup(true)
            end
     end
     self:getAnimation():setMovementEventCallFunc(animationEvent)
end

--通用特效 替换相应资源
function allAnimation:CommonSpecificReplaceRes(pStr, wordBgStr, typeIconStr, typeBone)
    local pIcon = ccs.Skin:create(pStr)
    local word = self:getBone("word")
    word:addDisplay(pIcon, 1)
    word:changeDisplayWithIndex(1, true)
    
end
-- 通用特效
function allAnimation:CommonSpecific(pStr, callback)
    if pStr==ALL_COMMON_TASK or 
    pStr==ALL_COMMON_STRENGTH or 
    pStr==ALL_COMMON_EXILE or  
    pStr==ALL_COMMON_TUPO or 
    pStr == ALL_COMMON_SKIN or
    pStr == ALL_COMMON_ZHAOHUAN or
    pStr == ALL_COMMON_RUNE_CASE_ACTIVE or
    pStr == ALL_COMMON_HEROLEVEL_SAODANG or
    pStr == ALL_COMMON_PATROL or
    pStr == ALL_COMMON_LEVELUP_COMPLETE or
    pStr == ALL_COMMON_WORLD_TASK or 
    pStr == ALL_COMMON_BATTLE_START or
    pstr == ALL_COMMON_HERO_LEVELUP or
    pStr == ALL_COMMON_LEVELSTAR 
     then
        self:CommonSpecificReplaceRes(pStr, "texiao_common_wordbg1.png", "", 1)
    elseif pStr==ALL_COMMON_TIMES_FEUD then
        self:CommonSpecificReplaceRes(pStr, "texiao_common_wordbg1.png", "texiao_zhi_shidai_fengjian_typeIco.png")
    elseif pStr==ALL_COMMON_TIMES_CASTE then
        self:CommonSpecificReplaceRes(pStr, "texiao_common_wordbg1.png", "texiao_zhi_shidai_chengbao_typeIco.png")
    elseif pStr==ALL_COMMON_TIMES_EMPEROR then
        self:CommonSpecificReplaceRes(pStr, "texiao_common_wordbg1.png", "texiao_zhi_shidai_diwang_typeIco.png")
    elseif pStr==ALL_COMMON_VICTORY or pStr==ALL_COMMON_RESIST_VICTORY then
        self:CommonSpecificReplaceRes(pStr, "texiao_common_wordbg1.png", "")
    elseif pStr==ALL_COMMON_VIPLEVELUP then
        self:CommonSpecificReplaceRes(pStr, "texiao_common_wordbg1.png", "texiao_zhi_vip_shengji_typeIco.png", 1)
    elseif pStr==ALL_COMMON_FAILURE or pStr==ALL_COMMON_RESIST_FAILURE then
        self:CommonSpecificReplaceRes(pStr, "texiao_common_wordbg2.png", "")
    else
        self:CommonSpecificReplaceRes(pStr, "texiao_common_wordbg1.png", "")
    end    
    self:fishPaly("ui_battle_victory")    
    local function animationEvent(armatureBack,movementType,movementID)
            if movementType == ccs.MovementEventType.loopComplete or movementType == ccs.MovementEventType.complete then
                self:removeFromParentAndCleanup(true)
            end
            if callback~=nil then
                callback()
            end
    end
    self:getAnimation():setMovementEventCallFunc(animationEvent)
end
-- 夏天阳光
function allAnimation:CitySummer()
     self:getAnimation():setSpeedScale(0.5)
     self:fishPaly("scene_city_season_2")      
end
-- 夏天云
function allAnimation:CityCloud()
     self:getAnimation():setSpeedScale(1.0)
     self:fishPaly("scene_city_season_2_1")      
end
-- 秋天树叶
function allAnimation:cityAutumn()
     self:fishPaly("scene_city_season_3")      
end
function allAnimation:heroSkillAni()
    self:fishPaly("idle")      
end
-- 驿站特效
function allAnimation:MapPostObj()
    self:fishPaly("scene_buildStation")  
    local function animationEvent(armatureBack,movementType,movementID)
        if movementType == ccs.MovementEventType.loopComplete then
           self:removeFromParentAndCleanup(true)
        end
    end
    self:getAnimation():setMovementEventCallFunc(animationEvent) 
end
-- 失败
function allAnimation:FailMapAniamtion(args)
    self:fishPaly("ui_battle_defeat")  
     local function animationEvent(armatureBack,movementType,movementID)
        if movementType == ccs.MovementEventType.loopComplete then
           self:removeFromParentAndCleanup(true)
        end
    end
    self:getAnimation():setMovementEventCallFunc(animationEvent) 
end
function allAnimation:onEnter()
--    print("allAnimation onEnter") 
--	me.doLayout(self,me.winSize)  
end
function allAnimation:onExit()
--    print("allAnimation onExit")    
end


