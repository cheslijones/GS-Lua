-------------------------------------------------------------------------------------------------------------------
--  Global Keybinds
-------------------------------------------------------------------------------------------------------------------
--
--  Spells /    [ CTRL+, ]         Haste Samba / Utsusemi: Ichi / Provoke / Jump / Silent Oil
--  Abilities   [ CTRL+. ]         Spectral Jig / Utsusemi: Ni / Berserk / High Jump / Prism Powder
--              [ CTRL+/ ]         Chocobo Jig Aggressor / Super Jump
--              [ ALT+, ]          Curing Waltz III / Monomi: Ichi / Warcry
--              [ ALT+. ]          Healing Waltz / Tonko: Ni / Defender
--              [ ALT+/ ]          Divine Waltz
--              [ CTRL+SHIFT+, ]   Quickstep / Yonnin
--              [ CTRL+SHIFT+. ]   Box Step / Innin
--              [ CTRL+SHIFT+/ ]   Stutter Step
--              [ ALT+SHIFT+, ]    Animated Flourish
--              [ ALT+SHIFT+. ]    Reverse Flourish
--              [ ALT+SHIFT+/ ]    Building Flourish
--
--              (Global-Binds.lua contains additional non-job-related keybinds)
--
-------------------------------------------------------------------------------------------------------------------

-- Sub jobs
if player.sub_job == 'DNC' then
    -- Instantiate local vars
    local contradance = ''

    -- Jigs
    send_command('bind ^, input /ja "Haste Samba" <me>')
    send_command('bind ^. input /ja "Spectral Jig" <me>')
    -- Check if Chcobo jig can be used
    if player.sub_job_level >= 55 then
        send_command('bind ^/ input /ja "Chocobo Jig" <me>')
    end
    
    -- Waltz
    -- First check if contradance can be appended
    if player.sub_job_level >= 50 then
        contradance = 'input /ja "Contradance" <me>;'
    end
    send_command('bind !, ' .. contradance .. 'input /ja "Curing Waltz III" <stpc>')
    send_command('bind !. ' .. contradance .. 'input /ja "Healing Waltz" <stpc>')
    send_command('bind !/ ' .. contradance .. 'input /ja "Divine Waltz" <stpc>')

    -- Steps
    send_command('bind ~^, input /ja "Quickstep" <t>')
    send_command('bind ~^. input /ja "Box Step" <t>')
    send_command('bind ~^/ input /ja "Stutter Step" <t>')

    -- Flourishes
    send_command('bind ~!/, input /ja "Animated Flourish" <t>')
    send_command('bind ~!/. input /ja "Reverse Flourish" <t>')
    -- Check if Chcobo jig can be used
    if player.sub_job_level >= 50 then
        send_command('bind ~!/ input /ja "Building Flourish" <t>')
    end

elseif player.sub_job == 'NIN' then
    send_command('bind ^, input /ma "Utsusemi: Ichi" <me>')
    send_command('bind ^. input /ma "Utsusemi: Ni" <me>')
    send_command('bind !, input /ma "Monomi: Ichi" <me> ')
    send_command('bind !. input /ma "Tonko: Ni" <me>')
    send_command('bind ~^, input /ma "Yonnin" <me>')
    send_command('bind ~^. input /ma "Innin" <me>')

elseif player.sub_job == 'WAR' then
    send_command('bind ^, input /ja "Provoke" <stnpc>')
    send_command('bind ^. input /ja "Berserk" <me>')
    send_command('bind ^/ input /ja "Aggressor" <me>')
    send_command('bind !, input /ja "Warcry" <me>')
    send_command('bind !. input /ja "Defender" <me>')

elseif player.sub_job == 'DRG' then
    send_command('bind ^, input /ja "Jump" <t>')
    send_command('bind ^. input /ja "High Jump" <t>')
    if player.sub_job_level >= 50 then
        send_command('bind ^/ input /ja "Super Jump" <t>') 
    end
else
    send_command('bind ^, input /item "Silent Oil" <me>')
    send_command('bind ^. input /item "Prism Powder" <me>')

end