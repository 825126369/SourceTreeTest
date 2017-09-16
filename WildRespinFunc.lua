require "Lua/GameLogic/WildRespin/WildRespinLevelUI"
WildRespinFunc = {}

WildRespinFunc.m_fAnyBarReward = 2.0
WildRespinFunc.m_fAny7Reward = 3.0

function  WildRespinFunc:GetDeck(bFreeSpinFlag)
    local result = {}
    for x=0,SlotsGameLua.m_nReelCount - 1 do
        for y=0,SlotsGameLua.m_nRowCount - 1 do
            local SymbolKey = SlotsGameLua.m_nRowCount * x + y
            --local SymbolIdx = SlotsGameLua.m_randomChoices[x + 1]:Choice()
            result[SymbolKey] = SymbolIdx
        end
    end

    self:ModifyResult(result,bFreeSpinFlag)
    return result
end

--1:每列中的元素不能相邻,Wild 元素 只在 中间列,1x,3x,5x 只出现在1，3列
function WildRespinFunc:ModifyResult(result,bFreeSpinFlag)
    local nNullSymbolID = SlotsGameLua:GetSymbolIdxByType(SymbolType.NullSymbol)
    local nWildSymbolID = SlotsGameLua:GetSymbolIdByTypeAndKindTag(SymbolType.Wild,"Wild")
    SlotsGameLua:GetSymbolByType(symbolType)

    local nRandom = math.random(1, 100)
    if nRandom < 80 then --有80%的可能把中间一行置为3个非空元素
        result[0] = nNullSymbolID
        result[3] = nNullSymbolID
        result[6] = nNullSymbolID
    end

    for x=0, SlotsGameLua.m_nReelCount -1 do
        for y=1,SlotsGameLua.m_nRowCount - 1 do
            local nkey = SlotsGameLua.m_nRowCount * x + y
            local nSymbolID = result[nkey]
            --local nPreSymbolID = result[nkey - 1]
            local id = LevelCommonFunctions:checkSymbolAdjacent(x, nSymbolID, nPreSymbolID)
            if x ~= 1 and id == SlotsGameLua:GetSymbolIdxByType(SymbolType.Wild) then
                while id == nNullSymbolID or id == nWildSymbolID do
                    id = SlotsGameLua.m_randomChoices[x + 1]:Choice()
                end
            end
            --result[nkey] = id
        end
    end

    --Test
    --result[1] = 1
    --result[4] = nWildSymbolID
    --result[7] = 1

    --local bInRespinFlag = result:InReSpin()
    -- resul

end

function WildRespinFunc:CreateReelRandomSymbolList()
    local nNullSymbolID = SlotsGameLua:GetSymbolIdxByType(SymbolType.NullSymbol)
    local nWildSymbolID = SlotsGameLua:GetSymbolIdByTypeAndKindTag(SymbolType.Wild,"Wild")

    local cnt = 40 --必须为偶数
    for x=0, SlotsGameLua.m_nReelCount-1 do
        SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID = {}
        for i=1, cnt do
            local nSymbolID = SlotsGameLua.m_randomChoices[x+1]:Choice()
            if i > 1 then
                local nPreSymbolID = SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID[i-1]
                nSymbolID = LevelCommonFunctions:checkSymbolAdjacent(x, nSymbolID, nPreSymbolID)
            end
            if x ~= 1 and nSymbolID == SlotsGameLua:GetSymbolIdByTypeAndKindTag(SymbolType.Wild,"Wild") then
                while nSymbolID == nNullSymbolID or nSymbolID == nWildSymbolID do
                    nSymbolID = SlotsGameLua.m_randomChoices[x + 1]:Choice()
                end
            end
            SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID[i] = nSymbolID
        end
    end
end

function WildRespinFunc:PreCheckWin()
    local bInRespinFlag = SlotsGameLua.m_GameResult:InReSpin() --是否在ReSpin的时候结算
    local orNextRespin = self:CheckOrReSpin(bInRespinFlag) --根据上一次的是否是ReSpin的状态，来做逻辑
    if orNextRespin then
        --self:InRespinStickyWildSymbol()
    else
        
    end

    --StartCoroutine(m_slotsGame.delayCallCheckWinEndFun(fTime));
    local co = coroutine.create(function()
           SlotsGameLua:delayCallCheckWinEndFun(0.5)
        end)
    assert(coroutine.resume(co))
end

