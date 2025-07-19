gScp2000 = gScp2000 or {}

gScp2000.SaveHook = "gScp2000SaveInfo"
gScp2000.LoadHook = "gScp2000LoadInfo"
gScp2000.TimerName = "gScp2000SaveTimer"
gScp2000.TimerDelay = 60 -- Seconds | Easiest to keep in 60 seconds interval
gScp2000.SavedTimes = {} -- Save the state of saved times, so we can overwrite values once they are passed
gScp2000.Cooldown = 3600 -- Seconds -> hours
gScp2000.LastUse = nil
gScp2000.Insertions = 0

hook.Add("DarkRPFinishedLoading", "gScp2000_InitializeAllowedTeams", function()
    gScp2000.AllowedTeams = {
        [TEAM_CITIZEN] = true
    }
end)

gScp2000.AllowedTimes = {
    ONE_MINUTE   = 1,
    TWO_MINUTES  = 2,
    THREE_MINUTES = 3,
    FOUR_MINUTES = 4,
    FIVE_MINUTES = 5,
    SIX_MINUTES  = 6,
    SEVEN_MINUTES = 7,
    EIGHT_MINUTES = 8,
    NINE_MINUTES = 9,
    TEN_MINUTES  = 10
}

gScp2000.MaxNodes = table.Count(gScp2000.AllowedTimes) -- Correlation :)
gScp2000.Cooldown = 3600 -- once an hour usage
if (SERVER) then
    if timer.Exists(gScp2000.TimerName) then
        timer.Remove(gScp2000.TimerName)
    end

    timer.Create(gScp2000.TimerName, gScp2000.TimerDelay, 0, function()
        gScp2000.SaveState()
        print("Saving")
        gScp2000.PrintList()
    end)

    function gScp2000.PrintList()
        local head = gScp2000.List

        if not head.next then
            return
        end

        local current = head.next

        while current.next do
            --PrintTable(current.info)
            current = current.next
        end
    end
end

--Use a linked list to store information, which we need to correlate to allowed times
gScp2000.List = {next = nil, info = nil, time = nil}

function gScp2000.AddToList(state)
    local newNode = {
        next = nil,
        info = state,
        time = CurTime()
    }

    local head = gScp2000.List

    if not head.next then
        head.next = newNode
        return
    end

    local count = 1
    local prev = head
    local current = head.next

    while current.next do
        count = count + 1
        prev = current
        current = current.next
    end

    current.next = newNode
    count = count + 1

    if count > gScp2000.MaxNodes then
        head.next = head.next.next -- I fucking love the stupidity of linked lists
    end
end

function gScp2000.SaveState()
    hook.Run(gScp2000.SaveHook)
    local playerState = {}
    local entityState = {}

    for _, ply in player.Iterator() do
        if (IsValid(ply)) then
            local ins = {}

            ins.pos = ply:GetPos()
            ins.weapon = IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass()
            ins.angle = ply:EyeAngles()

            playerState[ply:SteamID()] = ins
        end
    end

    for _, ent in ents.Iterator() do
        if (IsValid(ent)) then
            if (ent:IsPlayer()) then
                continue 
            end

            local ins = {}

            ins.pos = ent:GetPos()
            ins.angle = ent:GetAngles()

            entityState[ent:EntIndex()] = ins
        end
    end

    local stateSnap = {
        players = playerState,
        entities = entityState
    }

    gScp2000.AddToList(stateSnap)
    gScp2000.Insertions = gScp2000.Insertions + 1
end

function gScp2000.GetNode(num)
    local head = gScp2000.List
    local counter = 1

    if (num == 1) then --Head is the first node
        return head.next
    end

    while ((counter < num) and (head) and (head.next)) do
        head = head.next
        
        counter = counter + 1
    end

    return head
end

function gScp2000.CheckUse()
    local time = CurTime()
    local lastTime = gScp2000.LastUse

    if (not lastTime or (time - lastTime) >= gScp2000.Cooldown) then
        gScp2000.LastUse = CurTime()
        return true 
    end 

    return false
end

--Time correlates to the enum of gScp2000.AllowedTimes, where 1, 2, 3 correlate to the node in the linked list to reset the time to
function gScp2000.LoadState(num)
    if (gScp2000.Insertions < num) then
        return
    end

    if (not gScp2000.CheckUse()) then
        return
    end
    hook.Run(gScp2000.LoadHook)

    local node = gScp2000.GetNode(num)

    if (not node) then
        return 
    end

    local players = node.info.players or {}
    local entities = node.info.entities or {}

    if (not players) then
        return 
    end

    if (not entities) then 
        return
    end

    PrintTable(players)

    if (table.IsEmpty(players)) then
        return 
    end

    if (table.IsEmpty(entities)) then
        return 
    end

    for _, ply in player.Iterator() do
        if (IsValid(ply)) then
            local steamID = ply:SteamID()
            local pInfo = players[steamID]

            if (table.IsEmpty(pInfo)) then
                continue
            end

            ply:SetPos(pInfo.pos or ply:GetPos())
            ply:SetEyeAngles(pInfo.angle or ply:GetEyeAngles())

            if pInfo.weapon then
                ply:Give(pInfo.weapon)
                ply:SelectWeapon(pInfo.weapon)
            end
        end
    end

    for _, ent in ents.Iterator() do
        if (IsValid(ent)) then
            if (ent:IsPlayer()) then
                continue
            end

            local entInfo = entities[ent:EntIndex()]
            if (not entInfo) then 
                continue 
            end

            ent:SetPos(entInfo.pos or ent:GetPos())
            ent:SetAngles(entInfo.angle or ent:GetAngles())
        end
    end
end