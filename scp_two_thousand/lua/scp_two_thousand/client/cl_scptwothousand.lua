include("scp_two_thousand/sh_scptwothousand.lua")

net.Receive("scp_twothousand_open_menu", function()
    gScp2000.OpenMenu()
end)

function gScp2000.OpenMenu()
    local frame = vgui.Create("DFrame")
    local w, h = ScrW(), ScrH()

    local nW, nH = w * 0.5, h * 0.3
    frame:SetSize(nW, nH)
    frame:Center()
    frame:SetTitle("")

    local container = vgui.Create("DScrollPanel", frame)
    container:Dock(FILL)
    container:SetSize(nW * 0.5, nH)
    container:SetPos(nW / 2, 0)

    for i = 1, gScp2000.MaxNodes do
        local button = vgui.Create("DButton", container)
        button:Dock(TOP)
        button:DockMargin(5, 5, 5, 5)
        if (i == 1) then
            button:SetText(i .. " Minute")
        else
            button:SetText(i .. " Minutes")
        end

        button.DoClick = function()
            net.Start("gScp2000_RewindTime")
            net.WriteUInt(i, 3)
            net.SendToServer()
        end

        container:AddItem(button)
    end
end