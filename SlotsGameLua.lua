SlotsGameLua = {}

SlotsGameLua.m_enumLevelType = enumLEVELTYPE.enumLevelType_Null
SlotsGameLua.m_enumReturnRateType = enumReturnRateTYPE.enumReturnType_Rate95
SlotsGameLua.m_GameResult = {}
SlotsGameLua.m_TestGameResult = {} --仿真专用
SlotsGameLua.m_goSlotsGame = nil --GameObject   LevelData。。。
SlotsGameLua.m_transform = nil

SlotsGameLua.m_n20RateSpin = 0
SlotsGameLua.m_n50RateSpin = 0
SlotsGameLua.m_n140RateSpin = 0
SlotsGameLua.m_n300RateSpin = 0

--//索引从1开始 reelID + 1 作为索引key
SlotsGameLua.m_stackedChoices = {}
SlotsGameLua.m_randomChoices = {}

SlotsGameLua.m_listLineLua = {} ---配了多少根线 1开始
SlotsGameLua.m_listSymbolLua = {} ----有哪些元素 数组 索引从1开始 里面存的元素ID也是从1开始的

SlotsGameLua.m_listReelLua = {} -----有多少reel 以及信息 索引从0开始。。。

SlotsGameLua.m_nRowCount = 0 --用来计算deck-Key等用途 所以。。在不规则棋盘上 这个值就是最长一列的元素个数
SlotsGameLua.m_nReelCount = 0

SlotsGameLua.m_bSplashFlags = {} ----这是个map。。。以前的SplashCount 这个不是从1开始的，里面元素的key是SplashType值
SlotsGameLua.m_bInSplashShow = false
SlotsGameLua.m_nSplashActive = -1
SlotsGameLua.m_bInResult = false
SlotsGameLua.m_bInSpin = false

SlotsGameLua.m_bShowWinLines = false
SlotsGameLua.m_bInSplashShowAllWinLines = false
SlotsGameLua.m_bCoinAniTimeFlag = false

SlotsGameLua.m_nWinOffset = 1
SlotsGameLua.m_fWinShowAge = 0.0
SlotsGameLua.m_fWinShowPeriod = 1.9

SlotsGameLua.m_bInSplashShowAllWinLines = false
SlotsGameLua.m_bCoinAniTimeFlag = false
SlotsGameLua.m_bAnimationTime = false

SlotsGameLua.m_fSpinAge = 0.0
SlotsGameLua.m_nActiveReel = -1 --当前正在等待stop的reel

SlotsGameLua.m_fBoundSpeed = 10.0
SlotsGameLua.m_fAcceleration = 1000.0
SlotsGameLua.m_fSpeedMax = 1800.0
SlotsGameLua.m_fRotateDistance = 3000.0

SlotsGameLua.m_fCentBoardX = 0.0
SlotsGameLua.m_fCentBoardY = 0.0
SlotsGameLua.m_fAllReelsWidth = 0.0
SlotsGameLua.m_fReelHeight = 0.0
SlotsGameLua.m_fSymbolHeight = 0.0
SlotsGameLua.m_fSymbolWidth = 0.0

SlotsGameLua.m_fDampingHeight = 0.0

--关卡里编辑配置的各阶段系数
SlotsGameLua.m_bReturnRateEnable = false
SlotsGameLua.m_nReturnRateBaseRandom = 20
SlotsGameLua.m_fReturnRate300Coef = 1.0
SlotsGameLua.m_fReturnRate140Coef = 1.0
SlotsGameLua.m_fReturnRate50Coef = 2.0
SlotsGameLua.m_fReturnRate20Coef = 2.0
--

SlotsGameLua.m_SimulationCount = 0
SlotsGameLua.m_enumSimRateType = enumReturnRateTYPE.enumReturnType_Rate95

--以下group0都是标准数组，元素从1开始。。
SlotsGameLua.m_listGroups = {} ---每个元素都是一个数组。。。

--SlotsGameLua.m_listGroup1 = {}
--SlotsGameLua.m_listGroup2 = {}
--SlotsGameLua.m_listGroup3 = {}

SlotsGameLua.m_listDeck = {} --从0开始。。。key为索引

SlotsGameLua.m_mapHitLineEffect = {} --Dictionary<int, EffectObj>
SlotsGameLua.m_mapSpineEffects = {} --Dictionary<int, SpineEffect>
SlotsGameLua.m_mapHighLightEffects = {} --Dictionary<int, HighLightEffect>
SlotsGameLua.m_mapMultiClipEffects = {} --Dictionary<int, MultiClipEffectObj>
SlotsGameLua.m_mapLeanTweenID = {} --Dictionary<int, int>

SlotsGameLua.m_bInitPosParamFlag = false

SlotsGameLua.m_nWin0Count = 0

SlotsGameLua.m_bPlayingSlotFireSound = false -- 记录是不是在播放等待scatter中奖的特效

SlotsGameLua.m_fDeltaTime = 0.0

SlotsGameLua.m_goStickySymbolsDir = nil --固定符号的父节点

--SlotsGameLua.InitSymbolToReel = nil  -- 初始化符号委托事件

--==============================--
--desc:放在SceneSlotGame start里面调用init初始化
--time:2017-08-27 05:57:34
--@return 
--==============================---
function SlotsGameLua:init()
    self.m_GameResult = GameResult:create()
    self.m_TestGameResult = GameResult:create()

    local strLevelDataPath = "NewGameNode/LevelInfo/SlotsDataInfo/LevelData"
    local goLevelData = Unity.GameObject.Find(strLevelDataPath)
    if goLevelData == nil then
        return
    end

    self.m_goSlotsGame = goLevelData
    self.m_transform = goLevelData.transform

    BaseBehaviour.Bind(goLevelData, self)
    BaseUpdateBehaviour.Bind(goLevelData, self)


    self:initLevelParam()
end

function SlotsGameLua:initLevelParam()
    --进关卡之后的各种初始化处理
    --缓存、reelLua等等各种。。。
    local game = CS.SlotsMania.SlotsGame.instance
    local nLevelType = game.m_enumLevelType
    Debug.Log("----enumLevelType----: " .. tostring(nLevelType))

    self.m_enumLevelType = game.m_nLevelType -- game.m_enumLevelType转为整数存这里。。
    
    self.m_nRowCount = game.RowCount




    local Symbols = game.Symbols
    local symbolCount = Symbols.Count
    for i=1, symbolCount do
        self.m_listSymbolLua[i] = SymbolLua:create(i, Symbols[i-1])
        local poorSize = game:getPoorSize(Symbols[i-1].prfab)
        SymbolObjectPool:AddPoolItem(Symbols[i-1].prfab, poorSize)
    end

    SymbolObjectPool:CreateStartupPools()

    local Reels = game.Reels
    local reelCount = Reels.Count
    Debug.Log("----reelCount-------: " .. reelCount)

    for i=0, reelCount-1 do
        local SlotsReel = Reels[i]
        local reelLua = ReelLua:create(i, SlotsReel)

        self.m_listReelLua[i] = reelLua
    end
    self.m_nReelCount = reelCount

    local Lines = game.Lines
    local lineCount = Lines.Count
    for i=1, lineCount do
        local line = Lines[i-1]
        local color = line.color
        local lineLua = LineLua:create(self.m_nReelCount, color)
        
        for index=0, self.m_nReelCount-1 do
            lineLua.Slots[index] = line.Slots[index]
        end

        self.m_listLineLua[i] = lineLua
    end

    self:initStackedGroupInfo()
	ChoiceCommonFunc:CreateChoice()

    for i,v in ipairs(SplashType) do
        self.m_bSplashFlags[v] = false
    end

    self.m_fBoundSpeed = game.BoundSpeed
    self.m_fAcceleration = game.Acceleration
    self.m_fSpeedMax = game.SpeedMax
    self.m_fRotateDistance = game.RotateDistance
    
    self.m_fCentBoardX = game.m_fCentBoardX
    self.m_fCentBoardY = game.m_fCentBoardY
    self.m_fAllReelsWidth = game.m_fAllReelsWidth
    self.m_fReelHeight = game.m_fReelHeight
    self.m_fSymbolHeight = game.m_fSymbolHeight
    self.m_fSymbolWidth = game.m_fSymbolWidth

    self.m_bReturnRateEnable = game.m_bReturnRateEnable
    self.m_nReturnRateBaseRandom = game.m_nReturnRateBaseRandom
    self.m_fReturnRate300Coef = game.m_fReturnRate300
    self.m_fReturnRate140Coef = game.m_fReturnRate140
    self.m_fReturnRate50Coef = game.m_fReturnRate50
    self.m_fReturnRate20Coef = game.m_fReturnRate20

    self.m_SimulationCount  = game.m_SimulationCount
    self.m_enumSimRateType = game.m_nSimRateType --game.m_enumSimRateType 枚举转为int再传给lua用

    self.m_goStickySymbolsDir = self.m_transform:Find("StickySymbolsDir").gameObject

    self:initPositionParam()

    self.m_GameResult:ResetGame(false)
    self:CreateReelRandomSymbolList()
    self:SetRandomSymbolToReel()

    PayLinePayWaysEffectHandler:MatchLineHide(true)