function WildRespinFunc:InRespinStickyWildSymbol()
    local nWildSymbolID = SlotsGameLua:GetSymbolIdByTypeAndKindTag(SymbolType.Wild,"Wild")
    local deck = SlotsGameLua.m_listDeck
     for i=1, #SlotsGameLua.m_listLineLua do
        local y = SlotsGameLua.m_listLineLua[i].Slots[1]
        local lindId =  deck[1 * SlotsGameLua.m_nRowCount + y]
        if lindId == nWildSymbolID then
            local preGo =  SlotsGameLua.m_listReelLua[1].m_listGoSymbol[y]
            local prePos = preGo.transform.position
            local sr = preGo:GetComponentInChildren(typeof(CS.CurveItem))
            sr.m_sortingOrder = 200

            preGo.transform:SetParent(SlotsGameLua.m_goStickySymbolsDir.transform)
            preGo.transform.localScale = Unity.Vector3.one
            preGo.transform.position = prePos
            local stickySymbol = StickySymbol:new(nil,proGo,SymbolType.Wild,y)
            table.insert(SlotsGameLua.m_listReelLua[1].m_listStickySymbol,stickySymbol)

            local nRandomIndex = nil
            local nNullSymbolId = SlotsGameLua:GetSymbolIdxByType(SymbolType.NullSymbol)
            while not nRandomIndex or nRandomIndex == nNullSymbolId or nRandomIndex == lindId do
                nRandomIndex = SlotsGameLua.m_randomChoices[2]:Choice()
            end
            local tempSymbol = SlotsGameLua:GetSymbol(nRandomIndex)
            local tempGo = SymbolObjectPool:Spawn(tempSymbol.prfab)
            tempGo.transform:SetParent(SlotsGameLua.m_listReelLua[1].m_transform)
            tempGo.transform.localScale = Unity.Vector3.one
            tempGo.transform.localPosition = SlotsGameLua.m_listReelLua[1].m_listSymbolPos[y]
            SlotsGameLua.m_listReelLua[1].m_listGoSymbol[y] = tempGo

            deck[1 * SlotsGameLua.m_nRowCount + y] = nRandomIndex
        end
    end
end

function WildRespinFunc:CheckOrReSpin(lastbReSpin)
    if lastbReSpin then
        if self:IsWin0Deck_payLines() and self:CheckWildOrInLine() then
            return true
        end
    else
        if self:CheckWildOrInLine() then
            return true
        end
    end
    return false
end

function WildRespinFunc:CheckWildOrInLine()
    local nWildSymbolID = SlotsGameLua:GetSymbolIdByTypeAndKindTag(SymbolType.Wild,"Wild")
    local deck = SlotsGameLua.m_listDeck
    for i=1, #SlotsGameLua.m_listLineLua do
        local lindId =  deck[1 * SlotsGameLua.m_nRowCount + SlotsGameLua.m_listLineLua[i].Slots[1]]
        if lindId == nWildSymbolID then
            return true
        end
    end
    return false
end

function WildRespinFunc:IsWin0Deck_payLines()
    local deck = SlotsGameLua.m_listDeck
    for i=1, #SlotsGameLua.m_listLineLua do
        local iResult = {}
        local ld = SlotsGameLua:GetLine(i)
        for x=0, SlotsGameLua.m_nReelCount - 1 do
            iResult[x] = deck[SlotsGameLua.m_nRowCount * x + ld.Slots[x]]
        end

        local bCheckAnyCombFlag = false

        local nMaxMatchReelID = 0
        local MatchCount = 0
        local bFirstSymbol = false
        local SymbolIdx = -1
        for x=0,SlotsGameLua.m_nReelCount-1 do
            local type = SlotsGameLua:GetSymbol(iResult[x]).type
            if type ~= SymbolType.NullSymbol then
                if not bFirstSymbol then
                    SymbolIdx = iResult[x]
                    bFirstSymbol = true
                    MatchCount = MatchCount + 1
                else                                                               
                    local bSameKindSymbolFlag =  SlotsGameLua:isSamekindSymbol(SymbolIdx, iResult[x]) --这里已经判断了，如果是两个AnyBarAny7比较，则结果false
                    if bSameKindSymbolFlag then
                        MatchCount = MatchCount + 1

                        if SymbolIdx ~= iResult[x] then
                            bCheckAnyCombFlag = true

                            local strTag = SlotsGameLua:GetSymbol(iResult[x]).m_strKindTag
                            if strTag ~= "AnyBarAny7" then
                               SymbolIdx = iResult[x]
                            end
                        end
                    else
                        break
                    end
                end
            else
                break
            end
        end

        local nSymbolCount = #SlotsGameLua.m_listSymbolLua

        nMaxMatchReelID = MatchCount - 1
        if MatchCount >= 1 then
            local fCombReward = 0.0
            local bcond2 = false
            local nCombIndex = -1
            local sd = SlotsGameLua:GetSymbol(SymbolIdx)
            if bCheckAnyCombFlag and MatchCount>=3 then
                bcond2 = true
                local strKindTag = sd.m_strKindTag
                if strKindTag == "AnyBar" then
                    fCombReward = self.m_fAnyBarReward
                    nCombIndex = nSymbolCount + 1
                end

                if strKindTag == "Any7" then
                    fCombReward = self.m_fAny7Reward
                    nCombIndex = nSymbolCount + 2
                end
            end

            if not bCheckAnyCombFlag and SymbolIdx ~= -1 then
                fCombReward = SlotsGameLua:GetSymbol(SymbolIdx).m_fRewards[MatchCount]
            end

            if fCombReward > 0 then
                return true
            end
        end
    end
    return false
