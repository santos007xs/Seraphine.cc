-- ============================================
-- BYPASS ADONIS MODULE
-- ============================================

local Bypass = {}

function Bypass:Execute()
    local success, err = pcall(function()
        setthreadidentity(2)
        
        local Detected, Kill
        
        for i, v in getgc(true) do
            if typeof(v) == "table" then
                local DetectFunc = rawget(v, "Detected")
                local KillFunc = rawget(v, "Kill")
            
                if typeof(DetectFunc) == "function" and not Detected then
                    Detected = DetectFunc
                    
                    hookfunction(Detected, function(Action, Info, NoCrash)
                        return true
                    end)
                end
                
                if rawget(v, "Variables") and rawget(v, "Process") and typeof(KillFunc) == "function" and not Kill then
                    Kill = KillFunc
                    
                    hookfunction(Kill, function(Info)
                    end)
                end
            end
        end
        
        hookfunction(getrenv().debug.info, newcclosure(function(...)
            local LevelOrFunc, Info = ...
            if Detected and LevelOrFunc == Detected then
                return coroutine.yield(coroutine.running())
            end
            
            return debug.info(...)
        end))
        
        setthreadidentity(7)
    end)
    
    return success, err
end

return Bypass