end

function SlotsGameLua:reset()
    Unity.GameObject.Destroy(self.m_goSlotsGame)
    self.m_goSlotsGame = nil --GameObject   LevelData。。。
    
    --//索引从1开始 reelID + 1 作为索引key
    self.m_stackedChoices = {}
    self.m_randomChoices = {}

    self.m_listLineLua = {} ---配了多少根线 1开始
--[[ 
    for k,v in pairs(self.m_listSymbolLua) do
        Unity.GameObject.Destroy(v.prfab)
    end ]]
    self.m_listSymbolLua = {} ----有哪些元素 数组 索引从1开始 里面存的元素ID也是从1开始的

    self.m_listReelLua = {} -----有多少reel 以及信息 索引从0开始。。。
    
    -- 下面这些需要释放的吧？？会内存泄漏吗？。。。。 todo
 --[[    self.m_mapHitLineEffect = {} --Dictionary<int, EffectObj>
    self.m_mapSpineEffects = {} --Dictionary<int, SpineEffect>
    self.m_mapHighLightEffects = {} --Dictionary<int, HighLightEffect>
    self.m_mapMultiClipEffects = {} --Dictionary<int, MultiClipEffectObj>
    self.m_mapLeanTweenID = {} --Dictionary<int, int>
 ]]
    PayLinePayWaysEffectHandler:reset()

end

function SlotsGameLua:start()
    Debug.Log("-----SlotsGameLua:start()-------")
end

function SlotsGameLua:onEnable()
    Debug.Log("-----SlotsGameLua:onEnable()-------")
end

function SlotsGameLua:onDisable()
    Debug.Log("-----SlotsGameLua:onDisable()-------")
end

function SlotsGameLua:onDestroy()
    Debug.Log("000000000-----SlotsGameLua:onDestroy()-------")
    self:reset()
    LeanTween.cancelAll()
end

function SlotsGameLua:DisplayAllMatchWaysInfo()
    if (not self.m_bInSplashShow) or (self.m_nSplashActive ~= SplashType.Line) then
        return false
    end

    if not self.m_bInSplashShowAllWinLines then
        return false
    end

    local bAutoSpin = SpinButton.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_AutoSpin
    local bNFreeSpin = SpinButton.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_NFreeSpin

    local nTotalWins = LuaUtil.tableSize(self.m_GameResult.m_mapWinItemPayWays)
    for k,v in pairs(self.m_GameResult.m_mapWinItemPayWays) do
        local nSymolID = bundleKey
        local item = self.m_GameResult.m_mapWinItemPayWays[nSymolID]
        local nMatches = item.m_nMatches
        for x = 0, nMatches-1 do
            local nCurReelRows = self.m_listReelLua[x].m_nReelRow
            for y = 0, y < nCurReelRows-1 do
                local nkey = self.m_nRowCount * x + y
                local nID =self.m_listDeck[nkey]
                local bSameKindSymbolFlag = self.isSamekindSymbol(nSymolID,nID)
                if bSameKindSymbolFlag then
                    local nResultKey = self.m_nRowCount * x + y
                    local nEffectKey = nResultKey
                    local bHaHitEffectFlag = LuaUtil.arrayContainsElement(self.m_mapHitLineEffect,nEffectKey)
                    if not bHaHitEffectFlag then
                        local pos0 = self.m_listReelLua[x].m_transfor.localPosition
                        local pos1 = self.m_listReelLua[x].m_listGoSymbol[y].m_transfor.localPosition
                        local effectPos = pos0 + pos1 + self.m_transfor.localPosition
                        local effectObj = EffectObj.CreateAndShow(effectPos, EffectType.EnumEffectType_PayLineSymbol)
                        self.m_mapHitLineEffect[nEffectKey] = effectObj

                        local spineEffect = self.m_listReelLua[x].m_listGoSymbol[y].m_transfor:GetComponent(typeof(SpineEffect))
                        if spineEffect then
                            self:AddSpineEffect(spineEffect,nEffectKey)
                        end
                    end

                    local bSpineAniFlag =  LuaUtil.arrayContainsElement(self.m_mapSpineEffects,nEffectKey)
                    if not bSpineAniFlag then
                        if not LuaUtil.arrayContainsElement(self.m_mapLeanTweenID,nEffectKey) then
                            local id = LeanTween.scale(self.m_listReelLua[x].m_listGoSymbol[y].m_transfor.gameObject, Unity.Vector3(1.05,1.05,1.0),0.3):setLoopPingPong(-1).id
                            self.m_mapLeanTweenID[nEffectKey] = id
                        end
                    end
                end

            end
        end
    end

    local bres = self:checkNeedReusedHitLineEffect()
    self.m_fWinShowAge = self.m_fWinShowAge + Unity.Time.deltaTime
    if self.m_fWinShowAge > self.m_fWinShowPeriod then
        self.m_fWinShowAge = self.m_fWinShowAge - self.m_fWinShowPeriod
        self.m_bInSplashShowAllWinLines = false
        PayLinePayWaysEffectHandler.m_bNeedCheckHitLineEffect = true
    end

    return true
end

function SlotsGameLua:DisplayMatchWaysInfo()
    if (not self.m_bInSplashShow) or (self.m_nSplashActive ~= SplashType.Line) then
        return
    end

    if self.m_bInSplashShowAllWinLines then
        return 
    end

    local nPayWays = LuaUtil.tableSize(self.m_GameResult.m_listWinItemPayWays)
    if nPayWays == 0 then
        for k,v in pairs(self.m_GameResult.m_mapWinItemPayWays) do
            table.insert(self.m_GameResult.m_listWinItemPayWays, self.m_GameResult.m_mapWinItemPayWays[k])
        end
    end

    local item = self.m_GameResult.m_listWinItemPayWays[self.m_nWinOffset]
    local nSymbolID = item.m_nSymbolIdx
    local nMatches = item.m_nMatches

    for x=0, nMatches do
        local nCurReelRows = self.m_listReelLua[x].m_nReelRow
        for y=0,nCurReelRows do
            local nkey = self.m_nRowCount * x + y
            local nID = self.m_listDeck[nkey]
            local bSameKindSymbolFlag = self:isSamekindSymbol(nSymbolID, nID)
            if bSameKindSymbolFlag then
                local nResultKey = self.m_nRowCount * x + y
                local nEffectKey = nResultKey
                if (not LuaUtil.arrayContainsElement(PayLinePayWaysEffectHandler.m_listCurHitLineEffectKeys, nEffectKey)) and
                    (PayLinePayWaysEffectHandler.m_bNeedCheckHitLineEffect) then
                    table.insert(PayLinePayWaysEffectHandler.m_listCurHitLineEffectKeys, nEffectKey)
                end

                local bHasHitEffectFlag = LuaUtil.arrayContainsElement(self.m_mapHitLineEffect, nEffectKey)
                if not bHasHitEffectFlag then
                    local pos0 = self.m_listReelLua[x].m_transfor.localPosition
                    local pos1 = self.m_listReelLua[x].m_listGoSymbol[y].m_transfor.localPosition
                    local effectPos =  pos0 + pos1 + self.m_transfor.localPosition
                    local effectObj = EffectObj.CreateAndShow(effectPos,EffectType.EnumEffectType_PayLineSymbol)
                    self.m_mapHitLineEffect[nEffectKey] = effectObj

                    local spineEffect = self.m_listReelLua[x].m_listGoSymbol[y]:GetComponent(typeof(SpineEffect))
                    if spineEffect then
                        self:AddSpineEffect(spineEffect, nEffectKey)
                    end
                end

                local bSpineAniFlag = LuaUtil.arrayContainsElement(self.m_mapSpineEffects,nEffectKey) 
                if not bSpineAniFlag then
                    if not LuaUtil.arrayContainsElement(self.m_mapLeanTweenID,nEffectKey) then
                        local id = LeanTween.scale(self.m_listReelLua[x].m_listGoSymbol[y].m_transfor.gameObject,Unity.Vector3(1.05,1.05,1.0),0.3):setLoopPingPong(-1).id
                        self.m_mapLeanTweenID[nEffectKey] = id
                    end
                end
            end
        end
    end

    self:checkNeedReusedHitLineEffect()
    self.m_fWinShowAge = self.m_fWinShowAge + Unity.Time.deltaTime
    if self.m_fWinShowAge > self.m_fWinShowPeriod then
        PayLinePayWaysEffectHandler.m_bNeedCheckHitLineEffect = true
        self.m_fWinShowAge = self.m_fWinShowAge - self.m_fWinShowPeriod
        self.m_nWinOffset = self.m_nWinOffset + 1
        if self.m_nWinOffset >= #self.m_GameResult.m_listWinItemPayWays then
            self.m_nWinOffset = 1
        end
    end