end

function WildRespinFunc:CheckSpinWinPayLines(deck, result, bSimulationFlag)
    result:ResetSpin()
    local bInRespinFlag = result:InReSpin()

    for i=1, #SlotsGameLua.m_listLineLua do

        local iResult = {}
        local ld = SlotsGameLua:GetLine(i)
        for x=0, SlotsGameLua.m_nReelCount - 1 do
            iResult[x] = deck[SlotsGameLua.m_nRowCount * x + ld.Slots[x]]
        end

        local bCheckAnyCombFlag = false

        local nMaxMatchReelID = 0
        local MatchCount = 0
        local bFirstSymbol = false
        local SymbolIdx = -1
        for x=0,SlotsGameLua.m_nReelCount-1 do
            local type = SlotsGameLua:GetSymbol(iResult[x]).type
            if type ~= SymbolType.NullSymbol then
                if not bFirstSymbol then
                    SymbolIdx = iResult[x]
                    bFirstSymbol = true
                    MatchCount = MatchCount + 1
                else                                                               
                    local bSameKindSymbolFlag =  SlotsGameLua:isSamekindSymbol(SymbolIdx, iResult[x]) --这里已经判断了，如果是两个AnyBarAny7比较，则结果false
                    if bSameKindSymbolFlag then
                        MatchCount = MatchCount + 1

                        if SymbolIdx ~= iResult[x] and type ~= SymbolType.Wild then
                            bCheckAnyCombFlag = true

                            local strTag = SlotsGameLua:GetSymbol(iResult[x]).m_strKindTag
                            if strTag ~= "AnyBarAny7" then
                               SymbolIdx = iResult[x]
                            end
                        end
                    else
                        break
                    end
                end
            else
                break
            end
        end

        local nSymbolCount = #SlotsGameLua.m_listSymbolLua

        nMaxMatchReelID = MatchCount - 1
        if MatchCount >= 1 then
            local fCombReward = 0.0
            local bcond2 = false
            local nCombIndex = -1
            local sd = SlotsGameLua:GetSymbol(SymbolIdx)
            if bCheckAnyCombFlag and MatchCount>=3 then
                bcond2 = true
                local strKindTag = sd.m_strKindTag
                if strKindTag == "AnyBar" then
                    fCombReward = self.m_fAnyBarReward
                    nCombIndex = nSymbolCount + 1
                end

                if strKindTag == "Any7" then
                    fCombReward = self.m_fAny7Reward
                    nCombIndex = nSymbolCount + 2
                end
            end

            if not bCheckAnyCombFlag and SymbolIdx ~= -1 then
                fCombReward = SlotsGameLua:GetSymbol(SymbolIdx).m_fRewards[MatchCount]
            end

            if fCombReward > 0 then
                local fLineBet = SceneSlotGame.m_nTotalBet / #SlotsGameLua.m_listLineLua
                local LineWin = fCombReward * fLineBet
                --local fMultiCoef = self:getLuckyStarValue(deck,)
                local fMultiCoef = 0
                LineWin = LineWin * fMultiCoef

                table.insert(result.m_listWins, WinItem:create(i, SymbolIdx, MatchCount, LineWin, bcond2, nMaxMatchReelID))
                result.m_fSpinWin = result.m_fSpinWin + LineWin
                
                if bSimulationFlag then
                    if nCombIndex == nSymbolCount + 1 or
                         nCombIndex == nSymbolCount + 2 
                    then
                        if not result.m_listTestWinSymbols[nCombIndex] then
                            result.m_listTestWinSymbols[nCombIndex] = TestWinItem:create(nCombIndex)
                        end
                        result.m_listTestWinSymbols[nCombIndex].Hit = result.m_listTestWinSymbols[nCombIndex].Hit + 1
                        result.m_listTestWinSymbols[nCombIndex].WinGold = result.m_listTestWinSymbols[nCombIndex].WinGold + LineWin
                        
                    else
                        if not result.m_listTestWinSymbols[SymbolIdx] then
                            result.m_listTestWinSymbols[SymbolIdx] = TestWinItem:create(SymbolIdx)
                        end
                        result.m_listTestWinSymbols[SymbolIdx].Hit = result.m_listTestWinSymbols[SymbolIdx].Hit + 1
                        result.m_listTestWinSymbols[SymbolIdx].WinGold = result.m_listTestWinSymbols[SymbolIdx].WinGold + LineWin
                    end

                    if not result.m_listTestWinLines[i] then
                        result.m_listTestWinLines[i] = TestWinItem:create(i)
                    end
                    result.m_listTestWinLines[i].Hit = result.m_listTestWinLines[i].Hit + 1
                    result.m_listTestWinLines[i].WinGold = result.m_listTestWinLines[i].Hit + LineWin
                end
            end
        end
    end
    
    --result.m_fGameWin = result.m_fGameWin + result.m_fNonLineBonusWin
    result.m_fGameWin = result.m_fGameWin + result.m_fSpinWin

    return result
