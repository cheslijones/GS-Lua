-- Original: Motenten / Modified: Arislan / Modified: Strumpystrudel
-- Haste/DW Detection Requires Gearinfo Addon

-------------------------------------------------------------------------------------------------------------------
--  Keybinds
-------------------------------------------------------------------------------------------------------------------

--  KB Mods:    [ CTRL ]            ^
--              [ ALT ]             !
--              [ WIN ]             @
--              [ SHIFT ]           ~
--              [ APP KEY ]         #
--
--  Modes:      [ F9 ]              Cycle Offense Modes                             default
--              [ CTRL+F9 ]         Cycle Hybrid Modes                              default
--              [ ALT+F9 ]          Cycle Ranged Mode                               default
--              [ WIN+F9 ]          Cycle Weapon Skill Modes                        default
--              [ F10 ]             Defense Mode Physical                           default
--              [ CTRL+F10 ]        Cycle Physical Defense Modes                    default
--              [ ALT+F10 ]         Toggle Kiting Mode                              default
--              [ F11 ]             Defense Mode Magical                            default
--              [ CTRL+F11 ]        Cycle Magic Defense Modes                       user
--              [ F12 ]             Update Current Gear / Report Current Status     default
--              [ CTRL+F12 ]        Cycle Idle Modes                                default
--              [ ALT+F12 ]         Reset Defense Mode                              default
--              [ CTRL+- ]          Toggle NPC Target Mode                          default
--              [ ALT+- ]           Cycle Combat Weapon                             user
--              [ CTRL+= ]          Cycle PC Target Mode                            default
--              [ ALT+= ]           Cycle Treause Hunter Mode                       user
--
--  Abilities:  [ SHIFT+` ]         Flee                                            user
--              [ CTRL+` ]          Feint                                           user
--              [ ALT+` ]           Hide                                            user     
--              [ SHIFT+1 ]         Sneak Attack                                    user
--              [ SHIFT+2 ]         Trick Attack                                    user
--              [ SHIFT+3 ]         Rudra's Storm                                   user
--              [ SHIFT+4 ]         Mandalic Stab                                   user
--              [ SHIFT+5 ]         Evisceration                                    user
--              [ SHIFT+6 ]         Shark Bite                                      user
--              [ SHIFT+7 ]         Aeolian Edge                                    user
--
--              (Global-Binds.lua contains additional non-job-related keybinds)
--
--  TH Modes:  None                 Will never equip TH gear
--             Tag                  Will equip TH gear sufficient for initial contact with a mob (either melee,
--             SATA                 Will equip TH gear sufficient for initial contact with a mob, and when using SATA
--             Fulltime             Will keep TH gear equipped fulltime

-------------------------------------------------------------------------------------------------------------------
-- Setup functions for this job.  Generally should not be modified.
-------------------------------------------------------------------------------------------------------------------

-- Initialization function for this job file.
function get_sets()
    mote_include_version = 2
    
    -- Load and initialize the include file.
    include('Mote-Include.lua')
end

-- Setup vars that are user-independent.  state.Buff vars initialized here will automatically be tracked.
function job_setup()
    state.Buff['Sneak Attack'] = buffactive['sneak attack'] or false
    state.Buff['Trick Attack'] = buffactive['trick attack'] or false
    state.Buff['Feint'] = buffactive['feint'] or false
    
    include('Mote-TreasureHunter')

    -- For th_action_check():
    -- JA IDs for actions that always have TH: Provoke, Animated Flourish
    info.default_ja_ids = S{35, 204}
    -- Unblinkable JA IDs for actions that always have TH: Quick/Box/Stutter Step, Desperate/Violent Flourish
    info.default_u_ja_ids = S{201, 202, 203, 205, 207}

    lockstyleset = 23
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options('Normal', 'Hybrid', 'PDT') -- F9
    state.PhysicalDefenseMode:options('PDT', 'Eva') -- ^F10
    state.MagicalDefenseMode:options('MDT', 'MEva') -- ^F11
    state.IdleMode:options('Normal', 'Movement', 'Regen', 'Regain') -- ^F12
    state.CombatWeapon = M('Rudra', 'Evisceration', 'AOE', 'Trial', 'Low') -- !F9

    -- Additional local binds
    include('Global-Binds.lua') -- OK to remove this line

    -- Additional local binds
    send_command('bind !- gs c cycle CombatWeapon')
    send_command('bind != gs c cycle treasuremode')
	send_command('bind ^f11 gs c cycle MagicalDefenseMode')
    send_command('bind ~` input /ja "Flee" <me>')
    send_command('bind ^` input /ja "Feint" <me>')
    send_command('bind !` input /ja "Hide" <me>')
    send_command('bind ~1 input /ja "Sneak Attack" <me>')
    send_command('bind ~2 input /ja "Trick Attack" <me>')
    send_command('bind ~3 input /ws "Rudra\'s Storm" <t>')
    send_command('bind ~4 input /ws "Mandalic Stab" <t>')
    send_command('bind ~5 input /ws "Evisceration" <t>')
    send_command('bind ~6 input /ws "Shark Bite" <t>')
    send_command('bind ~7 input /ws "Aeolian Edge" <t>')
    send_command('bind ~8 input /ja "Conspirator" <me>')

    select_default_macro_book()
    set_lockstyle()
end

-- Called when this job file is unloaded (eg: job change)
function user_unload()
    send_command('unbind ~a')
    send_command('unbind ~s')
    send_command('unbind ~f12')
    send_command('unbind ~^1')
    send_command('unbind ~^2')
    send_command('unbind ~^3')
    send_command('unbind ~`')
    send_command('unbind ^`')
    send_command('unbind !`')
    send_command('unbind ^-')
    send_command('unbind ^=')
    send_command('unbind !-')
    send_command('unbind !=')
    send_command('unbind ~=')
    send_command('unbind ~-')
    send_command('unbind ![')
    send_command('unbind !]')
    send_command('unbind ^[')
    send_command('unbind ^]')
    send_command('unbind ~[')
    send_command('unbind ~]')
    send_command('unbind ~\'')
    send_command('unbind ~space')
    send_command('unbind ~1')
    send_command('unbind ~2')
    send_command('unbind ~3')
    send_command('unbind ~4')
    send_command('unbind ~5')
    send_command('unbind ~6')
    send_command('unbind ~7')
    send_command('unbind ~8')
    send_command('unbind ~9')
    send_command('unbind ~0')
    send_command('unbind ~,')
    send_command('unbind ~.')
    send_command('unbind ~/')
    send_command('unbind ^,')
    send_command('unbind ^.')
    send_command('unbind ^/')
    send_command('unbind !,')
    send_command('unbind !.')
    send_command('unbind !/')
    send_command('unbind ~^,')
    send_command('unbind ~^.')
    send_command('unbind ~^/')
    send_command('unbind ~!,')
    send_command('unbind ~!.')
    send_command('unbind ~!/')

end

-- Define sets and vars used by this job file.
function init_gear_sets()

    --------------------------------------
    -- Special sets (required by rules)
    --------------------------------------
    -- TH Base +3
    -- TH Max Initial Proc +9
    sets.TreasureHunter = {
        ammo="Per. Lucky Egg", -- TH+1
        head="Wh. Rarab Cap +1", -- TH+1
        hands={ name="Plun. Armlets +3", augments={'Enhances "Perfect Dodge" effect',}}, -- TH+4
    }

    sets.MovementSpeed = {
        feet="Pill. Poulaines +3",       
    }

    --------------------------------------
    -- Weapon sets
    --------------------------------------

    -- Rudra's Storm
    sets.Rudra = {
        main={ name="Aeneas", augments={'Path: A',}},
        sub="Gleti's Knife",
    }

    -- Eviscerate
    sets.Evisceration = {
        main="Tauret",
        sub="Gleti's Knife",
    }

    -- AOE
    sets.AOE = {
        main={ name="Gandring", augments={'Path: C',}},
        sub="Tauret",
    }

    -- Trial
    sets.Trial = {
        main={ name="Renegade", augments={'Attack+3',}},
        sub="Tauret",
    }

    -- Low DMG
    sets.Low = {
        main="Bronze Knife",
        sub="Bronze Knife",
    }

    --------------------------------------
    -- Precast sets
    --------------------------------------

    -- Precast sets to enhance JAs in order of unlock
    sets.precast.JA['Perfect Dodge'] = {
        hands={ name="Plun. Armlets +3", augments={'Enhances "Perfect Dodge" effect',}},
    }
    sets.precast.JA['Steal'] = sets.MovementSpeed
    sets.precast.JA['Sneak Attack'] = {
        hands="Skulk. Armlets +2",
    }
    sets.precast.JA['Flee'] = sets.MovementSpeed
    sets.precast.JA['Trick Attack'] = {
        body={ name="Plunderer's Vest +3", augments={'Enhances "Ambush" effect',}},
        hands="Pill. Armlets +3",
    }
    sets.precast.JA['Mug'] = {
        head={ name="Plun. Bonnet +3", augments={'Enhances "Aura Steal" effect',}}, 
    }
    sets.precast.JA['Hide'] = {
        body="Pillager's Vest +3",
    }
    sets.precast.JA['Accomplice'] = {
        head="Skulker's Bonnet +2",
    }
    sets.precast.JA['Collaborator'] = {
        head="Skulker's Bonnet +2",
    }
    sets.precast.JA['Assassin\'s Charge'] = {
        feet={ name="Plun. Poulaines +3", augments={'Enhances "Assassin\'s Charge" effect',}},
    }
    sets.precast.JA['Feint'] = {
        legs={ name="Plun. Culottes +3", augments={'Enhances "Feint" effect',}},
    }
    sets.precast.JA['Despoil'] = {
        legs="Skulk. Culottes +2",
        feet="Skulk. Poulaines +2",
    }
    sets.precast.JA['Conspirator'] = {
        body="Skulker's Vest +2",
    }
    sets.precast.JA['Bully'] = {}
    sets.precast.JA['Larceny'] = {}
    
    --------------------------------------
    -- Weapon skill sets
    --------------------------------------

    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {
        ammo="Crepuscular Pebble",
        head={ name="Plun. Bonnet +3", augments={'Enhances "Aura Steal" effect',}},
        body={ name="Plunderer's Vest +3", augments={'Enhances "Ambush" effect',}},
        hands="Meg. Gloves +2",
        legs={ name="Plun. Culottes +3", augments={'Enhances "Feint" effect',}},
        feet={ name="Plun. Poulaines +3", augments={'Enhances "Assassin\'s Charge" effect',}},
        neck={ name="Asn. Gorget +2", augments={'Path: A',}},
        waist={ name="Kentarch Belt +1", augments={'Path: A',}},
        left_ear="Sherida Earring",
        right_ear={ name="Moonshade Earring", augments={'"Mag.Atk.Bns."+4','TP Bonus +250',}},
        left_ring="Karieyh Ring",
        right_ring="Cornelia's Ring",
        back={ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','Weapon skill damage +10%','Phys. dmg. taken-10%',}},
    }

    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
    sets.precast.WS["Rudra's Storm"] = sets.precast.WS
    sets.precast.WS['Mandalic Stab'] = sets.precast.WS
    sets.precast.WS['Evisceration'] = {
        ammo="Yetshila +1",
        head="Skulker's Bonnet +2",
        body={ name="Plunderer's Vest +3", augments={'Enhances "Ambush" effect',}},
        hands="Gleti's Gauntlets",
        legs="Gleti's Breeches",
        feet="Gleti's Boots",
        neck="Fotia Gorget",
        waist="Fotia Belt",
        left_ear="Odr Earring",
        right_ear="Sherida Earring",
        left_ring="Karieyh Ring",
        right_ring="Cornelia's Ring",
        back={ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','Crit.hit rate+10','Phys. dmg. taken-10%',}},
    }    
    
    sets.precast.WS['Exenterator'] = sets.precast.WS
    sets.precast.WS['Dancing Edge'] = sets.precast.WS
    sets.precast.WS["Shark Bite"] = sets.precast.WS

    sets.precast.WS['Aeolian Edge'] = {
        ammo={ name="Ghastly Tathlum +1", augments={'Path: A',}},
        head="Nyame Helm",
        body="Nyame Mail",
        hands="Nyame Gauntlets",
        legs="Nyame Flanchard",
        feet="Nyame Sollerets",
        neck="Sibyl Scarf",
        waist="Orpheus's Sash",
        left_ear="Friomisi Earring",
        right_ear={ name="Moonshade Earring", augments={'"Mag.Atk.Bns."+4','TP Bonus +250',}},
        left_ring="Karieyh Ring",
        right_ring="Cornelia's Ring",
        back={ name="Toutatis's Cape", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','INT+10','Weapon skill damage +10%','Phys. dmg. taken-10%',}},
    }
    sets.precast.WS['Aeolian Edge'].TH = set_combine(sets.precast.WS['Aeolian Edge'], sets.TreasureHunter)

    --------------------------------------
    -- Midcast sets
    --------------------------------------

    --------------------------------------
    -- Idle sets
    --------------------------------------

    -- Idle sets (default idle set not needed since the other three are defined, but leaving for testing purposes)
    sets.idle = {
        ammo="Aurgelmir Orb +1",
        head="Turms Cap +1",
        body="Tu. Harness +1",
        hands="Turms Mittens +1",
        legs="Turms Subligar +1",
        feet="Turms Leggings +1",
        neck={ name="Bathy Choker +1", augments={'Path: A',}},
        waist="Chiner's Belt +1",
        left_ear="Infused Earring",
        right_ear="Eabani Earring",
        left_ring="Chirich Ring +1",
        right_ring="Chirich Ring +1",
        back={ name="Toutatis's Cape", augments={'AGI+20','Eva.+20 /Mag. Eva.+20','Evasion+10','Evasion+15',}},
    }

    sets.idle.Regen = sets.idle

    sets.idle.Regain = {
        ammo="Aurgelmir Orb +1",
        head="Turms Cap +1",
        body="Gleti's Cuirass",
        hands="Gleti's Gauntlets",
        legs="Gleti's Breeches",
        feet="Gleti's Boots",
        neck={ name="Bathy Choker +1", augments={'Path: A',}},
        waist="Chiner's Belt +1",
        left_ear="Infused Earring",
        right_ear="Eabani Earring",
        left_ring="Chirich Ring +1",
        right_ring="Karieyh Ring",
        back={ name="Toutatis's Cape", augments={'AGI+20','Eva.+20 /Mag. Eva.+20','Evasion+10','Evasion+15',}},
    }

    sets.idle.Movement = set_combine(sets.idle.Regen, sets.MovementSpeed)

    sets.idle.Town = sets.idle.MovementSpeed
    sets.idle.Field = sets.idle.MovementSpeed

    --------------------------------------
    -- Defense sets
    --------------------------------------

    -- Physical damage taken
    sets.defense.PDT = {
        ammo="Aurgelmir Orb +1",
        head="Skulker's Bonnet +2",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        legs="Gleti's Breeches",
        feet="Malignance Boots",
        neck={ name="Asn. Gorget +2", augments={'Path: A',}},
        waist="Reiki Yotai",
        left_ear="Sherida Earring",
        right_ear={ name="Skulker's Earring", augments={'System: 1 ID: 1676 Val: 0','Accuracy+6','Mag. Acc.+6',}},
        left_ring="Defending Ring",
        right_ring="Moonlight Ring",
        back={ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10','Phys. dmg. taken-10%',}},
    }

    -- Magic damage taken
    sets.defense.MDT = sets.defense.PDT

    -- Evasion
    sets.defense.Eva = {
        ammo="Aurgelmir Orb +1",
        head="Malignance Chapeau",
        body="Malignance Tabard",
        hands="Turms Mittens +1",
        legs="Malignance Tights",
        feet="Turms Leggings +1",
        neck={ name="Asn. Gorget +2", augments={'Path: A',}},
        waist="Reiki Yotai",
        left_ear="Eabani Earring",
        right_ear={ name="Skulker's Earring", augments={'System: 1 ID: 1676 Val: 0','Accuracy+6','Mag. Acc.+6',}},
        left_ring="Shadow Ring",
        right_ring="Moonlight Ring",
        back={ name="Toutatis's Cape", augments={'AGI+20','Eva.+20 /Mag. Eva.+20','Evasion+10','Evasion+15',}},
    }

    -- Magic Evasion
    sets.defense.MEva = set_combine(
        sets.defense.Eva, {
            hands="Malignance Gloves",
            feet="Malignance Boots",
            waist="Plat. Mog. Belt",
            right_ear="Infused Earring",
            left_ring="Shadow Ring",
            back={ name="Toutatis's Cape", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Mag. Evasion+15',}},
        }
    )

    --------------------------------------
    -- Melee sets
    --------------------------------------

    -- Normal
    sets.engaged = {
        ammo="Aurgelmir Orb +1",
        head="Skulker's Bonnet +2",
        body="Pillager's Vest +3",
        hands={ name="Adhemar Wrist. +1", augments={'DEX+12','AGI+12','Accuracy+20',}},
        legs="Meg. Chausses +2",
        feet={ name="Plun. Poulaines +3", augments={'Enhances "Assassin\'s Charge" effect',}},
        neck={ name="Asn. Gorget +2", augments={'Path: A',}},
        waist="Reiki Yotai",
        left_ear="Sherida Earring",
        right_ear={ name="Skulker's Earring", augments={'System: 1 ID: 1676 Val: 0','Accuracy+6','Mag. Acc.+6',}},
        left_ring="Epona's Ring",
        right_ring="Moonlight Ring",
        back={ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10','Phys. dmg. taken-10%',}},
    }

    -- Hybrid
    sets.engaged.Hybrid = set_combine(
        sets.engaged, {
            hands="Malignance Gloves",
            legs="Malignance Tights",
        }
    )

    -- PDT
    sets.engaged.PDT = sets.defense.PDT

    --------------------------------------
    -- Kiting set
    --------------------------------------

    sets.Kiting = set_combine(sets.defense.Eva, sets.MovementSpeed)

    --------------------------------------
    --Subjob sets
    --------------------------------------

    -- DNC subjob
    sets.precast.JA['Chocobo Jig'] = sets.MovementSpeed
    sets.precast.JA['Spectral Jig'] = sets.MovementSpeed
    sets.precast.Waltz = gear.DNC_Sub_Waltz

    -- WAR subjob

    -- NIN subjob

    -- DRG subjob

end


-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Run after the general precast() is done.
function job_post_precast(spell, action, spellMap, eventArgs)
    if spell.english == 'Aeolian Edge' and state.TreasureMode.value ~= 'None' then
        equip(sets.TreasureHunter)
    elseif spell.english=='Sneak Attack' or spell.english=='Trick Attack' or spell.type == 'WeaponSkill' then
        if state.TreasureMode.value == 'SATA' or state.TreasureMode.value == 'Fulltime' then
            equip(sets.TreasureHunter)
        end
    end
end

-- Run after the general midcast() set is constructed.
function job_post_midcast(spell, action, spellMap, eventArgs)
    if state.TreasureMode.value ~= 'None' and spell.action_type == 'Ranged Attack' then
        equip(sets.TreasureHunter)
    end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Weaponskills wipe SATA/Feint.  Turn those state vars off before default gearing is attempted.
    if spell.type == 'WeaponSkill' and not spell.interrupted then
        state.Buff['Sneak Attack'] = false
        state.Buff['Trick Attack'] = false
        state.Buff['Feint'] = false
    end
end

-- Called after the default aftercast handling is complete.
function job_post_aftercast(spell, action, spellMap, eventArgs)
    -- If Feint is active, put that gear set on on top of regular gear.
    -- This includes overlaying SATA gear.
    check_buff('Feint', eventArgs)
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for non-casting events.
-------------------------------------------------------------------------------------------------------------------

-- Called when a player gains or loses a buff.
-- buff == buff gained or lost
-- gain == true if the buff was gained, false if it was lost.
function job_buff_change(buff, gain)
    if state.Buff[buff] ~= nil then
        if not midaction() then
            handle_equipping_gear(player.status)
        end
    end
end


-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

function get_custom_wsmode(spell, spellMap, defaut_wsmode)
    local wsmode

    if state.Buff['Sneak Attack'] then
        wsmode = 'SA'
    end
    if state.Buff['Trick Attack'] then
        wsmode = (wsmode or '') .. 'TA'
    end

    return wsmode
end


-- Called any time we attempt to handle automatic gear equips (ie: engaged or idle gear).
function job_handle_equipping_gear(playerStatus, eventArgs)
    -- Check that ranged slot is locked, if necessary
    check_range_lock()

    -- Check for SATA when equipping gear.  If either is active, equip
    -- that gear specifically, and block equipping default gear.
    check_buff('Sneak Attack', eventArgs)
    check_buff('Trick Attack', eventArgs)
end


function customize_idle_set(idleSet)

    return set_combine(idleSet, change_weapon_set())
end


function customize_melee_set(meleeSet)
    if state.TreasureMode.value == 'Fulltime' then
        meleeSet = set_combine(meleeSet, sets.TreasureHunter)
    end

    return set_combine(meleeSet, change_weapon_set())
end


function change_weapon_set() 
    -- if state.CombatWeapon.value == 'Rudra' then
    --     return sets.Rudra
    -- else if state.CombatWeapon.value == 'Evisceration' then
    --     return sets.Evisceration
    -- else if state.CombatWeapon.value == 'AOE' then
    --     return sets.AOE
    -- else if state.CombatWeapon.value == 'Trial' then
    --     return sets.Trial
    -- end
    return sets[state.CombatWeapon.value]
end

-- Called by the 'update' self-command.
function job_update(cmdParams, eventArgs)
    th_update(cmdParams, eventArgs)
end

-- Function to display the current relevant user state when doing an update.
-- Return true if display was handled, and you don't want the default info shown.
function display_current_job_state(eventArgs)
    local msg = 'Melee'
    
    if state.CombatForm.has_value then
        msg = msg .. ' (' .. state.CombatForm.value .. ')'
    end
    
    msg = msg .. ': '
    
    msg = msg .. state.OffenseMode.value
    if state.HybridMode.value ~= 'Normal' then
        msg = msg .. '/' .. state.HybridMode.value
    end
    msg = msg .. ', WS: ' .. state.WeaponskillMode.value
    
    if state.DefenseMode.value ~= 'None' then
        msg = msg .. ', ' .. 'Defense: ' .. state.DefenseMode.value .. ' (' .. state[state.DefenseMode.value .. 'DefenseMode'].value .. ')'
    end
    
    if state.Kiting.value == true then
        msg = msg .. ', Kiting'
    end

    if state.PCTargetMode.value ~= 'default' then
        msg = msg .. ', Target PC: '..state.PCTargetMode.value
    end

    if state.SelectNPCTargets.value == true then
        msg = msg .. ', Target NPCs'
    end
    
    msg = msg .. ', TH: ' .. state.TreasureMode.value

    add_to_chat(122, msg)

    eventArgs.handled = true
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

-- State buff checks that will equip buff gear and mark the event as handled.
function check_buff(buff_name, eventArgs)
    if state.Buff[buff_name] then
        equip(sets.buff[buff_name] or {})
        if state.TreasureMode.value == 'SATA' or state.TreasureMode.value == 'Fulltime' then
            equip(sets.TreasureHunter)
        end
        eventArgs.handled = true
    end
end


-- Check for various actions that we've specified in user code as being used with TH gear.
-- This will only ever be called if TreasureMode is not 'None'.
-- Category and Param are as specified in the action event packet.
function th_action_check(category, param)
    if category == 2 or -- any ranged attack
        --category == 4 or -- any magic action
        (category == 3 and param == 30) or -- Aeolian Edge
        (category == 6 and info.default_ja_ids:contains(param)) or -- Provoke, Animated Flourish
        (category == 14 and info.default_u_ja_ids:contains(param)) -- Quick/Box/Stutter Step, Desperate/Violent Flourish
        then return true
    end
end


-- Function to lock the ranged slot if we have a ranged weapon equipped.
function check_range_lock()
    if player.equipment.range ~= 'empty' then
        disable('range', 'ammo')
    else
        enable('range', 'ammo')
    end
end


-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    -- Default macro set/book
    if player.sub_job == 'DNC' then
        set_macro_page(1, 6)
    elseif player.sub_job == 'WAR' then
        set_macro_page(2, 6)
    elseif player.sub_job == 'NIN' then
        set_macro_page(3, 6)
    elseif player.sub_job == 'DRG' then
        set_macro_page(4, 6)
    else
        set_macro_page(1, 6)
    end
end

function set_lockstyle()
    send_command('wait 2; input /lockstyleset ' .. lockstyleset)
end