end

function SlotsGameLua:ShowAllMatchLines()
    if not self.m_bInSplashShow or self.m_nSplashActive ~= SplashType.Line then
        return false
    end
    
    if not self.m_bInSplashShowAllWinLines then
        return false
    end

    local nTotalWinLines = #self.m_GameResult.m_listWins -- 有多少根线中奖了

    local bNeedShowLines = false -- todo 有些3X3关卡需要画出中奖线条。。。 todo
    local bShowHighLightEffectFlag = false -- 3x3关卡给中奖元素播高光特效。。。
    local fElemScale = 1.05
    for nWinIndex = 1, nTotalWinLines do
        local wi = self.m_GameResult.m_listWins[nWinIndex]
        local ld = self:GetLine(wi.m_nLineID)

        if bNeedShowLines then
            -- 把这条线显示出来。。。
            PayLinePayWaysEffectHandler:ShowWinLine(wi.m_nLineID)
        end

        if bShowHighLightEffectFlag then
            PayLinePayWaysEffectHandler:ShowHighLightWinLine(wi.m_nLineID, wi.m_nMaxMatchReelID) --一般是3x3关卡用
        else
            PayLinePayWaysEffectHandler:ShowPayLineEffect(wi.m_nLineID, wi.m_nMaxMatchReelID)
            -- 转圈的粒子特效、spine动画、unity动画或者放大缩小...
        end

    end

    -- 上面枚举完了所有的线。。。下面还可能有不在中奖线的中奖元素需要播放特效。。比如Arab关的钻石上的金币数。。todo

    local bres = PayLinePayWaysEffectHandler:checkNeedReusedHitLineEffect()

    self.m_fWinShowAge = self.m_fWinShowAge + self.m_fDeltaTime
    if self.m_fWinShowAge > self.m_fWinShowPeriod * 1.35 then
        self.m_fWinShowAge = 0.0
        self.m_bInSplashShowAllWinLines = false
        PayLinePayWaysEffectHandler.m_bNeedCheckHitLineEffect = true
        --//绕框特效如果这次播放的线和接下来播放的线有相同元素，那么这些相同的不要reuse 否则会有卡顿感觉。

        --//这个不能和hitLineEffect一样 不管相同不相同的都要重置。。要让动画播放时间完全一致。。
        PayLinePayWaysEffectHandler:resetHighLightEffects()

        Debug.Log("-----self.m_fWinShowAge > self.m_fWinShowPeriod * 1.35---- ")
    end

    return true
end

function SlotsGameLua:DisplayMatchLinesInfo()
    if not self.m_bInSplashShow or self.m_nSplashActive ~= SplashType.Line then
        return
    end

    if self.m_bInSplashShowAllWinLines then
        return
    end

    if self.m_nWinOffset == 0 then --正式正常的线从1开始
        -- 不在中奖线上的元素中奖。。。比如arab关的钻石等。。 todo

        return
    end

    local nTotalWinLines = #self.m_GameResult.m_listWins
    if nTotalWinLines < 1 then
        --针对上面的情况在这里把m_nWinOffset置为 0 todo

        return
    end

    local wi = self.m_GameResult.m_listWins[self.m_nWinOffset] -- 从1开始的。。
    local ld = self:GetLine(wi.m_nLineID)

    --Debug.Log("------DisplayMatchLinesInfo--------nTotalWinLines: " .. nTotalWinLines)
    --Debug.Log("---------wi.m_nLineID: " .. wi.m_nLineID .. "   wi.m_nMaxMatchReelID: " .. wi.m_nMaxMatchReelID)

    -- 中奖线上的元素播放特效处理。。
    for x=0, self.m_nReelCount-1 do
        local nResultKey = self.m_nRowCount * x + ld.Slots[x]
        local nEffectKey = nResultKey

        if PayLinePayWaysEffectHandler.m_bNeedCheckHitLineEffect then
            local bflag = LuaUtil.arrayContainsElement(PayLinePayWaysEffectHandler.m_listCurHitLineEffectKeys, nEffectKey)
            if not bflag then
                table.insert( PayLinePayWaysEffectHandler.m_listCurHitLineEffectKeys, nEffectKey )
            end
        end
    end

    local bNeedShowLines = false
    local bShowHighLightEffectFlag = false

    -- 1. 3X3关卡里线条的显示。。
    if bNeedShowLines then
        -- 把这条线显示出来。。。
        PayLinePayWaysEffectHandler:ShowWinLine(wi.m_nLineID)
    end

    if bShowHighLightEffectFlag then
        PayLinePayWaysEffectHandler:ShowHighLightWinLine(wi.m_nLineID, wi.m_nMaxMatchReelID) --一般是3x3关卡用
    else
        PayLinePayWaysEffectHandler:ShowPayLineEffect(wi.m_nLineID, wi.m_nMaxMatchReelID)
        -- 转圈的粒子特效、spine动画、unity动画或者放大缩小...
    end

    PayLinePayWaysEffectHandler:checkNeedReusedHitLineEffect()

    self.m_fWinShowAge = self.m_fWinShowAge + self.m_fDeltaTime

    --Debug.Log("---------self.m_fWinShowAge: " .. self.m_fWinShowAge)


    if self.m_fWinShowAge > self.m_fWinShowPeriod then
        PayLinePayWaysEffectHandler.m_bNeedCheckHitLineEffect = true
        PayLinePayWaysEffectHandler:resetHighLightEffects()

        self.m_fWinShowAge = self.m_fWinShowAge - self.m_fWinShowPeriod
        self.m_nWinOffset = self.m_nWinOffset + 1
        if self.m_nWinOffset > nTotalWinLines then
            self.m_nWinOffset = 1

            --arab关从0开始^_^

        end
    end

end

function SlotsGameLua:DisplaySplashInfo()
    if self.m_bInSpin or not self.m_bInResult or self.m_bInSplashShow or self.m_bAnimationTime then
        return false
    end

    if self.m_nSplashActive == -1 then
        return false
    end

    if self.m_nSplashActive >= SplashType.Max then
        self.m_bInResult = false
        self.m_bInSplashShowAllWinLines = false
        SceneSlotGame:OnSplashEnd()
        PayLinePayWaysEffectHandler:MatchLineHide(false)
    else
        -- 一些SplashType范围外的弹窗或者逻辑处理 需要打断后续弹窗的 可以在这插入 todo
        -- 比如 preFreeSpin等。。
        if not self.m_bSplashFlags[self.m_nSplashActive] then
            self.m_nSplashActive = self.m_nSplashActive + 1
        else
            self.m_bInSplashShow = true
            if self.m_nSplashActive ~= SplashType.Line then
                SceneSlotGame:OnSplashShow(self.m_nSplashActive)
            end
        end
    end

    return true