end

function WildRespinFunc:getLuckyStarValue(deck)
    local nReelID = 3
    local nkey = SlotsGameLua.m_nRowCount * nReelID + 1
    local nSymbolID = deck[nkey]
    local strTag = SlotsGameLua:GetSymbol(nSymbolID).m_strKindTag
    if strTag == "X1" then
        return 1.0
    end
    if strTag == "X3" then
        return 3.0
    end
    if strTag == "X5" then
        return 5.0
    end
    return 1.0
end

--仿真，把结果 输入到文本文件中
function WildRespinFunc:Simulation()
    self:GetTestResultByRate()
    self:WriteToFile()
end

function WildRespinFunc:GetTestResultByRate()
    local rt = GameResult:create()
    rt:ResetGame(true)

    local preEnumReaturnRateType = SlotsGameLua.m_enumReturnRateType
    
    local nPreTotalBet = SceneSlotGame.m_nTotalBet
    SceneSlotGame.m_nTotalBet = 1

    for i=1, #rt.m_TestWin0Nums do
        rt.m_TestWin0Nums[i] = 0
    end

    local enumSimuType = SlotsGameLua.m_enumSimRateType
    local preSimuType = enumSimuType
    local curSimuType = enumSimuType
    local bPlayerMode = false
    if enumSimuType == enumReturnRateTYPE.enumReturnType_Null then
        curSimuType = enumReturnRateTYPE.enumReturnType_Rate95
        bPlayerMode = true
    end

    SlotsGameLua.m_enumReturnRateType = curSimuType
    ChoiceCommonFunc:CreateChoice()

    local nSimulationCount = SlotsGameLua.m_SimulationCount
    local nRandom = nSimulationCount / 7
    local n300RateSpin = nRandom
    local n140RateSpin = nRandom
    local n50RateSpin = nRandom * 2.0
    local n20RateSpin = nRandom * 2
    local n95RateSpin = nRandom

    local nTotalLuckyStarNum = 0 -- 每次随机到的倍数加起来。。。

    local nWin0Count = 0
    local c = 0
    while true do
        if c >= nSimulationCount then
            break
        end

        if bPlayerMode then
            if(n300RateSpin >= 0) then
                n300RateSpin = n300RateSpin - 1
                curSimuType = enumReturnRateTYPE.enumReturnType_Rate300
            elseif(n140RateSpin >= 0) then
                n300RateSpin = n300RateSpin - 1
                curSimuType = enumReturnRateTYPE.enumReturnType_Rate140
            elseif(n95RateSpin >= 0) then
                n300RateSpin = n300RateSpin - 1
                curSimuType = enumReturnRateTYPE.enumReturnType_Rate95
            elseif(n50RateSpin >= 0) then
                n300RateSpin = n300RateSpin - 1
                curSimuType = enumReturnRateTYPE.enumReturnType_Rate50
            elseif(n20RateSpin >= 0) then
                n300RateSpin = n300RateSpin - 1
                curSimuType = enumReturnRateTYPE.enumReturnType_Rate20
            else
                curSimuType =enumReturnRateTYPE.enumReturnType_Rate95
            end

            if curSimuType ~= preSimuType then
                SlotsGameLua.m_enumReturnRateType = curSimuType
                ChoiceCommonFunc:CreateChoice()
                preSimuType = curSimuType
            end
        end

        local bFlag = rt:Spin()
        local bFreeSpinFlag = rt:InFreeSpin()
        local iDeck = SlotsGameLua:GetDeck(bFreeSpinFlag)

        nTotalLuckyStarNum = nTotalLuckyStarNum + self:getLuckyStarValue(iDeck)

        rt = SlotsGameLua:CheckSpinWinPayLines(iDeck, rt, true)

        if rt.m_fSpinWin <= 0.0 then
            nWin0Count = nWin0Count + 1
        elseif nWin0Count > 0 then
            local nCount = LuaUtil.arraySize(rt.m_TestWin0Nums)
            if nWin0Count > nCount then
                rt.m_TestWin0Nums[nCount] = rt.m_TestWin0Nums[nCount] + 1
            else    
                for i=1,nWin0Count do
                    rt.m_TestWin0Nums[i] = rt.m_TestWin0Nums[i] + 1
                end
            end
            nWin0Count = 0
        else
            --
        end

        c = c + 1
    end

    self.m_nSimulationAvgLuckyStarNum = nTotalLuckyStarNum / c

    SlotsGameLua.m_TestGameResult = rt
    SceneSlotGame.m_nTotalBet = nPreTotalBet  --下注 金额 还原
    SlotsGameLua.m_enumReturnRateType = preEnumReaturnRateType
    ChoiceCommonFunc:CreateChoice()