end

function SlotsGameLua:ApplyResult()
    local bFreeSpinFlag = self.m_GameResult:InFreeSpin()
    self.m_listDeck = self:GetDeck(bFreeSpinFlag)

    -- 关卡相关的deck内容修改都放在各自的GetDeck方法里做了

    local bWin0 = false
    local nUserLevel, fPercent = PlayerLevelEXP:GetUserLevel()
    local bFreeSpinFlag = LevelDataHandler:isFreeSpinFlag() --新用户是否已经玩过freespin了
    local nThresholdValue = 3
    if self.m_nWin0Count >= nThresholdValue or  (nUserLevel > 2 and not bFreeSpinFlag) then
        bWin0 = LevelCommonFunctions:IsWin0Deck(self.m_listDeck) --返回true表示这次spin没有中奖
    end

    if self.m_nWin0Count >= nThresholdValue then
        self.m_nWin0Count = 0
        if bWin0 then
            LevelCommonFunctions:modifyWin0Deck(self.m_listDeck)
        end
    else
        if nUserLevel > 2 and not bFreeSpinFlag then
            if bWin0 then
                LevelCommonFunctions:modifyScatterDeck(self.m_listDeck)
            end
        end
    end

    --set to reel
    for x=0, self.m_nReelCount-1 do
        local reelLua = self.m_listReelLua[x]
        for y=0, self.m_nRowCount-1 do
            local nkey = self.m_nRowCount * x + y
            reelLua.m_FinalValues[y] = self.m_listDeck[nkey]
        end
    end
end

function SlotsGameLua:GetDeck(bFreeSpinFlag)
    --todo 每一关都应该各自写自己的GetDeck方法
    --
    if self.m_enumLevelType == enumLEVELTYPE.enumLevelType_SnowWhite11 then
        --todo
        local deck = SnowWhiteFunc:GetDeck(bFreeSpinFlag)
        return deck
    elseif self.m_enumLevelType == enumLEVELTYPE.enumLevelType_LuckyStar then
        local deck = LuckyStarFun:GetDeck(bFreeSpinFlag)
        return deck
    elseif self.m_enumLevelType == enumLEVELTYPE.enumLevelType_WildRespin then
        local deck = WildRespinFunc:GetDeck(bFreeSpinFlag)
        return deck
    end

    --下面写个基本的跑流程用
   local deck = self:GetTestDeck(bFreeSpinFlag)
   return deck
end

function SlotsGameLua:GetTestDeck(bFreeSpinFlag)
    local deck = {}
    for x=0, self.m_nReelCount-1 do
        for y=0, self.m_nRowCount do
            local nkey = self.m_nRowCount * x + y
            local nSymbolId = self.m_randomChoices[x+1]:Choice()
            deck[nkey] = nSymbolId
        end
    end

    --self:ModifyTestDeck(deck)

    return deck
end

function SlotsGameLua:ModifyTestDeck(deck)
   if not Config.PLATFORM_EDITOR then
        return
   end

   deck[0] = 1
   deck[3] = 1
   deck[6] = 1

   deck[1] = 2
   deck[4] = 2
   deck[7] = 2

end

function SlotsGameLua:update(dt)
    self.m_fDeltaTime = dt

    local bPayWaysFlag = GameLevelUtil:isPayWaysLevel()
    if bPayWaysFlag then
        local bShowAllWaysFlag = self:DisplayAllMatchWaysInfo()
        self:DisplayMatchWaysInfo()
    else
        local bShowAllLinesFlag = self:ShowAllMatchLines()
        if bShowAllLinesFlag then
            return
        end
        self:DisplayMatchLinesInfo()
    end

    local bFlag = self:DisplaySplashInfo()
    if bFlag then
        return
    end

    if not self.m_bInSpin then
        return
    end

    if self.m_nActiveReel == -1 then
        self.m_fSpinAge = self.m_fSpinAge + dt
        if self.m_fSpinAge > 0.5 then -- spin开始后0.5s可以允许停
            self.m_nActiveReel = 0
            self:ApplyResult()
            self.m_listReelLua[self.m_nActiveReel]:Stop()

            SceneSlotGame:OnSpinToStop()
        end
    else
        local nMaxReelID = self.m_nReelCount-1
        local bHasPreCheckWinFlag = false
        if self.m_nActiveReel <= nMaxReelID and self.m_listReelLua[self.m_nActiveReel]:Completed() then
            SceneSlotGame:OnReelStop(self.m_nActiveReel)
            --check next reel
            self.m_nActiveReel = self.m_nActiveReel + 1
            --if all Reels stopped.
            if self.m_nActiveReel > nMaxReelID then
                local bAllReelAniStop = self:IsAllReelAniStop()
                if bAllReelAniStop then
                    self:PreCheckWin()
                    bHasPreCheckWinFlag = true
                end
            else
                self.m_listReelLua[self.m_nActiveReel]:Stop()
            end
        end

        if not bHasPreCheckWinFlag and self.m_nActiveReel > nMaxReelID then
            local bAllReelAniStop = self:IsAllReelAniStop()
            if bAllReelAniStop then
                self:PreCheckWin()
            end
        end

    end
end

function SlotsGameLua:IsAllReelAniStop()
    return true
end

function SlotsGameLua:PreCheckWin()
    self.m_bInSpin = false
    self:RefreshDeck() --reel.m_curSymbolIds可能在reel滚动时修改了 ... 比如pixie关，最后停下来的情况与之前生成的Deck有差别

    ---这个方法也是 需要每一关各自写自己的 播放动画等做一些关卡相关的事情 类似：
    if self.m_enumLevelType == enumLEVELTYPE.enumLevelType_SnowWhite11 then
        SnowWhiteFunc:PreCheckWin()
        return
    end

    if self.m_enumLevelType == enumLEVELTYPE.enumLevelType_WildRespin then
        WildRespinFunc:PreCheckWin()
    end

    --走流程。。
    self:CheckWinEnd()
end

function SlotsGameLua:RefreshDeck() ----极少特殊情况下m_curSymbolIds会修改了Deck
    for x=0, self.m_nReelCount-1 do
        local reel = self.m_listReelLua[x]
        for y=0, self.m_nRowCount-1 do
            local nkey = self.m_nRowCount * x + y
            local nSymbolId = reel.m_curSymbolIds[y]
            self.m_listDeck[nkey] = nSymbolId
        end
    end
end

function SlotsGameLua:CheckWinEnd()
    local bPayWaysFlag = GameLevelUtil:isPayWaysLevel()
    if bPayWaysFlag then
        self:CheckSpinWinPayWays(self.m_listDeck, self.m_GameResult, false)
    else
        self:CheckSpinWinPayLines(self.m_listDeck, self.m_GameResult, false)
    end

    local fCurSpinWins =  SceneSlotGame.m_fCurSpinWinCoins
    fCurSpinWins = fCurSpinWins + self.m_GameResult.m_fSpinWin
    fCurSpinWins = fCurSpinWins + self.m_GameResult.m_fJackPotBonusWin
    fCurSpinWins = fCurSpinWins + self.m_GameResult.m_fNonLineBonusWin
    SceneSlotGame.m_fCurSpinWinCoins = fCurSpinWins

    self.m_bInSplashShowAllWinLines = true
    local bInFreeSpinFlag = self.m_GameResult:InFreeSpin()
    if bInFreeSpinFlag then
        LevelDataHandler:addFreeSpinTotalWin(fCurSpinWins) --todo
    end

    local bInReSpinFlag = self.m_GameResult:InReSpin()
    if fCurSpinWins < 0.0 and not bInReSpinFlag then
        self.m_nWin0Count = self.m_nWin0Count + 1
    else
        self.m_nWin0Count = 0
    end

    self.m_nWinOffset = 1
    self.m_fWinShowAge = 0.0
    SceneSlotGame:OnSpinEnd()
    self:ShowSpinResult()

    local fCurWin = self.m_GameResult.m_fSpinWin + self.m_GameResult.m_fNonLineBonusWin
    if self.m_GameResult:HasFreeSpin() then
        if fCurWin > 0.0 then
            local strInfo = LuaUtil.numWithCommas(fCurWin) -- 只会是整数。。
            strInfo = "+" .. strInfo 
            SceneSlotGame:setTotalWinTipInfo(strInfo, true)
        end
    end

    self:CreateReelRandomSymbolList()
end

function SlotsGameLua:CreateReelRandomSymbolList()

    if self.m_enumLevelType == enumLEVELTYPE.enumLevelType_LuckyStar then
        return LuckyStarFun:CreateReelRandomSymbolList()
    end

    if self.m_enumLevelType == enumLEVELTYPE.enumLevelType_WildRespin then
        return WildRespinFunc:CreateReelRandomSymbolList()
    end

    -- 每关各自写自己的方法 todo
    
    local bPayWaysFlag = GameLevelUtil:isPayWaysLevel()

    for x=0, self.m_nReelCount-1 do
        self.m_listReelLua[x].m_listRandomSymbolID = {}
        for i=1, 40 do
            local nSymbolId = self.m_randomChoices[x+1]:Choice()
            self.m_listReelLua[x].m_listRandomSymbolID[i] = nSymbolId
        end
    end

--[[ 
    local nSymbolID = LevelCommonFunctions:checkBigSymbolIdx(self.m_nID, nSymbolID, y)

    nSymbolID = LevelCommonFunctions:checkSymbolSizeRule(self.m_nID, nSymbolID, y, bResultDeck)

    nSymbolID = LevelCommonFunctions:checkSymbolAdjacent(self.m_nID, nSymbolID, y,bResultDeck)

 ]]
    -- 1. 根据掉落规则来检查修改m_listRandomSymbolID里的元素 把不符合要求的替换掉。。。 比如：scatter不能相邻 占多格的元素等等。。

end


function SlotsGameLua:ShowSpinResult()
	--local bIrishFlag = m_enumLevelType == enumLEVELTYPE.enumLevelType_3X3_Irish
	--local bMardigrasFlag = m_enumLevelType == enumLEVELTYPE.enumLevelType_3X3_Mardigras
	--local b3X3Flag = bIrishFlag or bMardigrasFlag
    local bRespinFlag = self.m_GameResult:InReSpin()
    if bRespinFlag then
        for i=1, #self.m_GameResult.m_listWins do
            if self.m_GameResult.m_listWins[i].m_nMatches == self.m_nReelCount  then
                if not self.m_GameResult.m_listWins[i].m_bAny3CombFlag then --类似luckyVegas关卡的混合中奖就不弹窗了
                    self.m_bSplashFlags[SplashType.FiveInRow] = true
                    break
                end
            end
        end

        --Ways的情况
        for k,v in pairs(self.m_GameResult.m_mapWinItemPayWays) do
            if v.m_nMatches == self.m_nReelCount then
                self.m_bSplashFlags[SplashType.FiveInRow] = true
            end
        end
    end

    --领取jackpot的情况
    if self.m_GameResult.m_enumJackpotType ~= JackpotTYPE.enumJackpotType_NULL then
        self.m_bSplashFlags[SplashType.BonusGameEnd] = true
    end

    local bShowWinLines = #self.m_GameResult.m_listWins > 0
    local bShowWinWays = #self.m_GameResult.m_listWinItemPayWays > 0
    local bNonLineBonusWin = self.m_GameResult.m_fNonLineBonusWin > 0
    if bShowWinLines or bShowWinWays or bNonLineBonusWin then
        self.m_bSplashFlags[SplashType.Line] = true
    end

    local fWins = self.m_GameResult.m_fSpinWin
    if bRespinFlag then
        fWins = self.m_GameResult.m_fNonLineBonusWin
    end

    local fWinCoef = fWins / SceneSlotGame.m_nTotalBet
    if fWinCoef >= 1500.0 then
        self.m_bSplashFlags[SplashType.MegaWin] = true
    elseif fWinCoef >= 1000.0 then
        self.m_bSplashFlags[SplashType.BigWin] = true
    end

    --if freeSpin exist..
    if self.m_GameResult.m_nNewFreeSpinCount > 0 then
        if self.m_GameResult.m_nFreeSpinCount == 0 then
            -- 初次触发
        else
            --retriger
            SceneSlotGame.m_bNeedPlayRetrigerSound = true
        end
         self.m_bSplashFlags[SplashType.FreeSpin] = true

         --标记玩家已经获得过freespin了。。
         LevelDataHandler:setFreeSpinFlag(true) --todo
    end

    if self.m_GameResult.m_bRespinCompletedFlag then
        -- body
    else
        if self.m_GameResult.m_nFreeSpinTotalCount > 0 and 
            self.m_GameResult.m_nFreeSpinCount >= self.m_GameResult.m_nFreeSpinTotalCount and
            not self.m_GameResult:InFreeSpin()
        then
            self:FreeSpinEndFunc()
        end
    end

    if SpinButton.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_AutoSpin then
        if SceneSlotGame.m_nAutoSpinNum == 0 then
            SpinButton.m_enumSpinStatus = enumSpinButtonStatus.SpinButtonStatus_SpinEnable
            SpinButton:SetButtonSprite(enumButtonType.ButtonType_Spin)
            SceneSlotGame:ButtonEnable(true)
            SceneSlotGame.m_textAutoSpinNum.gameObject:SetActive(false)
        end
    end

    if self.m_GameResult.m_bBonusStartFlag then
        LevelDataHandler:setBonusGameFlag(strLevelName, true)
        self.m_bSplashFlags[SplashType.Bonus] = true
        self.m_GameResult.m_bBonusStartFlag = false
        Debug.Log("-----bonusGame------")
    end

    if self.m_GameResult.m_bReSpinStartFlag then
        self.m_bSplashFlags[SplashType.ReSpin] = true
        self.m_GameResult.m_bReSpinStartFlag = false
    end

    for k,v in pairs(SplashType) do
        if self.m_bSplashFlags[v] then -- true 这一项有弹窗再去做检查
            if v == SplashType.BigWin or v == SplashType.MegaWin then
                self.m_bSplashFlags[SplashType.FiveInRow] = false
            end
        end
    end

    self.m_bInResult = true
    self.m_nSplashActive = 0
    Debug.Log("---------self.m_nSplashActive = 0--------")

    local bres1 = self.m_bSplashFlags[SplashType.BigWin] or self.m_bSplashFlags[SplashType.MegaWin] or
                    self.m_bSplashFlags[SplashType.FiveInRow]

    local bres2 = self.m_bSplashFlags[SplashType.Bonus] or self.m_bSplashFlags[SplashType.FreeSpin] or
                    self.m_bSplashFlags[SplashType.FreeSpinEnd] or self.m_bSplashFlags[SplashType.BonusGameEnd] or
                    self.m_bSplashFlags[SplashType.ReSpin] or self.m_bSplashFlags[SplashType.ReSpinEnd]

    if bres2 then -- 这种情况就永远不再调用HandleAllReelStopAudio
        SceneSlotGame.m_bPlayReelStopAudio = false
    else --这种情况分现在就播放HandleAllReelStopAudio 还是等弹窗结束播放。。
        SceneSlotGame.m_bPlayReelStopAudio = true
    end

    --//bres1 && !bres2 //等界面关闭了再来HandleAllReelStopAudio

    if not bres1 and not bres2 then
        SceneSlotGame:AllReelStopAudioHandle(true)
    end

    if not bres1 and bres2 then
        SceneSlotGame:AllReelStopAudioHandle(false)
    end

    if bres1 or bres2 then
        if SpinButton.m_SpinButton.interactable then
            SpinButton.m_SpinButton.interactable = false
        end
    end

    --Test Splash
    --self.m_bSplashFlags[SplashType.FreeSpin] = true
    --self.m_bSplashFlags[SplashType.FreeSpinEnd] = true
    --self.m_bSplashFlags[SplashType.Bonus] = true
    --self.m_bSplashFlags[SplashType.BonusGameEnd] = true
    --self.m_bSplashFlags[SplashType.BigWin] = true
    --self.m_bSplashFlags[SplashType.MegaWin] = true

end