end

function WildRespinFunc:WriteToFile()
    local strFile = ""
    local levelReturnRateType = SlotsGameLua.m_enumSimRateType
    if levelReturnRateType == enumReturnRateTYPE.enumReturnType_Rate300 then
        strFile = strFile.."===============预测返回率 : 300 ======================\n"
    elseif levelReturnRateType == enumReturnRateTYPE.enumReturnType_Rate140 then
        strFile = strFile.."=============预测返回率 : 140 ========================\n"
    elseif levelReturnRateType == enumReturnRateTYPE.enumReturnType_Rate95 then
        strFile = strFile.."=============预测返回率 : 95 ========================\n"
    elseif levelReturnRateType == enumReturnRateTYPE.enumReturnType_Rate50 then
        strFile = strFile.."=============预测返回率 : 50 ========================\n"
    elseif levelReturnRateType == enumReturnRateTYPE.enumReturnType_Rate20 then
        strFile = strFile.."=============预测返回率 : 20 ========================\n"
    elseif levelReturnRateType == enumReturnRateTYPE.enumReturnType_Null then
        strFile = strFile.."=============预测返回率 : NULL ========================\n"
    end

    local rt = SlotsGameLua.m_TestGameResult
    local TotalBet = 1.0 * SlotsGameLua.m_SimulationCount - rt.m_nFreeSpinAccumCount
    local Ratio = rt.m_fGameWin / TotalBet

    strFile = strFile.."SimulationCount:  "..SlotsGameLua.m_SimulationCount.."\n"
    strFile = strFile.."TotalBets : "..TotalBet.."\n"
    strFile = strFile.."TotalWins : "..rt.m_fGameWin.."\n"
    strFile = strFile.."Return Rate: "..Ratio.."\n"
    strFile = strFile .. "----------------------------------" .. "\n"
    strFile = strFile .. "nSimulationAvgLuckyStarNum: " .. self.m_nSimulationAvgLuckyStarNum .. "\n" .."\n"

    local nSymbolCount = #SlotsGameLua.m_listSymbolLua
    for i=1, nSymbolCount+2 do
        local name = ""
        if i <= nSymbolCount then
            name = SlotsGameLua.m_listSymbolLua[i].prfab.name
        end
        if i==nSymbolCount+1 then
            name = "AnyBar"
        end
        if i==nSymbolCount+2 then
            name = "Any7"
        end

        local nHit = 0
        local fWinGold = 0
        if rt.m_listTestWinSymbols[i] ~= nil then
            nHit = rt.m_listTestWinSymbols[i].Hit
            fWinGold = rt.m_listTestWinSymbols[i].WinGold
        end
       strFile = strFile.."Name: "..name .." | HitWinCount: "..nHit.." | WinGolds: "..fWinGold.."\n"
    end

    local dir =  Unity.Application.dataPath.."/SimulationTest/"
    local path = dir..Scene.themeKey..".txt"
    file = io.open(path, "w");
    if file ~= nil then
        file:write(strFile);
        file:close();
    else
        os.execute("mkdir -p " ..dir)
        os.execute("touch -p "..path)
    end
end