function SlotsGameLua:FreeSpinEndFunc()
    self.m_bSplashFlags[SplashType.FreeSpinEnd] = true
    if SceneSlotGame.m_nAutoSpinNum == 0 then
        SpinButton.m_enumSpinStatus = enumSpinButtonStatus.SpinButtonStatus_SpinEnable
    else
        SpinButton.m_enumSpinStatus = enumSpinButtonStatus.SpinButtonStatus_AutoSpin
        SpinButton:SetButtonSprite(enumButtonType.ButtonType_Auto)
    end
    SceneSlotGame:ButtonEnable(true)
end

function SlotsGameLua:CheckSpinWinPayWays(deck, result, bSimulationFlag)
    result:ResetSpin()
    
    local nReel0RowNum = 3
    local nReelIndex = 0
    for row = 0,nReel0RowNum do
        local nCurID = deck[self.m_nRowCount * nReelIndex + row]
        local Wild2XSymbolCount = 0
        local Wild3XSymbolCount = 0
        local nReelSameSymbolNums ={}
        for i=0,self.m_nReelCount-2 do
            nReelSameSymbolNums[i] = 0
        end
        for x=1,self.m_nReelCount-1 do
            local nCurReelRowNum = self.m_listReelLua[x].m_nReelRow
            for y=0,nCurReelRowNum - 1 do
                local nID = deck[self.m_nRowCount * x + y]
                local bSameKindSymbolFlag = self:isSamekindSymbol(nCurID,nID)
                if bSameKindSymbolFlag then
                    nReelSameSymbolNums[x - 1] = nReelSameSymbolNums[x - 1] + 1
                    local bWildFlag1 = self:GetSymbol(nID):IsWild()
                    if bWildFlag1 then
                        if self:GetSymbol(nID).type == SymbolType.Wild2X then
                            Wild2XSymbolCount = Wild2XSymbolCount + 1
                        end
                        if self:GetSymbol(nID).type == SymbolType.Wild3X then
                            Wild3XSymbolCount = Wild3XSymbolCount + 1
                        end
                    end
                end
            end
        end

        local nWays = 1
        local nMatches = 1
        for i=0,#nReelSameSymbolNums do
            if nReelSameSymbolNums[i] == 0 then
                break
            end
            nWays =nWays * nReelSameSymbolNums[i]
            nMatches = i + 2
        end

        local sd = self:GetSymbol(nCurID)
        local nRewardBet = sd.m_fRewards[nMatches]
        if nMatches > 1 and nRewardBet > 0 then
            local fMultiplier = SceneSlotGame.m_nTotalBet / 100.0
            local fWinGold = nRewardBet * fMultiplier * nWays
            if Wild3XSymbolCount > 0 then
                fWinGold = math.pow(3.0, Wild3XSymbolCount)
            end
            if Wild2XSymbolCount > 0 then
                fWinGold = math.pow(3.0, Wild2XSymbolCount)
            end
            local winItem =WinItemPayWay:create(nCurID, nMatches, nWays, fWinGold)
            local bFlag = false
            for tkey in pairs(result.m_mapWinItemPayWays) do
                if tkey == nCurID then
                    bFlag = true
                    break
                end
            end
            if bFlag then
                local curItem = result.m_mapWinItemPayWays[nCurID]
                assert(curItem.m_nMatches == nMatches)
                curItem.m_nWays = curItem.m_nWays + nWays
                curItem.m_fWinGold = fWinGold
                result.m_mapWinItemPayWays[nCurID] = curItem
            else
                result.m_mapWinItemPayWays[nCurID] = winItem
            end

            result.m_fSpinWin = result.m_fSpinWin + fWinGold
            local nPayWayTestWinItemLength = 0
            for i in pairs(result.m_mapTestPayWayWinItems) do
                nPayWayTestWinItemLength = nPayWayTestWinItemLength + 1
            end
            if nPayWayTestWinItemLength ~= 0 then
                result.m_mapTestPayWayWinItems[nCurID].m_nHit = result.m_mapTestPayWayWinItems[nCurID].m_nHit  + nWays
                result.m_mapTestPayWayWinItems[nCurID].m_fWinGold  = result.m_mapTestPayWayWinItems[nCurID].m_fWinGold + fWinGold
            end
        end
    end

    local nLevelType = self.m_enumLevelType
    result.m_fGameWin = result.m_fGameWin + result.m_fSpinWin
    if result:InFreeSpin() then
        result.m_fFreeSpinTotalWins = result.m_fFreeSpinTotalWins + result.m_fSpinWin
        result.m_fFreeSpinAccumWins = result.m_fFreeSpinAccumWins + result.m_fSpinWin
    end

    local ScaterSymbolCount = LevelCommonFunctions:GetResultSymbolCount(deck, SymbolType.Scatter)
    local nNewFreeSpinCount = LevelCommonFunctions:GetNewFreeSpinCount(ScaterSymbolCount,result)
    if not bSimulationFlag then
        LevelDataHandler:addNewFreeSpinCount(Scene.themeKey,nNewFreeSpinCount)
        LevelDataHandler:addTotalFreeSpinCount(Scene.themeKey,nNewFreeSpinCount)
    end

    result.m_nNewFreeSpinCount = nNewFreeSpinCount
    result.m_nFreeSpinAccumCount = result.m_nFreeSpinAccumCount + result.m_nNewFreeSpinCount
    result.m_nFreeSpinTotalCount = result.m_nFreeSpinTotalCount + result.m_nNewFreeSpinCount

    return result
end

function SlotsGameLua:CheckSpinWinPayLines(deck, result, bSimulationFlag)
    if self.m_enumLevelType == enumLEVELTYPE.enumLevelType_LuckyStar then
        LuckyStarFun:CheckSpinWinPayLines(deck, result, bSimulationFlag)
        return result
    end

    if self.m_enumLevelType == enumLEVELTYPE.enumLevelType_WildRespin then
        WildRespinFunc:CheckSpinWinPayLines(deck,result,bSimulationFlag)
        return result
    end

    result:ResetSpin()
    local bInRespinFlag = result:InReSpin()
    local bSimulationRespinFlag = false

    bInRespinFlag = result:InReSpin() or bSimulationRespinFlag
    for i=1, #self.m_listLineLua do
        if bInRespinFlag then
            break
        end

        local iResult = {}
        local ld = self:GetLine(i)
        for x=0, self.m_nReelCount-1 do
            iResult[x] = deck[ self.m_nRowCount * x + ld.Slots[x] ]
        end

        for x=0,self.m_nReelCount-1 do
            local bNormalFlag = self:GetSymbol(iResult[x]):IsNormalSymbol()
            if not bFirstSymbol then
                if not self:GetSymbol(iResult[x]):IsWild() then
                    if (not bNormalFlag) and  (MatchCount > 0) then -- 这是遇到scatter牌了
                        break
                    endsfdsf sf 
                    SymbolIdx = iResult[x]
                    bFirstSymbol = true
                end
sdf sdf sdf
                MatchCount = MatchCount + 1
                nMaxMatchReelID = x
            else
                local curSymbol = self:GetSymbol(SymbolIdx)
                bNormalFlag = curSymbol:IsNormalSymbol()

                local bSameKindSymbolFlag = false
                bSameKindSymbolFlag = LevelCommonFunctions:isSamekindSymbol(SymbolIdx, iResult[x])
                if bSameKindSymbolFlag or (self:GetSymbol(iResult[x]):IsWild() and bNormalFlag) then
                    MatchCount = MatchCount + 1

                    nMaxMatchReelID = x
                else
                    break
                end
            end
        end
        if MatchCount >= 1 then
            local bcond1 = false
            local bcond2 = false
            local bcond3 = false

            local nCombIndex = -1
            local sd = nil
            local fCombReward = 0.0
            if SymbolIdx == -1 then
                local wildType = SymbolType.Wild
                sd = self:GetSymbolByType(wildType)
                fCombReward = sd.m_fRewards[MatchCount]
                bcond1 = true
                SymbolIdx = self:GetSymbolIdxByType(wildType)

            else
                sd = self:GetSymbol(SymbolIdx)
                if sd.type == SymbolType.Normal or sd.type == SymbolType.NormalDouble or sd.type > 100 then
                    fCombReward = sd.m_fRewards[MatchCount]
                    bcond3 = true

                end
            end

            if fCombReward > 0 then
                local fLineBet = SceneSlotGame.m_nTotalBet / #self.m_listLineLua
                local LineWin = fCombReward * fLineBet
                Debug.Log("-------fCombReward: " .. fCombReward .. "  fLineBet:  " .. fLineBet)
                Debug.Log("-------SymbolIdx: " .. SymbolIdx .. "  MatchCount:  " .. MatchCount)

                table.insert(result.m_listWins, WinItem:create(i, SymbolIdx, MatchCount, LineWin, bcond2, nMaxMatchReelID))
                result.m_fSpinWin = result.m_fSpinWin + LineWin

                if bSimulationRespinFlag then
                    if nCombIndex == #self.m_listSymbolLua or
                        nCombIndex == #self.m_listSymbolLua + 1 or
                        nCombIndex == #self.m_listSymbolLua + 2  then
                        result.m_listTestWinSymbols[nCombIndex].Hit = result.m_listTestWinSymbols[nCombIndex].Hit + 1
                        result.m_listTestWinSymbols[nCombIndex].WinGold = result.m_listTestWinSymbols[nCombIndex].WinGold + LineWin

                    else
                        result.m_listTestWinSymbols[SymbolIdx].Hit = result.m_listTestWinSymbols[nCombIndex].Hit + 1
                        result.m_listTestWinSymbols[SymbolIdx].WinGold = result.m_listTestWinSymbols[nCombIndex].WinGold + LineWin

                    end
                    result.m_listTestWinLines[i].Hit = result.m_listTestWinLines[i].Hit + 1
                    result.m_listTestWinLines[i].WinGold = result.m_listTestWinLines[i].Hit + LineWin

                end
            else


            end
        end
    end
    bInRespinFlag = result:InReSpin()
    
    result.m_fGameWin = result.m_fGameWin + result.m_fNonLineBonusWin
    result.m_fGameWin = result.m_fGameWin + result.m_fSpinWin

    local nLevelType = self.m_enumLevelType
    if result:InFreeSpin() then
        result.m_fFreeSpinTotalWins = result.m_fFreeSpinTotalWins + result.m_fSpinWin
        result.m_fFreeSpinAccumWins = result.m_fFreeSpinAccumWins + result.m_fSpinWin

        result.m_fFreeSpinTotalWins = result.m_fFreeSpinTotalWins + result.m_fNonLineBonusWin
        result.m_fFreeSpinAccumWins = result.m_fFreeSpinAccumWins + result.m_fNonLineBonusWin

        result.m_fFreeSpinTotalWins = result.m_fFreeSpinTotalWins + result.m_fJackPotBonusWin
        result.m_fFreeSpinAccumWins = result.m_fFreeSpinAccumWins + result.m_fJackPotBonusWin

    end

    if not bSimulationFlag then
        local ScaterSymbolCount = LevelCommonFunctions:GetResultSymbolCount(deck, SymbolType.Scatter)
        local nNewFreeSpinCount = LevelCommonFunctions:GetNewFreeSpinCount(ScaterSymbolCount, result)
        if not bSimulationFlag then
            LevelDataHandler:addNewFreeSpinCount(Scene.themeKey, nNewFreeSpinCount)
            LevelDataHandler:addTotalFreeSpinCount(Scene.themeKey, nNewFreeSpinCount)
        end

        result.m_nNewFreeSpinCount = nNewFreeSpinCount
        result.m_nFreeSpinAccumCount = result.m_nFreeSpinAccumCount + result.m_nNewFreeSpinCount
        result.m_nFreeSpinTotalCount = result.m_fFreeSpinTotalWins + result.m_nNewFreeSpinCount
    end

    return result
end

function SlotsGameLua:SetRandomSymbolToReel()
    for i=0, self.m_nReelCount-1 do
        local nTotal = self.m_listReelLua[i].m_nReelRow + self.m_listReelLua[i].m_nAddSymbolNums
        for y=0, nTotal-1 do
            self.m_listReelLua[i].m_curSymbolIds[y] = 0
        end

        self.m_listReelLua[i]:SetSymbolRandom()
    end
end

function SlotsGameLua:initStackedGroupInfo()
    local game = CS.SlotsMania.SlotsGame.instance
    local group0 = game.m_listGroup0 --List<int>
    local group1 = game.m_listGroup1
    local group2 = game.m_listGroup2
    local group3 = game.m_listGroup3
    local group4 = game.m_listGroup4
    local group5 = game.m_listGroup5
    local group6 = game.m_listGroup6
    local group7 = game.m_listGroup7
    local group8 = game.m_listGroup8
    local group9 = game.m_listGroup9

    local groups = {group0, group1, group2, group3, group4, group5, group6, group7, group8, group9}
    for i=1, #groups do
        local nGroupCount = groups[i].Count --C# 的list
        if nGroupCount > 0 then
            for j=1, nGroupCount do
                self.m_listGroups[i][j] = groups[i][j]
            end
        end
    end
    
end

function SlotsGameLua:GetSymbolIdByTypeAndKindTag(type, strKindTag)
    for i=1,#self.m_listSymbolLua do
        if self.m_listSymbolLua[i].type == type and self.m_listSymbolLua[i].m_strKindTag == strKindTag then
            return i
        end
    end
end

function SlotsGameLua:GetSymbol(nSymbolID) --//从1开始
    if nSymbolID == nil then
        Debug.Log("---------SlotsGameLua:GetSymbol(nSymbolID)----nSymbolID == nil-----")
    end

    local symbollua = self.m_listSymbolLua[nSymbolID]
    return symbollua
end

function SlotsGameLua:GetSymbolIdxByType(symbolType)
    for i=1, #self.m_listSymbolLua do
        local type = self.m_listSymbolLua[i].type
        if type == symbolType then
            return i
        end
    end

    return -1
end

function SlotsGameLua:GetSymbolByType(symbolType)
    local idx = self:GetSymbolIdxByType(symbolType)
    if idx == -1 then
        return nil
    else
        return self.m_listSymbolLua[idx]
    end
end

function SlotsGameLua:Spin()
    if self.m_bInSpin then
        return SlotsReturnCode.InSpin
    end

    local bFreeSpinFlag = self.m_GameResult:HasFreeSpin()
    local bReSpinFlag = self.m_GameResult:HasReSpin()
    local fPlayerCoins = DBHandler:getCoin()
    if not bFreeSpinFlag and not bReSpinFlag then
        if fPlayerCoins < SceneSlotGame.m_nTotalBet then
            return SlotsReturnCode.NoGold
        end
    end

    -- 某些有sticky元素的关卡需要在这里resetStickySymbols  还有一些关卡相关的运行时数据需要重置等 todo

    if not bFreeSpinFlag and not bReSpinFlag then
        DBHandler:addCoin(-SceneSlotGame.m_nTotalBet)
    end

    LeanTween.delayedCall(0.5, function()
        if not bFreeSpinFlag and not bReSpinFlag then
            self.m_GameResult.m_fGameWin = 0.0
        else
            local bCond1 = bFreeSpinFlag and self.m_GameResult.m_nFreeSpinCount==0
            local bCond2 = bReSpinFlag and self.m_GameResult.m_nReSpinCount==0
            if bCond1 or bCond2 then
                self.m_GameResult.m_fGameWin = 0.0
            end
        end
        SceneSlotGame.m_SlotsNumberWins:End(self.m_GameResult.m_fGameWin)
    end)

    for k,v in pairs(SplashType) do
        self.m_bSplashFlags[v] = false
    end
    
    PayLinePayWaysEffectHandler:MatchLineHide(true)

    ---start reels spin
    for i=0, self.m_nReelCount-1 do
        self.m_listReelLua[i]:SymbolScaleReset()
        self.m_listReelLua[i]:Spin()
    end

    self.m_fSpinAge = 0.0
    self.m_nActiveReel = -1
    self.m_bInSpin = true
    return SlotsReturnCode.Success
end

function SlotsGameLua:Spinable()
    if self.m_bInSpin or self.m_bAnimationTime then
        return false
    end

    if SceneSlotGame.m_bUIState then
        return false
    end

    ---todo //收集金币等动画不能被忽略了，必须等金币飞了才能允许spin
    ----todo  //有元素需要被变成wild固定下来

    local bHasSplash = SceneSlotGame:hasSplashUI()
    if bHasSplash then
        return false
    end

    local bHasPopWindow = PopController:hasPop()
    if bHasPopWindow then
        return false
    end

    return true
end

function SlotsGameLua:getSymbolOffsetY(nReelID) --从0开始
    local nRow = self.m_listReelLua[nReelID + 1]
    local fcoef = (nRow - 1.0)/2.0
    return fcoef
end

function SlotsGameLua:initPositionParam()
    if self.m_bInitPosParamFlag then
        return
    end
    self.m_bInitPosParamFlag  = true

    local strPrePath = "NewGameNode/LevelInfo/LevelBG"
    local strBiaoChiDir = strPrePath .. "/BiaoChi"
    local TopObj = Unity.GameObject.Find(strBiaoChiDir .. "/TOP")
    local BottomObj = Unity.GameObject.Find(strBiaoChiDir .. "/BOTTOM")
    local RightObj = Unity.GameObject.Find(strBiaoChiDir .. "/RIGHT")
    local LeftObj = Unity.GameObject.Find(strBiaoChiDir .. "/LEFT")
    TopObj:SetActive(false)
    BottomObj:SetActive(false)
    RightObj:SetActive(false)
    LeftObj:SetActive(false)

    local BiaoChiObj = Unity.GameObject.Find(strBiaoChiDir)
    local posBiaoChi = BiaoChiObj.transform.localPosition
    local posRight = RightObj.transform.localPosition + posBiaoChi
    local posLeft = LeftObj.transform.localPosition + posBiaoChi
    local posTop = TopObj.transform.localPosition + posBiaoChi
    local posBottom = BottomObj.transform.localPosition + posBiaoChi

    self.m_fCentBoardX = (posRight.x + posLeft.x) / 2.0
    self.m_fCentBoardY = (posTop.y + posBottom.y) / 2.0

    self.m_fAllReelsWidth = posRight.x - posLeft.x
    self.m_fReelHeight = posTop.y - posBottom.y

    self.m_fSymbolHeight = self.m_fReelHeight / self.m_nRowCount
    self.m_fSymbolWidth = self.m_fAllReelsWidth / self.m_nReelCount

    self:RepositionSymbols()
end

function SlotsGameLua:RepositionSymbols()
    local nOutSideCount = self:getLevelOutSideCount()
    local nReelCount = self.m_nReelCount
    local fReelWidth = self.m_fAllReelsWidth / nReelCount

    local fMidIndex = (nReelCount - 1) / 2.0
    for i=0, nReelCount-1 do
        local fOffsetX = self.m_fCentBoardX + (i - fMidIndex) * fReelWidth
        local reelLua = self.m_listReelLua[i]
        -- self.m_fCentBoardY
        reelLua.m_goGameObject.transform.localPosition = Unity.Vector3(fOffsetX, 0.0, 0.0)

        --//animal等不规则关卡 ReelRow互相不一样
        local fMidRow = (reelLua.m_nReelRow-1) / 2.0
        local nSymbolNum = #(reelLua.m_listGoSymbol)
        for y=1, nSymbolNum do
            local fPosY = (y-1 -fMidRow) * self.m_fSymbolHeight
            reelLua.m_listSymbolPos[y-1] = Unity.Vector3(0.0, fPosY, 0.0)
            reelLua.m_listGoSymbol[y-1].transform.localPosition = reelLua.m_listSymbolPos[y-1]
        end

        reelLua.m_nOutSideCount = nOutSideCount

    end
end

function SlotsGameLua:getLevelOutSideCount()
    local nOutSideCount = 1

    return nOutSideCount
end

function SlotsGameLua:initReelBGPosition()
    local strPrePath = "NewGameNode"
    local goReelBG = Unity.GameObject.Find(strPrePath .. "/LevelInfo/LevelBG/ReelBG")
    local posLevelData = self.m_goSlotsGame.transform.localPosition
    local nReelNum = goReelBG.transform.childCount
    local fReelWidth = self.m_fAllReelsWidth / nReelNum
    local fMidIndex = (nReelNum - 1) / 2.0

    for i=0, nReelNum-1 do
        local tr = goReelBG.transform:GetChild(i)
        local fOffsetX = self.m_fCentBoardX + (i - fMidIndex) * fReelWidth

        local pos = Unity.Vector2(fOffsetX, self.m_fCentBoardY)

        tr.localPosition = pos
    end

end

function SlotsGameLua:getReelBGPosByReelID(nReelIndex) --从0开始。。
    local strPrePath = "NewGameNode"
    local goReelBG = Unity.GameObject.Find(strPrePath .. "/LevelInfo/LevelBG/ReelBG")
    local nReelNum = goReelBG.transform.childCount

    local fReelWidth = self.m_fAllReelsWidth / nReelNum
    local fMidIndex = (nReelNum-1) / 2.0
    local fOffsetX = self.m_fCentBoardX + (nReelIndex-fMidIndex) * fReelWidth
    local pos = Unity.Vector2(fOffsetX, m_fCentBoardY)

    return pos
end

function SlotsGameLua:resetStickySymbols()
    local nReelCount = self.m_nReelCount
    for i=0, nReelCount-1 do
        local reel = self.m_listReelLua[i]
        local cnt = #reel.m_listStickySymbol
        for j=1, cnt do
            local goSymbol = reel.m_listStickySymbol[j].m_goSymbol
            if goSymbol ~= nil then
                SymbolObjectPool:Unspawn(goSymbol)
            end
        end

        reel.m_listStickySymbol = {}
    end
end

function SlotsGameLua:onSimulationFunc()
    -- body
    local game = CS.SlotsMania.SlotsGame.instance
    self.m_enumSimRateType = game.m_nSimRateType
    self.m_SimulationCount = game.m_SimulationCount
    -- 然后再根据关卡 LevelID 分到各自的类里面去实现
    if self.m_enumLevelType == enumLEVELTYPE.enumLevelType_LuckyStar  then
        LuckyStarFun:Simulation()
    end
end

function SlotsGameLua:GetLine(index)---从1开始
    return self.m_listLineLua[index]
end

function SlotsGameLua:isSamekindSymbol(SymbolIdx, nResultId)
    if self.m_GameResult:InReSpin() then
        return false
    end

    local enumType1 = self:GetSymbol(SymbolIdx).type
    local enumType2 = self:GetSymbol(nResultId).type

    if enumType1 == SymbolType.NullSymbol or enumType2 == SymbolType.NullSymbol then
        return false
    end

    local bWildFlag1 = self:GetSymbol(SymbolIdx):IsWild()
    local bWildFlag2 = self:GetSymbol(SymbolIdx):IsWild()

    if bWildFlag1 or bWildFlag2 then
        return true
    end

    if SymbolIdx == nResultId then
        return true
    end

    local strTag1 = self:GetSymbol(SymbolIdx).m_strKindTag
    local strTag2 = self:GetSymbol(nResultId).m_strKindTag
    local bSameTag = strTag1 == strTag2
    if bSameTag and strTag1 ~= "" then
        return true
    end

    if strTag1 == "AnyBarAny7" then
        if strTag2 == "AnyBar" or strTag2 == "Any7" then
            return true
        end
    end

    if strTag2 == "AnyBarAny7" then
        if strTag1 == "AnyBar" or strTag1 == "Any7" then
            return true
        end
    end

    local nType1 = enumType1
    local nType2 = enumType2

    if nType1 < 1000 or nType2 < 1000 then
        return false
    end

    if math.floor(nType1 / 1000) == math.floor(nType2 / 1000) then
        return true
    end

    return false
end

function SlotsGameLua:delayCallCheckWinEndFun(fDelay)
    local yield_return = (require 'cs_coroutine').yield_return
    if fDelay > 0.01 then
        yield_return(YieldCache:Wait(fDelay))
    end

    if not SlotsGameLua.m_GameResult:InReSpin() then
        SceneSlotGame.m_btnSpin.interactable = true
    end

    self.m_bAnimationTime = false
    self:CheckWinEnd()
end