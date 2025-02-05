-- Original: Motenten / Modified: Arislan
-- Haste/DW Detection Requires Gearinfo Addon

-------------------------------------------------------------------------------------------------------------------
--  Keybinds
-------------------------------------------------------------------------------------------------------------------

--  Modes:      [ F9 ]              Cycle Offense Modes
--              [ CTRL+F9 ]         Cycle Hybrid Modes
--              [ ALT+F9 ]          Cycle Ranged Modes
--              [ WIN+F9 ]          Cycle Weapon Skill Modes
--              [ F10 ]             Emergency -PDT Mode
--              [ ALT+F10 ]         Toggle Kiting Mode
--              [ F11 ]             Emergency -MDT Mode
--              [ F12 ]             Update Current Gear / Report Current Status
--              [ CTRL+F12 ]        Cycle Idle Modes
--              [ ALT+F12 ]         Cancel Emergency -PDT/-MDT Mode
--              [ WIN+C ]           Toggle Capacity Points Mode
--              [ WIN+` ]           Toggle use of Luzaf Ring.
--              [ WIN+Q ]           Quick Draw shot mode selector.
--
--  Abilities:  [ CTRL+- ]          Quick Draw primary shot element cycle forward.
--              [ CTRL+= ]          Quick Draw primary shot element cycle backward.
--              [ ALT+- ]           Quick Draw secondary shot element cycle forward.
--              [ ALT+= ]           Quick Draw secondary shot element cycle backward.
--              [ CTRL+[ ]          Quick Draw toggle target type.
--              [ CTRL+] ]          Quick Draw toggle use secondary shot.
--
--              [ CTRL+C ]          Crooked Cards
--              [ CTRL+` ]          Double-Up
--              [ CTRL+X ]          Fold
--              [ CTRL+S ]          Snake Eye
--              [ CTRL+NumLock ]    Triple Shot
--              [ CTRL+Numpad/ ]    Berserk
--              [ CTRL+Numpad* ]    Warcry
--              [ CTRL+Numpad- ]    Aggressor
--
--  Spells:     [ WIN+, ]           Utsusemi: Ichi
--              [ WIN+. ]           Utsusemi: Ni
--
--  Weapons:    [ WIN+E/R ]         Cycles between available Weapon Sets
--              [ WIN+W ]           Toggle Ranged Weapon Lock
--
--  WS:         [ CTRL+Numpad7 ]    Savage Blade
--              [ CTRL+Numpad8 ]    Last Stand
--              [ CTRL+Numpad4 ]    Leaden Salute
--              [ CTRL+Numpad5 ]    Requiescat
--              [ CTRL+Numpad6 ]    Wildfire
--              [ CTRL+Numpad1 ]    Aeolian Edge
--              [ CTRL+Numpad2 ]    Evisceration
--
--  RA:         [ Numpad0 ]         Ranged Attack
--
--
--              (Global-Binds.lua contains additional non-job-related keybinds)


-------------------------------------------------------------------------------------------------------------------
--  Custom Commands (preface with /console to use these in macros)
-------------------------------------------------------------------------------------------------------------------

--  gs c qd                         Uses the currently configured shot on the target, with either <t> or
--                                  <stnpc> depending on setting.
--  gs c qd t                       Uses the currently configured shot on the target, but forces use of <t>.
--
--  gs c cycle mainqd               Cycles through the available steps to use as the primary shot when using
--                                  one of the above commands.
--  gs c cycle altqd                Cycles through the available steps to use for alternating with the
--                                  configured main shot.
--  gs c toggle usealtqd            Toggles whether or not to use an alternate shot.
--  gs c toggle selectqdtarget      Toggles whether or not to use <stnpc> (as opposed to <t>) when using a shot.
--
--  gs c toggle LuzafRing           Toggles use of Luzaf Ring on and off


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
    -- QuickDraw Selector
    state.Mainqd = M{['description']='Primary Shot', 'Dark Shot', 'Light Shot', 'Fire Shot', 'Ice Shot', 'Wind Shot', 'Earth Shot', 'Thunder Shot', 'Water Shot'}
    state.Altqd = M{['description']='Secondary Shot', 'Dark Shot', 'Light Shot', 'Fire Shot', 'Ice Shot', 'Wind Shot', 'Earth Shot', 'Thunder Shot', 'Water Shot'}
    state.UseAltqd = M(false, 'Use Secondary Shot')
    state.QDMode = M{['description']='Quick Draw Mode', 'STP', 'Enhance', 'Potency', 'TH'}
    state.Currentqd = M{['description']='Current Quick Draw', 'Main', 'Alt'}

    -- Whether to use Luzaf's Ring
    state.LuzafRing = M(true, "Luzaf's Ring")
    -- Whether a warning has been given for low ammo
    state.warned = M(false)

    no_swap_gear = S{"Warp Ring", "Dim. Ring (Dem)", "Dim. Ring (Holla)", "Dim. Ring (Mea)",
              "Trizek Ring", "Echad Ring", "Facility Ring", "Capacity Ring",
              "Dev. Bul. Pouch", "Chr. Bul. Pouch", "Liv. Bul. Pouch"}
    elemental_ws = S{"Aeolian Edge", "Leaden Salute", "Wildfire"}
    no_shoot_ammo = S{"Animikii Bullet", "Hauksbok Bullet"}

    -- For th_action_check():
    -- JA IDs for actions that always have TH: Provoke, Animated Flourish
    info.default_ja_ids = S{35, 204}
    -- Unblinkable JA IDs for actions that always have TH: Quick/Box/Stutter Step, Desperate/Violent Flourish
    info.default_u_ja_ids = S{201, 202, 203, 205, 207}

    define_roll_values()

    lockstyleset = 26
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options('Normal', 'LowAcc', 'MidAcc', 'HighAcc', 'STP')
    state.HybridMode:options('Normal', 'Malignance', 'Nyame')
    state.RangedMode:options('Normal', 'Acc', 'HighAcc', 'Critical', 'STP')
    state.WeaponskillMode:options('Normal', 'HighBuff')
    state.IdleMode:options('Normal', 'DT', 'Regen', 'Movement')

    state.Gun = M{['description']='Gun', 'Fomalhaut', 'Holliday', 'Molybdosis', 'Anarchy'}
    state.WeaponSet = M{['description']='Melee', 'Piercing', 'Slashing', 'Ranged', 'Aeolian', 'Trial'}
    state.WeaponLock = M(false, 'Weapon Lock')

    options.ammo_warning_limit = 10

    -- Additional local binds
    include('Global-Binds.lua') -- OK to remove this line

    -- Ring Toggle
    send_command('bind ~f12 gs c toggle LuzafRing')

    -- Rolls
    send_command('bind ~^1 input /ja "Bolter\'s Roll" <me>')
    send_command('bind ~^2 input /ja "Samurai Roll" <me>')
    send_command('bind ~^3 input /ja "Chaos Roll" <me>')

    -- Roll related
    send_command('bind ~` input /ja "Double-up" <me>')
    send_command('bind ^` input /ja "Crooked Cards" <me>')
    send_command('bind !` input /ja "Snake Eye" <me>')
    send_command('bind ~^` input /ja "Fold" <me>')

    -- Quick Draw
    send_command('bind ^- gs c cycleback mainqd')
    send_command('bind ^= gs c cycle mainqd')
    send_command('bind !- gs c cycle altqd')
    send_command('bind != gs c cycleback altqd')
    send_command('bind ~= gs c toggle usealtqd')    
    send_command('bind ~- gs c qd')
    
    -- Weapon Selection
    send_command('bind ![ gs c cycleback Gun')
    send_command('bind !] gs c cycle Gun')
    send_command('bind ^[ gs c cycleback WeaponSet')
    send_command('bind ^] gs c cycle WeaponSet')

    -- Other JA
    send_command('bind ~[ input /ja "Wild Card" <me>')
    send_command('bind ~] input /ja "Random Deal" <me>')
    send_command('bind ~\' input /ja "Cutting Cards" <stpc>')

    -- Ranged Attack
    send_command('bind ~space input /ra <t>')

    -- Combined WS
    send_command('bind ~1 input /ws "Savage Blade" <t>')
    send_command('bind ~2 input /ws "Requiescat" <t>')
    send_command('bind ~3 input /ws "Leaden Salute" <t>')
    send_command('bind ~4 input /ws "Last Stand" <t>')
    send_command('bind ~5 input /ws "Wildfire" <t>')
    send_command('bind ~6 input /ws "Hot Shot" <t>')
    send_command('bind ~7 input /ws "Evisceration" <t>')
    send_command('bind ~8 input /ws "Aeolian Edge" <t>')
    send_command('bind ~9 input /ws "Sniper Shot" <t>')

    -- Ranged Buff
    send_command('bind ~0 input /ja "Triple Shot" <me>')

    -- -- Ranged Weapon WS
    -- send_command('bind ~q input /ws "Leaden Salute" <t>')
    -- send_command('bind ~w input /ws "Last Stand" <t>')
    -- send_command('bind ~e input /ws "Wildfire" <t>')
    -- send_command('bind ~r input /ws "Numbing Shot" <t>')
    -- send_command('bind ~t input /ws "Slug Shot" <t>')
    -- send_command('bind ~y input /ws "Sniper Shot" <t>')
    -- send_command('bind ~u input /ws "Split Shot" <t>')
    -- send_command('bind ~i input /ws "Hot Shot" <t>')

    -- -- Slashing Weapon WS
    -- send_command('bind ~a input /ws "Savage Blade" <t>')
    -- send_command('bind ~s input /ws "Requiescat" <t>')
    -- send_command('bind ~d input /ws "Spirits Within" <t>')
    -- send_command('bind ~f input /ws "Circle Blade" <t>')
    -- send_command('bind ~g input /ws "Shining Blade" <t>')
    -- send_command('bind ~h input /ws "Flat Blade" <t>')
    -- send_command('bind ~i input /ws "Burning Blade" <t>')
    -- send_command('bind ~j input /ws "Fast Blade" <t>')

    -- -- Piercing Weapon WS
    -- send_command('bind ~q input /ws "Exenterator" <t>')
    -- send_command('bind ~w input /ws "Aeolian Edge" <t>')
    -- send_command('bind ~e input /ws "Evisceration" <t>')
    -- send_command('bind ~r input /ws "Energy Drain" <t>')
    -- send_command('bind ~t input /ws "Energy Steal" <t>')
    -- send_command('bind ~y input /ws "Cyclone" <t>')
    -- send_command('bind ~u input /ws "Gust Slash" <t>')
    -- send_command('bind ~i input /ws "Shadowstitch" <t>')
    -- send_command('bind ~o input /ws "Viper Bite" <t>')
    -- send_command('bind ~p input /ws "Wasp Sting" <t>')

    select_default_macro_book()
    set_lockstyle()

    state.Auto_Kite = M(false, 'Auto_Kite')
    Haste = 0
    DW_needed = 0
    DW = false
    moving = false
    update_combat_form()
    determine_haste_group()
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

    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Special Sets ------------------------------------------
    ------------------------------------------------------------------------------------------------

    -- Bullets
    gear.RAbullet = "Chrono Bullet"
    -- gear.RAccbullet = "Devastating Bullet"
    gear.RAccbullet = "Chrono Bullet"
    gear.WSbullet = "Chrono Bullet"
    -- gear.MAbullet = "Living Bullet"
    gear.MAbullet = "Chrono Bullet"
    -- gear.QDbullet = "Living Bullet"
    gear.QDbullet = "Chrono Bullet"
    gear.TrialBullet = "Bronze Bullet"

    -- Movement Speed
    sets.MovementSpeed = {
        legs="Carmine Cuisses +1",
    }

    -- Luzaf's Ring
    sets.precast.LuzafRing = {ring1="Luzaf's Ring"}

    -- Ranged Weapons
    sets.Fomalhaut = {
        range={ name="Fomalhaut", augments={'Path: A'}},
        ammo=gear.RAbullet
    }
    sets.Anarchy = {
        range={name="Anarchy", augments={'DMG:+3','Split Shot:DMG:+10%'}},
        ammo=gear.TrialBullet,
    }
    sets.Molybdosis = {
        range="Molybdosis",
        ammo=gear.RAbullet
    }
    sets.Holliday = {
        range="Holliday",
        ammo=gear.RAbullet
    }

    -- Melee Weapons
    sets.Piercing = {main="Tauret", sub="Gleti's Knife"}
    sets.Slashing = {main="Naegling", sub="Gleti's Knife"}
    sets.Ranged = {main="Naegling", sub="Tauret"}
    sets.Aeolian = {main={ name="Rostam", augments={'Path: B',}}, sub="Tauret"}
    sets.Shield = {main={ name="Rostam", augments={'Path: A',}}, sub="Tauret"}
    sets.Trial = {main="Bronze Knife", sub="Bronze Knife"}

    -- Doom
    sets.buff.Doom = {
        neck="Nicander's Necklace", --20
        ring1="Eshmun's Ring", --20
        ring2="Eshmun's Ring", --20
        waist="Gishdubar Sash", --10
    }

    -- Other sets
    sets.FullTP = {ear1="Crematio Earring"}
    sets.Obi = {waist="Hachirin-no-Obi"}

    sets.DefaultShield = {sub="Nusku Shield"}

    sets.TripleShotCritical = {
        head="Meghanada Visor +2",
        body="Nisroch Jerkin",
        legs="Osh. Trousers +1",
        feet="Ikenga's Clogs",
        waist="Tellen Belt",
    }

    sets.TrueShot = {
        body="Nisroch Jerkin",
        legs="Osh. Trousers +1",
        feet="Ikenga's Clogs",
        waist="Tellen Belt",
    }

    -- Doesn't seem to be linked to anything
    sets.EnmityDown = {
        hands="Ikenga's Gloves",
        legs="Ikenga's Trousers",
        feet="Ikenga's Clogs",
        ear1="Beyla Earring",
        waist="Elanid Belt",
        neck="Marked Gorget",
        
    }

    -- WS Buff Sets
    sets.HighBuffMelee = {
        body="Ikenga's Vest",
        ring1="Sroda Ring",
    }

    sets.HighBuffRanged = {
        body="Ikenga's Vest",
        hand="Ikenga's Gloves",
        legs="Ikenga's Trousers",
        feet="Ikenga's Clogs",
        ring1="Sroda Ring",
    }

    sets.HighBuffEvisc = {
        body="Ikenga's Vest",
        ring1="Ikenga's Clogs",
    }

    -- MAcc / Weather... in guide but don't see it here
    sets.MAccWeather={
        head="Nyame Helm",
        neck={ name="Comm. Charm +2", augments={'Path: A',}},
    }


    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Precast Sets - Phantom Roll ---------------------------
    ------------------------------------------------------------------------------------------------

    sets.precast.CorsairRoll = {
        main={ name="Rostam", augments={'Path: C',}},
        range={ name="Compensator", augments={'DMG:+15','AGI+15','Rng.Acc.+15',}},
        head={ name="Lanun Tricorne +3", augments={'Enhances "Winning Streak" effect',}},
        hands="Chasseur's Gants +2",
        ring2="Barataria Ring",
        back={ name="Camulus's Mantle", augments={'INT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Snapshot"+10','Mag. Evasion+15',}},
        neck='Regal Necklace',
        legs="Desultor Tassets",
    }

    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Precast Sets - Roll Specific -------------------------
    ------------------------------------------------------------------------------------------------

    sets.precast.CorsairRoll["Allies' Roll"] = set_combine(
        sets.precast.CorsairRoll, {
            hands="Chasseur's Gants +2",
        }
    )
    sets.precast.CorsairRoll["Blitzer's Roll"] = set_combine(
        sets.precast.CorsairRoll, {
            sets.MovementSpeed
        }
    )
    sets.precast.CorsairRoll["Bolter's Roll"] = set_combine(
        sets.precast.CorsairRoll, {
            body="Chasseur's Frac +2",
        }
    )
    sets.precast.CorsairRoll["Caster's Roll"] = set_combine(
        sets.precast.CorsairRoll, {
            legs="Chas. Culottes +2",
        }
    )
    sets.precast.CorsairRoll["Courser's Roll"] = set_combine(
        sets.precast.CorsairRoll, {
            feet="Chass. Bottes +2",
        }
    )
    sets.precast.CorsairRoll["Tactician's Roll"] = set_combine(
        sets.precast.CorsairRoll, {
            body="Chasseur's Frac +2",
        }
    )

    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Precast Sets - Abilities ------------------------------
    ------------------------------------------------------------------------------------------------

    sets.precast.JA['Wild Card'] = {
        feet={ name="Lanun Bottes +3", augments={'Enhances "Wild Card" effect',}},
    }
    sets.precast.JA['Random Deal'] = {
        body={ name="Lanun Frac +3", augments={'Enhances "Loaded Deck" effect',}},
    }
    sets.precast.JA['Snake Eye'] = {
        legs={ name="Lanun Trews +3", augments={'Enhances "Snake Eye" effect',}},
    }
    sets.precast.JA['Fold'] = {
        hands={ name="Lanun Gants +3", augments={'Enhances "Fold" effect',}},
    }
    sets.precast.FoldDoubleBust = {
        hands={ name="Lanun Gants +3", augments={'Enhances "Fold" effect',}},
    }
    sets.precast.JA['Triple Shot'] = {
        head="Oshosi Mask +1",
        body="Chasseur's Frac +2",
        hands={ name="Lanun Gants +3", augments={'Enhances "Fold" effect',}},
        legs="Osh. Trousers +1",
        feet="Osh. Leggings +1",
        back={ name="Camulus's Mantle", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','Rng.Acc.+10','"Store TP"+10','Mag. Evasion+15',}},
    }

    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Precast Sets - Subjobs --------------------------------
    ------------------------------------------------------------------------------------------------

    -- DNC
    sets.precast.Waltz = gear.DNC_Sub_Waltz

    -- NIN
    sets.precast.FC = {
        head="Carmine Mask +1",
        body={ name="Taeon Tabard", augments={'"Fast Cast"+5',}},
        legs={ name="Herculean Trousers", augments={'Mag. Acc.+7','"Fast Cast"+5','INT+6','"Mag.Atk.Bns."+6',}},
        feet="Carmine Greaves +1",
        left_ear="Enchntr. Earring +1",
    }

    sets.precast.FC.Utsusemi = set_combine(
        sets.precast.FC, {
            body="Passion Jacket",
        }
    )

    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Precast Sets - Ranged --------------------------------
    ------------------------------------------------------------------------------------------------

    -- (10% Snapshot from JP Gifts)
    sets.precast.RA = {
        head="Chass. Tricorne +2",
        body="Oshosi Vest +1",
        hands={ name="Carmine Fin. Ga. +1", augments={'Rng.Atk.+20','"Mag.Atk.Bns."+12','"Store TP"+6',}},
        legs={ name="Adhemar Kecks +1", augments={'AGI+12','"Rapid Shot"+13','Enmity-6',}},
        feet="Meg. Jam. +2",
        neck={ name="Comm. Charm +2", augments={'Path: A',}},
        left_ring="Crepuscular Ring",
        back={ name="Camulus's Mantle", augments={'INT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Snapshot"+10','Mag. Evasion+15',}},
        waist="Impulse Belt", --3/0
    } --62/38

    sets.precast.RA.Flurry1 = set_combine(
        sets.precast.RA, {
            body="Laksa. Frac +3", --0/20
            waist="Yemaya Belt", --0/5
        }
    ) --45/63

    sets.precast.RA.Flurry2 = set_combine(
        sets.precast.RA.Flurry1, {
            feet="Pursuer's Gaiters", --0/10
        }
    ) --35/73

    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Midcast Sets - Ranged TP ------------------------------
    ------------------------------------------------------------------------------------------------

    sets.midcast.RA = {
        ammo="Chrono Bullet",
        head="Malignance Chapeau",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        legs="Chas. Culottes +2",
        feet="Malignance Boots",
        left_ear="Telos Earring",
        right_ear="Crep. Earring",
        left_ring="Crepuscular Ring",
        right_ring="Rajas Ring",
        back={ name="Camulus's Mantle", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','Rng.Acc.+10','"Store TP"+10','Mag. Evasion+15',}},
    }

    sets.midcast.RA.STP = set_combine(
        sets.midcast.RA, {
            ear1="Dedition Earring",
            ring2="Chirich Ring +1",
            waist="Gerdr Belt +1",
        }
    )

    sets.midcast.RA.Acc = set_combine(
        sets.midcast.RA, {
            neck={ name="Comm. Charm +2", augments={'Path: A',}},
            waist="K. Kachina Belt +1",
            ear1="Beyla Earring",
            left_ring="Hajduk Ring +1",
        }
    )

    -- Not sure what gear shuold go here, it isn't in guide
    sets.midcast.RA.HighAcc = set_combine(
        sets.midcast.RA.Acc, {
            legs="Laksa. Trews +3",
            ring1="Regal Ring",
            waist="K. Kachina Belt +1",
        }
    )

    sets.midcast.RA.Critical = set_combine(
        sets.midcast.RA, {
            ammo="Chrono Bullet",
            head="Meghanada Visor +2",
            body="Meg. Cuirie +2",
            hands="Chasseur's Gants +2",
            feet="Osh. Leggings +1",
            waist="K. Kachina Belt +1",
            left_ear="Odr Earring",
            left_ring="Mummu Ring",
        }
    )

    ------------------------------------------------------------------------------------------------
    ------------------------------------- Weapon Skill Sets ----------------------------------------
    ------------------------------------------------------------------------------------------------

    --- don't know what to do with this section yet
    sets.precast.WS = {
        ammo="Chrono Bullet",
        head={ name="Lanun Tricorne +3", augments={'Enhances "Winning Streak" effect',}},
        body="Meg. Cuirie +2",
        hands="Chasseur's Gants +2",
        legs="Nyame Flanchard",
        feet={ name="Lanun Bottes +3", augments={'Enhances "Wild Card" effect',}},
        neck="Fotia Gorget",
        waist="Fotia Belt",
        left_ear={ name="Moonshade Earring", augments={'"Mag.Atk.Bns."+4','TP Bonus +250',}},
        left_ring="Epaminondas's Ring",
        right_ring="Meghanada Ring",
        back={ name="Camulus's Mantle", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','AGI+10','Weapon skill damage +10%','Mag. Evasion+15',}},
    }

    sets.precast.WS.PDL = set_combine(
        sets.precast.WS,
        sets.HighBuffRanged
    )

    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Precast Sets - WS Ranged ------------------------------
    ------------------------------------------------------------------------------------------------

    -- Leaden Salute
    sets.precast.WS['Leaded Salute'] = {
        ammo="Orichalc. Bullet",
        head="Pixie Hairpin +1",
        body={ name="Lanun Frac +3", augments={'Enhances "Loaded Deck" effect',}},
        hands="Nyame Gauntlets",
        legs="Nyame Flanchard",
        feet={ name="Lanun Bottes +3", augments={'Enhances "Wild Card" effect',}},
        neck={ name="Comm. Charm +2", augments={'Path: A',}},
        waist="Svelt. Gouriz +1",
        left_ear="Friomisi Earring",
        right_ear={ name="Moonshade Earring", augments={'"Mag.Atk.Bns."+4','TP Bonus +250',}},
        left_ring="Arvina Ringlet +1",
        back={ name="Camulus's Mantle", augments={'AGI+20','Mag. Acc+20 /Mag. Dmg.+20','AGI+5','Weapon skill damage +10%','Mag. Evasion+15',}},
    }

    sets.precast.WS['Leaded Salute'].HighBuff = set_combine(
        sets.precast.WS['Leaded Salute'],
        sets.MAccWeather
    )

    sets.precast.WS['Wildfire'] = {
        ammo="Orichalc. Bullet",
        head="Nyame Helm",
        body={ name="Lanun Frac +3", augments={'Enhances "Loaded Deck" effect',}},
        hands="Nyame Gauntlets",
        legs="Nyame Flanchard",
        feet={ name="Lanun Bottes +3", augments={'Enhances "Wild Card" effect',}},
        neck={ name="Comm. Charm +2", augments={'Path: A',}},
        waist="Skrymir Cord +1",
        left_ear="Friomisi Earring",
        left_ring="Epaminondas's Ring",
        right_ring="Arvina Ringlet +1",
        back={ name="Camulus's Mantle", augments={'AGI+20','Mag. Acc+20 /Mag. Dmg.+20','AGI+5','Weapon skill damage +10%','Mag. Evasion+15',}},
    }

    sets.precast.WS['Wildfire'].HighBuff = set_combine(
        sets.precast.WS['Wildfire'],
        sets.MAccWeather
    )

    sets.precast.WS['Last Stand'] = sets.precast.WS

    sets.precast.WS['Last Stand'].HighBuff = set_combine(
        sets.precast.WS['Last Stand'],
        sets.HighBuffRanged
    )

    sets.precast.WS['Hot Shot'] = {
        ammo="Orichalc. Bullet",
        head="Nyame Helm",
        body="Nyame Mail",
        hands="Chasseur's Gants +2",
        legs="Nyame Flanchard",
        feet={ name="Lanun Bottes +3", augments={'Enhances "Wild Card" effect',}},
        neck="Fotia Gorget",
        waist="Fotia Belt",
        left_ear={ name="Moonshade Earring", augments={'"Mag.Atk.Bns."+4','TP Bonus +250',}},
        right_ear="Friomisi Earring",
        left_ring="Epaminondas's Ring",
        back={ name="Camulus's Mantle", augments={'AGI+20','Mag. Acc+20 /Mag. Dmg.+20','AGI+5','Weapon skill damage +10%','Mag. Evasion+15',}},
    }

    sets.precast.WS['Hot Shot'].HighBuff = set_combine(
        sets.precast.WS['Hot Shot'],
        sets.HighBuffRanged
    )

    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Precast Sets - WS Melee -------------------------------
    ------------------------------------------------------------------------------------------------

    -- Savage Blade
    sets.precast.WS['Savage Blade'] = {
        head="Nyame Helm",
        body="Nyame Mail",
        hands="Chasseur's Gants +2",
        legs="Nyame Flanchard",
        feet="Nyame Sollerets",
        neck="Rep. Plat. Medal",
        waist="Prosilio Belt +1",
        left_ear={ name="Moonshade Earring", augments={'"Mag.Atk.Bns."+4','TP Bonus +250',}},
        left_ring="Epaminondas's Ring",
        right_ring="Ifrit Ring +1",
        back={ name="Camulus's Mantle", augments={'STR+20','Accuracy+20 Attack+20','Weapon skill damage +10%','Mag. Evasion+15',}},
    }

    sets.precast.WS['Savage Blade'].HighBuff = set_combine(
        sets.precast.WS['Savage Blade'],
        sets.HighBuffMelee
    )

    -- Requiescat
    sets.precast.WS['Requiescat'] =  {
        head="Nyame Helm",
        body="Nyame Mail",
        hands="Nyame Gauntlets",
        legs="Nyame Flanchard",
        feet="Nyame Sollerets",
        neck="Fotia Gorget",
        waist="Fotia Belt",
        left_ear={ name="Moonshade Earring", augments={'"Mag.Atk.Bns."+4','TP Bonus +250',}},
        right_ear="Telos Earring",
        left_ring="Levia. Ring +1",
        right_ring="Epona's Ring",
        back={ name="Camulus's Mantle", augments={'MND+20','Accuracy+20 Attack+20','"Dbl.Atk."+10','Mag. Evasion+6',}},
    }

    sets.precast.WS['Requiescat'].HighBuff = set_combine(
        sets.precast.WS['Requiescat'],
        sets.HighBuffMelee
    )

    -- Evisceration
    sets.precast.WS['Evisceration'] = {
        head={ name="Adhemar Bonnet +1", augments={'DEX+12','AGI+12','Accuracy+20',}},
        body="Meg. Cuirie +2",
        hands={ name="Adhemar Wrist. +1", augments={'DEX+12','AGI+12','Accuracy+20',}},
        legs="Meg. Chausses +2",
        feet={ name="Adhe. Gamashes +1", augments={'HP+65','"Store TP"+7','"Snapshot"+10',}},
        neck="Fotia Gorget",
        waist="Fotia Belt",
        left_ear="Odr Earring",
        right_ear={ name="Moonshade Earring", augments={'"Mag.Atk.Bns."+4','TP Bonus +250',}},
        left_ring="Mummu Ring",
        right_ring="Epona's Ring",
    }

    sets.precast.WS['Evisceration'].HighBuff = set_combine(
        sets.precast.WS['Evisceration'],
        sets.HighBuffEvisc
    )
 
    -- Aeolian Edge
    sets.precast.WS['Aeolian Edge'] = {
        ammo="Hauksbok Bullet",
        head="Nyame Helm",
        body={ name="Lanun Frac +3", augments={'Enhances "Loaded Deck" effect',}},
        hands="Nyame Gauntlets",
        legs="Nyame Flanchard",
        feet={ name="Lanun Bottes +3", augments={'Enhances "Wild Card" effect',}},
        neck="Sanctity Necklace",
        waist="Orpheus's Sash",
        left_ear={ name="Moonshade Earring", augments={'"Mag.Atk.Bns."+4','TP Bonus +250',}},
        right_ear="Friomisi Earring",
        left_ring="Epaminondas's Ring",
        right_ring="Shiva Ring +1",
    }

    sets.precast.WS['Aeolian Edge'].HighBuff = set_combine(
        sets.precast.WS['Aeolian Edge'],
        sets.MAccWeather
    )

    -- Misc. Weapon Skills
    sets.precast.WS['Circle Blade'] = sets.precast.WS['Savage Blade']
    sets.precast.WS['Circle Blade'].HighBuff = set_combine(
        sets.precast.WS['Circle Blade'],
        sets.HighBuffMelee
    )

    sets.precast.WS['Burning Blade'] = sets.precast.WS['Wildfire']

    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Midcast Sets - Quick Draw -----------------------------
    ------------------------------------------------------------------------------------------------

    sets.midcast.CorsairShot = {
        ammo="Hauksbok Bullet",
        head="Nyame Helm",
        body={ name="Lanun Frac +3", augments={'Enhances "Loaded Deck" effect',}},
        hands="Mummu Wrists +2",
        legs="Nyame Flanchard",
        feet={ name="Lanun Bottes +3", augments={'Enhances "Wild Card" effect',}},
        neck={ name="Comm. Charm +2", augments={'Path: A',}},
        waist="Skrymir Cord +1",
        left_ear="Friomisi Earring",
        left_ring="Arvina Ringlet +1",
        right_ring="Fenrir Ring +1",
    }
    
    sets.midcast.CorsairShot.STP = {
        ammo="Hauksbok Bullet",
        head="Malignance Chapeau",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        legs="Chas. Culottes +2",
        feet="Malignance Boots",
        neck="Iskur Gorget",
        left_ear="Crep. Earring",
        ear2="Telos Earring",
        ring1="Crepuscular Ring",
        ring2="Chirich Ring +1",
        waist="Gerdr Belt +1",
        back={ name="Camulus's Mantle", augments={'AGI+20','Mag. Acc+20 /Mag. Dmg.+20','AGI+5','Weapon skill damage +10%','Mag. Evasion+15',}},
    }

    sets.midcast.CorsairShot['Light Shot'] = {
        ammo="Animikii Bullet",
        head="Mummu Bonnet +2",
        body="Malignance Tabard",
        hands="Mummu Wrists +2",
        legs="Malignance Tights",
        feet="Mummu Gamash. +2",
        neck={ name="Comm. Charm +2", augments={'Path: A',}},
        waist="K. Kachina Belt +1",
        left_ear="Crep. Earring",
        right_ear="Breeze Pearl",
        left_ring="Mummu Ring",
        right_ring="Stikini Ring +1",
        back={ name="Camulus's Mantle", augments={'AGI+20','Mag. Acc+20 /Mag. Dmg.+20','AGI+5','Weapon skill damage +10%','Mag. Evasion+15',}},
    }

    sets.midcast.CorsairShot['Dark Shot'] = sets.midcast.CorsairShot['Light Shot']
    sets.midcast.CorsairShot.Enhance = {
        head="Blood Mask",
        body="Mirke Wardecors", 
        feet="Chass. Bottes +2"
    }

    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Midcast Sets - Subjobs --------------------------------
    ------------------------------------------------------------------------------------------------

    -- NIN
    sets.midcast.FastRecast = sets.precast.FC

    sets.midcast.SpellInterrupt = {
        hands="Rawhide Gloves", --15
        legs="Carmine Cuisses +1", --20
        neck="Loricate Torque +1", --5
        ear1="Halasz Earring", --5
        ear2="Magnetic Earring", --8
        ring2="Evanescence Ring", --5
        waist="Rumination Sash", --10
    }

    sets.midcast.Utsusemi = sets.midcast.SpellInterrupt

    ------------------------------------------------------------------------------------------------
    ----------------------------------------- Idle Sets --------------------------------------------
    ------------------------------------------------------------------------------------------------

    sets.resting = {}

    sets.idle = {
        ammo=gear.RAbullet,
        head="Nyame Helm",
        body="Nyame Mail",
        hands="Raetic Bangles +1",
        legs="Chas. Culottes +3",
        feet="Nyame Sollerets",
        neck="Bathy Choker +1",
        ear1="Sanare Earring",
        ear2="Eabani Earring",
        ring1="Chirich Ring +1",
        ring2="Chirich Ring +1",
        back={ name="Camulus's Mantle", augments={'INT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Snapshot"+10','Mag. Evasion+15',}},
        waist="Plat. Mog. Belt",
    }

    sets.idle.DT = set_combine(
        sets.idle, {
            head="Nyame Helm",
            body="Nyame Mail",
            hands="Raetic Bangles +1",
            legs="Nyame Flanchard",
            feet="Nyame Sollerets",
            waist="Plat. Mog. Belt",
            right_ear="Eabani Earring",
            left_ring="Defending Ring",
            back={ name="Camulus's Mantle", augments={'INT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Snapshot"+10','Mag. Evasion+15',}},
        }
    )

    sets.idle.Regen = {
        head="Meghanada Visor +2",
        body="Meg. Cuirie +2",
        hands="Meg. Gloves +2",
        legs="Meg. Chausses +2",
        feet="Meg. Jam. +2",
        neck={ name="Bathy Choker +1", augments={'Path: A',}},
        left_ear="Infused Earring",
        right_ear="Dawn Earring",
        left_ring="Chirich Ring +1",
        right_ring="Chirich Ring +1",
    }

    sets.idle.Movement = set_combine(
        sets.idle.Regen,
        sets.MovementSpeed
    )

    sets.idle.Town = sets.idle.Movement

    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Defense Sets ------------------------------------------
    ------------------------------------------------------------------------------------------------

    sets.defense.PDT = sets.idle.DT

    sets.defense.MDT = sets.idle.DT

    sets.Kiting = {legs="Carmine Cuisses +1"}


    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Engaged Sets ------------------------------------------
    ------------------------------------------------------------------------------------------------

    -- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
    -- sets if more refined versions aren't defined.
    -- If you create a set with both offense and defense modes, the offense mode should be first.
    -- EG: sets.engaged.Dagger.Accuracy.Evasion

    -- Single Wield
    sets.engaged = {
        head={ name="Adhemar Bonnet +1", augments={'DEX+12','AGI+12','Accuracy+20',}},
        hands={ name="Adhemar Wrist. +1", augments={'DEX+12','AGI+12','Accuracy+20',}},
        body={ name="Herculean Vest", augments={'Rng.Atk.+18','"Triple Atk."+3','Accuracy+11',}},
        legs={ name="Taeon Tights", augments={'Accuracy+21','"Dual Wield"+4','DEX+8',}},
        feet={ name="Herculean Boots", augments={'Attack+6','"Triple Atk."+4','DEX+4',}},
        waist="Windbuffet Belt +1",
        ear1="Mache Earring +1",
        left_ring="Rajas Ring",
        right_ring="Epona's Ring",
    }

    sets.engaged.LowAcc = set_combine(sets.engaged, {
        head="Dampening Tam",
        hands={ name="Adhemar Wrist. +1", augments={'DEX+12','AGI+12','Accuracy+20',}},
        ring1="Chirich Ring +1",
        neck="Combatant's Torque",
        ear1="Mache Earring +1",
    })

    sets.engaged.MidAcc = set_combine(sets.engaged.LowAcc, {
        ear1="Mache Earring +1",
        ear2="Telos Earring",
        ring1="Regal Ring",
        ring2="Ilabrat Ring",
        waist="Kentarch Belt +1",
    })

    sets.engaged.HighAcc = set_combine(sets.engaged.MidAcc, {
        head="Carmine Mask +1",
        hands="Gazu Bracelets +1",
        ear1="Mache Earring +1",
        ear2="Odr Earring",
        ring2="Chirich Ring +1",
        waist="Olseni Belt",
    })

    sets.engaged.STP = set_combine(sets.engaged, {
        ring1="Chirich Ring +1",
        ring2="Chirich Ring +1",
    })

    -- * DNC Subjob DW Trait: +15%
    -- * NIN Subjob DW Trait: +25%

    -- No Magic Haste (74% DW to cap)
    sets.engaged.DW = {
        head={ name="Herculean Helm", augments={'"Dual Wield"+6','AGI+8','Accuracy+2',}},
        body={ name="Adhemar Jacket +1", augments={'DEX+12','AGI+12','Accuracy+20',}},
        hands={ name="Taeon Gloves", augments={'"Dual Wield"+4','DEX+7','Accuracy+20','Attack+20'}},
        legs="Carmine Cuisses +1",
        feet={ name="Taeon Boots", augments={'Accuracy+23','"Dual Wield"+5','DEX+10',}},
        waist="Reiki Yotai",
        left_ear="Eabani Earring",
        right_ear="Suppanomimi",
        left_ring="Rajas Ring",
        right_ring="Epona's Ring",
        back={ name="Camulus's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','"Dual Wield"+10','Phys. dmg. taken-10%',}},
      } -- 48%

    sets.engaged.DW.LowAcc = set_combine(
        sets.engaged.DW, {
            head="Dampening Tam",
            ring1="Chirich Ring +1",
            neck="Combatant's Torque",
        }
    )

    sets.engaged.DW.MidAcc = set_combine(
        sets.engaged.DW.LowAcc, {
            hands={ name="Adhemar Wrist. +1", augments={'DEX+12','AGI+12','Accuracy+20',}},
            ear1="Crep. Earring",
            ear2="Telos Earring",
            ring1="Regal Ring",
            ring2="Ilabrat Ring",
            waist="Kentarch Belt +1", 
        }
    )

    sets.engaged.DW.HighAcc = set_combine(
        sets.engaged.DW.MidAcc, {
            head="Carmine Mask +1",
            hands="Gazu Bracelets +1",
            ear1="Mache Earring +1",
            ear2="Odr Earring",
            ring2="Chirich Ring +1",
            waist="Olseni Belt",
        }
    )

    sets.engaged.DW.STP = set_combine(
        sets.engaged.DW, {
            ring1="Chirich Ring +1",
            ring2="Chirich Ring +1",
        }
    )

    -- 15% Magic Haste (67% DW to cap)
    sets.engaged.DW.LowHaste = {
        head={ name="Adhemar Bonnet +1", augments={'DEX+12','AGI+12','Accuracy+20',}},
        body={ name="Adhemar Jacket +1", augments={'DEX+12','AGI+12','Accuracy+20',}},
        hands={ name="Taeon Gloves", augments={'"Dual Wield"+4','DEX+7','Accuracy+20','Attack+20'}},
        legs="Carmine Cuisses +1",
        feet={ name="Taeon Boots", augments={'Accuracy+23','"Dual Wield"+5','DEX+10',}},
        waist="Reiki Yotai",
        left_ear="Eabani Earring",
        right_ear="Suppanomimi",
        left_ring="Rajas Ring",
        right_ring="Epona's Ring",
        back={ name="Camulus's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','"Dual Wield"+10','Phys. dmg. taken-10%',}},
    } -- 42%

    sets.engaged.DW.LowAcc.LowHaste = set_combine(
        sets.engaged.DW.LowHaste, {
            head="Dampening Tam",
            ring1="Chirich Ring +1",
            neck="Combatant's Torque",
        }
    )

    sets.engaged.DW.MidAcc.LowHaste = set_combine(
        sets.engaged.DW.LowAcc.LowHaste, {
            head={ name="Adhemar Bonnet +1", augments={'DEX+12','AGI+12','Accuracy+20',}},
            ear1="Crep. Earring",
            ear2="Telos Earring",
            ring1="Regal Ring",
            ring2="Ilabrat Ring",
            waist="Kentarch Belt +1",
        }
    )

    sets.engaged.DW.HighAcc.LowHaste = set_combine(
        sets.engaged.DW.MidAcc.LowHaste, {
            head="Carmine Mask +1",
            hands="Gazu Bracelets +1",
            ear1="Mache Earring +1",
            ear2="Odr Earring",
            ring2="Chirich Ring +1",
            waist="Olseni Belt",
        }
    )

    sets.engaged.DW.STP.LowHaste = set_combine(
        sets.engaged.DW.LowHaste, {
            ring1="Chirich Ring +1",
            ring2="Chirich Ring +1",
        }
    )

    -- 30% Magic Haste (56% DW to cap)
    sets.engaged.DW.MidHaste = {
        head={ name="Adhemar Bonnet +1", augments={'DEX+12','AGI+12','Accuracy+20',}},
        body={ name="Adhemar Jacket +1", augments={'DEX+12','AGI+12','Accuracy+20',}},
        hands={ name="Adhemar Wrist. +1", augments={'DEX+12','AGI+12','Accuracy+20',}},
        legs={ name="Taeon Tights", augments={'Accuracy+21','"Dual Wield"+4','DEX+8',}},
        feet={ name="Taeon Boots", augments={'Accuracy+23','"Dual Wield"+5','DEX+10',}},
        waist="Reiki Yotai",
        left_ear="Eabani Earring",
        right_ear="Suppanomimi",
        left_ring="Rajas Ring",
        right_ring="Epona's Ring",
        back={ name="Camulus's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','"Dual Wield"+10','Phys. dmg. taken-10%',}},
    } -- 31%

    sets.engaged.DW.LowAcc.MidHaste = set_combine(
        sets.engaged.DW.MidHaste, {
            head="Dampening Tam",
            hands={ name="Adhemar Wrist. +1", augments={'DEX+12','AGI+12','Accuracy+20',}},
            ring1="Chirich Ring +1",
            neck="Combatant's Torque",
        }
    )

    sets.engaged.DW.MidAcc.MidHaste = set_combine(
        sets.engaged.DW.LowAcc.MidHaste, {
            legs="Meg. Chausses +2",
            ear1="Crep. Earring",
            ear2="Telos Earring",
            ring1="Regal Ring",
            ring2="Ilabrat Ring",
            waist="Kentarch Belt +1",
        }
    )

    sets.engaged.DW.HighAcc.MidHaste = set_combine(
        sets.engaged.DW.MidAcc.MidHaste, {
            head="Carmine Mask +1",
            hands="Gazu Bracelets +1",
            legs="Carmine Cuisses +1",
            ear1="Mache Earring +1",
            ear2="Odr Earring",
            ring2="Chirich Ring +1",
            waist="Olseni Belt",
        }
    )

    sets.engaged.DW.STP.MidHaste = set_combine(
        sets.engaged.DW.MidHaste, {
            -- head=gear.Herc_STP_head, need to get this
            ring1="Chirich Ring +1",
            ring2="Chirich Ring +1",
        }
    )

    -- 35% Magic Haste (51% DW to cap)
    sets.engaged.DW.HighHaste = {
        head={ name="Adhemar Bonnet +1", augments={'DEX+12','AGI+12','Accuracy+20',}},
        body={ name="Adhemar Jacket +1", augments={'DEX+12','AGI+12','Accuracy+20',}},
        hands={ name="Adhemar Wrist. +1", augments={'DEX+12','AGI+12','Accuracy+20',}},
        legs={ name="Taeon Tights", augments={'Accuracy+21','"Dual Wield"+4','DEX+8',}},
        feet={ name="Taeon Boots", augments={'Accuracy+23','"Dual Wield"+5','DEX+10',}},
        waist="Reiki Yotai",
        left_ear="Eabani Earring",
        right_ear="Suppanomimi",
        left_ring="Rajas Ring",
        right_ring="Epona's Ring",
        back={ name="Camulus's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','"Dual Wield"+10','Phys. dmg. taken-10%',}},
    }

    sets.engaged.DW.LowAcc.HighHaste = set_combine(
        sets.engaged.DW.HighHaste, {
            head="Dampening Tam",
            hands={name="Adhemar Wrist. +1", augments={'DEX+12','AGI+12','Accuracy+20',}},
            ring1="Chirich Ring +1",
            neck="Combatant's Torque",
        }
    )

    sets.engaged.DW.MidAcc.HighHaste = set_combine(
        sets.engaged.DW.LowAcc.HighHaste, {
            legs="Meg. Chausses +2",
            ear1="Crep. Earring",
            ear2="Telos Earring",
            ring1="Regal Ring",
            ring2="Ilabrat Ring",
            waist="Kentarch Belt +1",
        }
    )

    sets.engaged.DW.HighAcc.HighHaste = set_combine(
        sets.engaged.DW.MidAcc.HighHaste, {
            head="Carmine Mask +1",
            hands="Gazu Bracelets +1",
            legs="Carmine Cuisses +1",
            ear1="Mache Earring +1",
            ear2="Odr Earring",
            ring2="Chirich Ring +1",
            waist="Olseni Belt",
        }
    )

    sets.engaged.DW.STP.HighHaste = set_combine(
        sets.engaged.DW.HighHaste, {
            ring1="Chirich Ring +1",
            ring2="Chirich Ring +1",
        }
    )

    -- 45% Max Magic Haste (36% DW to cap)
    sets.engaged.DW.MaxHaste = {
        head={ name="Adhemar Bonnet +1", augments={'DEX+12','AGI+12','Accuracy+20',}},
        body={ name="Adhemar Jacket +1", augments={'DEX+12','AGI+12','Accuracy+20',}},
        hands={ name="Adhemar Wrist. +1", augments={'DEX+12','AGI+12','Accuracy+20',}},
        legs={ name="Taeon Tights", augments={'Accuracy+21','"Dual Wield"+4','DEX+8',}},
        feet={ name="Herculean Boots", augments={'Attack+6','"Triple Atk."+4','DEX+4',}},
        waist="Windbuffet Belt +1",
        left_ear="Telos Earring",
        right_ear="Suppanomimi",
        left_ring="Rajas Ring",
        right_ring="Epona's Ring",
        back={ name="Camulus's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','"Dual Wield"+10','Phys. dmg. taken-10%',}},
    } -- 11%

    sets.engaged.DW.LowAcc.MaxHaste = set_combine(
        sets.engaged.DW.MaxHaste, {
            head="Dampening Tam",
            hands={ name="Adhemar Wrist. +1", augments={'DEX+12','AGI+12','Accuracy+20',}},
            ring1="Chirich Ring +1",
            waist="Kentarch Belt +1",
        }
    )

    sets.engaged.DW.MidAcc.MaxHaste = set_combine(
        sets.engaged.DW.LowAcc.MaxHaste, {
            legs="Meg. Chausses +2",
            neck="Combatant's Torque",
            ear1="Crep. Earring",
            ring1="Regal Ring",
            ring2="Ilabrat Ring",
        }
    )

    sets.engaged.DW.HighAcc.MaxHaste = set_combine(
        sets.engaged.DW.MidAcc.MaxHaste, {
            head="Carmine Mask +1",
            hands="Gazu Bracelets +1",
            legs="Carmine Cuisses +1",
            ear1="Mache Earring +1",
            ear2="Odr Earring",
            ring2="Chirich Ring +1",
            waist="Olseni Belt",
        }
    )

    sets.engaged.DW.STP.MaxHaste = set_combine(
        sets.engaged.DW.MaxHaste, {
            ring1="Chirich Ring +1",
            ring2="Chirich Ring +1",
        }
    )

    -- Evaluate putting the DNC DA backpieces here if the subjob is DNC
    -- sets.engaged.DW.MaxHastePlus = set_combine(
    --     sets.engaged.DW.MaxHaste, {
    --         back=gear.COR_DW_Cape
    --     }
    -- )
    -- sets.engaged.DW.LowAcc.MaxHastePlus = set_combine(
    --     sets.engaged.DW.LowAcc.MaxHaste, {
    --         back=gear.COR_DW_Cape
    --     }
    -- )
    -- sets.engaged.DW.MidAcc.MaxHastePlus = set_combine(
    --     sets.engaged.DW.MidAcc.MaxHaste, {
    --         back=gear.COR_DW_Cape
    --     }
    -- )
    -- sets.engaged.DW.HighAcc.MaxHastePlus = set_combine(
    --     sets.engaged.DW.HighAcc.MaxHaste, {
    --         back=gear.COR_DW_Cape
    --     }
    -- )
    -- sets.engaged.DW.STP.MaxHastePlus = set_combine(
    --     sets.engaged.DW.STP.MaxHaste, {
    --         back=gear.COR_DW_Cape
    --     }
    -- )

    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Hybrid Sets -------------------------------------------
    ------------------------------------------------------------------------------------------------

    sets.engaged.MalignanceHybrid = {
        head="Malignance Chapeau", --6/6
        body="Malignance Tabard", --9/9
        hands="Malignance Gloves", --5/5
        legs="Chas. Culottes +3", --12/12
        feet="Malignance Boots", --4/4
        left_ring="Defending Ring",

    }

    sets.engaged.MalignanceHybrid.MidHaste = {
        head="Malignance Chapeau",
        hands="Malignance Gloves",
        legs="Chas. Culottes +2",
        left_ring="Defending Ring",    
    }

    sets.engaged.MalignanceHybrid.LowHaste = {
        head="Malignance Chapeau",
        left_ring="Defending Ring",    
    }

    sets.engaged.MalignanceHybrid.NoHaste = {
        left_ring="Defending Ring",
    }

    sets.engaged.NyameHybrid = {
        head="Nyame Helm", --7/7
        body="Nyame Mail", --9/9
        hands="Nyame Gauntlets",  --7/7
        legs="Chas. Culottes +3", --12/12
        feet="Nyame Sollerets", --7/7
    }

    sets.engaged.Malignance = set_combine(
        sets.engaged, 
        sets.engaged.MalignanceHybrid
    )
    sets.engaged.LowAcc.Malignance = set_combine(
        sets.engaged.LowAcc, 
        sets.engaged.MalignanceHybrid
    )
    sets.engaged.MidAcc.Malignance = set_combine(
        sets.engaged.MidAcc, 
        sets.engaged.MalignanceHybrid
    )
    sets.engaged.HighAcc.Malignance = set_combine(
        sets.engaged.HighAcc, 
        sets.engaged.MalignanceHybrid
    )
    sets.engaged.STP.Malignance = set_combine(
        sets.engaged.STP, 
        sets.engaged.MalignanceHybrid
    )

    sets.engaged.DW.Malignance = set_combine(
        sets.engaged.DW,
        sets.engaged.MalignanceHybrid.NoHaste
    )
    sets.engaged.DW.LowAcc.Malignance = set_combine(
        sets.engaged.DW.LowAcc,
        sets.engaged.MalignanceHybrid.NoHaste
    )
    sets.engaged.DW.MidAcc.Malignance = set_combine(
        sets.engaged.DW.MidAcc,
        sets.engaged.MalignanceHybrid.NoHaste
    )
    sets.engaged.DW.HighAcc.Malignance = set_combine(
        sets.engaged.DW.HighAcc,
        sets.engaged.MalignanceHybrid.NoHaste
    )
    sets.engaged.DW.STP.Malignance = set_combine(
        sets.engaged.DW.STP,
        sets.engaged.MalignanceHybrid.NoHaste
    )

    sets.engaged.DW.Malignance.LowHaste = set_combine(
        sets.engaged.DW.LowHaste,
        sets.engaged.MalignanceHybrid.LowHaste
    )
    sets.engaged.DW.LowAcc.Malignance.LowHaste = set_combine(
        sets.engaged.DW.LowAcc.LowHaste,
        sets.engaged.MalignanceHybrid.LowHaste
    )
    sets.engaged.DW.MidAcc.Malignance.LowHaste = set_combine(
        sets.engaged.DW.MidAcc.LowHaste,
        sets.engaged.MalignanceHybrid.LowHaste
    )
    sets.engaged.DW.HighAcc.Malignance.LowHaste = set_combine(
        sets.engaged.DW.HighAcc.LowHaste,
        sets.engaged.MalignanceHybrid.LowHaste
    )
    sets.engaged.DW.STP.Malignance.LowHaste = set_combine(
        sets.engaged.DW.STP.LowHaste,
        sets.engaged.MalignanceHybrid.LowHaste
    )

    sets.engaged.DW.Malignance.MidHaste = set_combine(
        sets.engaged.DW.MidHaste,
        sets.engaged.MalignanceHybrid.MidHaste
    )
    sets.engaged.DW.LowAcc.Malignance.MidHaste = set_combine(
        sets.engaged.DW.LowAcc.MidHaste,
        sets.engaged.MalignanceHybrid.MidHaste
    )
    sets.engaged.DW.MidAcc.Malignance.MidHaste = set_combine(
        sets.engaged.DW.MidAcc.MidHaste,
        sets.engaged.MalignanceHybrid.MidHaste
    )
    sets.engaged.DW.HighAcc.Malignance.MidHaste = set_combine(
        sets.engaged.DW.HighAcc.MidHaste,
        sets.engaged.MalignanceHybrid.MidHaste
    )
    sets.engaged.DW.STP.Malignance.MidHaste = set_combine(
        sets.engaged.DW.STP.MidHaste,
        sets.engaged.MalignanceHybrid.MidHaste
    )

    sets.engaged.DW.Malignance.HighHaste = set_combine(
        sets.engaged.DW.HighHaste,
        sets.engaged.MalignanceHybrid.MidHaste
    )
    sets.engaged.DW.LowAcc.Malignance.HighHaste = set_combine(
        sets.engaged.DW.LowAcc.HighHaste,
        sets.engaged.MalignanceHybrid.MidHaste
    )
    sets.engaged.DW.MidAcc.Malignance.HighHaste = set_combine(
        sets.engaged.DW.MidAcc.HighHaste,
        sets.engaged.MalignanceHybrid.MidHaste
    )
    sets.engaged.DW.HighAcc.Malignance.HighHaste = set_combine(
        sets.engaged.DW.HighAcc.HighHaste,
        sets.engaged.MalignanceHybrid.MidHaste
    )
    sets.engaged.DW.STP.Malignance.HighHaste = set_combine(
        sets.engaged.DW.HighHaste.STP,
        sets.engaged.MalignanceHybrid.MidHaste
    )

    sets.engaged.DW.Malignance.MaxHaste = set_combine(
        sets.engaged.DW.MaxHaste,
        sets.engaged.MalignanceHybrid
    )
    sets.engaged.DW.LowAcc.Malignance.MaxHaste = set_combine(
        sets.engaged.DW.LowAcc.MaxHaste,
        sets.engaged.MalignanceHybrid
    )
    sets.engaged.DW.MidAcc.Malignance.MaxHaste = set_combine(
        sets.engaged.DW.MidAcc.MaxHaste,
        sets.engaged.MalignanceHybrid
    )
    sets.engaged.DW.HighAcc.Malignance.MaxHaste = set_combine(
        sets.engaged.DW.HighAcc.MaxHaste,
        sets.engaged.MalignanceHybrid
    )
    sets.engaged.DW.STP.Malignance.MaxHaste = set_combine(
        sets.engaged.DW.STP.MaxHaste,
        sets.engaged.MalignanceHybrid
    )

    sets.engaged.DW.Malignance.MaxHastePlus = set_combine(
        sets.engaged.DW.MaxHastePlus,
        sets.engaged.MalignanceHybrid
    )
    sets.engaged.DW.LowAcc.Malignance.MaxHastePlus = set_combine(
        sets.engaged.DW.LowAcc.MaxHastePlus,
        sets.engaged.MalignanceHybrid
    )
    sets.engaged.DW.MidAcc.Malignance.MaxHastePlus = set_combine(
        sets.engaged.DW.MidAcc.MaxHastePlus,
        sets.engaged.MalignanceHybrid
    )
    sets.engaged.DW.HighAcc.Malignance.MaxHastePlus = set_combine(
        sets.engaged.DW.HighAcc.MaxHastePlus,
        sets.engaged.MalignanceHybrid
    )
    sets.engaged.DW.STP.Malignance.MaxHastePlus = set_combine(
        sets.engaged.DW.STP.MaxHastePlus,
        sets.engaged.MalignanceHybrid
    )

    sets.engaged.Nyame = set_combine(
        sets.engaged, 
        sets.engaged.NyameHybrid
    )
    sets.engaged.LowAcc.Nyame = set_combine(
        sets.engaged.LowAcc, 
        sets.engaged.NyameHybrid
    )
    sets.engaged.MidAcc.Nyame = set_combine(
        sets.engaged.MidAcc, 
        sets.engaged.NyameHybrid
    )
    sets.engaged.HighAcc.Nyame = set_combine(
        sets.engaged.HighAcc, 
        sets.engaged.NyameHybrid
    )
    sets.engaged.STP.Nyame = set_combine(
        sets.engaged.STP, 
        sets.engaged.NyameHybrid
    )

    sets.engaged.DW.Nyame = set_combine(
        sets.engaged.DW, 
        sets.engaged.NyameHybrid
    )
    sets.engaged.DW.LowAcc.Nyame = set_combine(
        sets.engaged.DW.LowAcc, 
        sets.engaged.NyameHybrid
    )
    sets.engaged.DW.MidAcc.Nyame = set_combine(
        sets.engaged.DW.MidAcc, 
        sets.engaged.NyameHybrid
    )
    sets.engaged.DW.HighAcc.Nyame = set_combine(
        sets.engaged.DW.HighAcc, 
        sets.engaged.NyameHybrid
    )
    sets.engaged.DW.STP.Nyame = set_combine(
        sets.engaged.DW.STP, 
        sets.engaged.NyameHybrid
    )

    sets.engaged.DW.Nyame.LowHaste = set_combine(
        sets.engaged.DW.LowHaste, 
        sets.engaged.NyameHybrid
    )
    sets.engaged.DW.LowAcc.Nyame.LowHaste = set_combine(
        sets.engaged.DW.LowAcc.LowHaste, 
        sets.engaged.NyameHybrid
    )
    sets.engaged.DW.MidAcc.Nyame.LowHaste = set_combine(
        sets.engaged.DW.MidAcc.LowHaste, 
        sets.engaged.NyameHybrid
    )
    sets.engaged.DW.HighAcc.Nyame.LowHaste = set_combine(
        sets.engaged.DW.HighAcc.LowHaste, 
        sets.engaged.NyameHybrid
    )
    sets.engaged.DW.STP.Nyame.LowHaste = set_combine(
        sets.engaged.DW.STP.LowHaste, 
        sets.engaged.NyameHybrid
    )

    sets.engaged.DW.Nyame.MidHaste = set_combine(
        sets.engaged.DW.MidHaste, 
        sets.engaged.NyameHybrid
    )
    sets.engaged.DW.LowAcc.Nyame.MidHaste = set_combine(
        sets.engaged.DW.LowAcc.MidHaste, 
        sets.engaged.NyameHybrid
    )
    sets.engaged.DW.MidAcc.Nyame.MidHaste = set_combine(
        sets.engaged.DW.MidAcc.MidHaste, 
        sets.engaged.NyameHybrid
    )
    sets.engaged.DW.HighAcc.Nyame.MidHaste = set_combine(
    sets.engaged.DW.HighAcc.MidHaste, 
        sets.engaged.NyameHybrid
    )
    sets.engaged.DW.STP.Nyame.MidHaste = set_combine(
        sets.engaged.DW.STP.MidHaste, 
        sets.engaged.NyameHybrid
    )

    sets.engaged.DW.Nyame.HighHaste = set_combine(
        sets.engaged.DW.HighHaste, 
        sets.engaged.NyameHybrid
    )
    sets.engaged.DW.LowAcc.Nyame.HighHaste = set_combine(
        sets.engaged.DW.LowAcc.HighHaste, 
        sets.engaged.NyameHybrid
    )
    sets.engaged.DW.MidAcc.Nyame.HighHaste = set_combine(
        sets.engaged.DW.MidAcc.HighHaste, 
        sets.engaged.NyameHybrid
    )
    sets.engaged.DW.HighAcc.Nyame.HighHaste = set_combine(
        sets.engaged.DW.HighAcc.HighHaste, 
        sets.engaged.NyameHybrid
    )
    sets.engaged.DW.STP.Nyame.HighHaste = set_combine(
        sets.engaged.DW.HighHaste.STP, 
        sets.engaged.NyameHybrid
    )

    sets.engaged.DW.Nyame.MaxHaste = set_combine(
        sets.engaged.DW.MaxHaste, 
        sets.engaged.NyameHybrid
    )
    sets.engaged.DW.LowAcc.Nyame.MaxHaste = set_combine(
        sets.engaged.DW.LowAcc.MaxHaste, 
        sets.engaged.NyameHybrid
    )
    sets.engaged.DW.MidAcc.Nyame.MaxHaste = set_combine(
        sets.engaged.DW.MidAcc.MaxHaste, 
        sets.engaged.NyameHybrid
    )
    sets.engaged.DW.HighAcc.Nyame.MaxHaste = set_combine(
        sets.engaged.DW.HighAcc.MaxHaste, 
        sets.engaged.NyameHybrid
    )
    sets.engaged.DW.STP.Nyame.MaxHaste = set_combine(
        sets.engaged.DW.STP.MaxHaste, 
        sets.engaged.NyameHybrid
    )

    sets.engaged.DW.Nyame.MaxHastePlus = set_combine(
        sets.engaged.DW.MaxHastePlus, 
        sets.engaged.NyameHybrid
    )
    sets.engaged.DW.LowAcc.Nyame.MaxHastePlus = set_combine(
        sets.engaged.DW.LowAcc.MaxHastePlus, 
        sets.engaged.NyameHybrid
    )
    sets.engaged.DW.MidAcc.Nyame.MaxHastePlus = set_combine(
        sets.engaged.DW.MidAcc.MaxHastePlus, 
        sets.engaged.NyameHybrid
    )
    sets.engaged.DW.HighAcc.Nyame.MaxHastePlus = set_combine(
        sets.engaged.DW.HighAcc.MaxHastePlus, 
        sets.engaged.NyameHybrid
    )
    sets.engaged.DW.STP.Nyame.MaxHastePlus = set_combine(
        sets.engaged.DW.STP.MaxHastePlus, 
        sets.engaged.NyameHybrid
    )

end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
function job_precast(spell, action, spellMap, eventArgs)
    -- Check that proper ammo is available if we're using ranged attacks or similar.
    if spell.action_type == 'Ranged Attack' or spell.type == 'WeaponSkill' or spell.type == 'CorsairShot' then
        do_bullet_checks(spell, spellMap, eventArgs)
    end

    if spell.english == 'Fold' and buffactive['Bust'] == 2 then
        if sets.precast.FoldDoubleBust then
            equip(sets.precast.FoldDoubleBust)
            eventArgs.handled = true
        end
    end
    if spellMap == 'Utsusemi' then
        if buffactive['Copy Image (3)'] or buffactive['Copy Image (4+)'] then
            cancel_spell()
            add_to_chat(123, '**!! '..spell.english..' Canceled: [3+ IMAGES] !!**')
            eventArgs.handled = true
            return
        elseif buffactive['Copy Image'] or buffactive['Copy Image (2)'] then
            send_command('cancel 66; cancel 444; cancel Copy Image; cancel Copy Image (2)')
        end
    end
end

function job_post_precast(spell, action, spellMap, eventArgs)
    if (spell.type == 'CorsairRoll' or spell.english == "Double-Up") then
        if player.status ~= 'Engaged' and state.WeaponLock.value == false then
            equip(sets.precast.CorsairRoll.Duration)
        end
        if state.LuzafRing.value then
            equip(sets.precast.LuzafRing)
        end
    end
    if spell.action_type == 'Ranged Attack' then
        special_ammo_check()
        if flurry == 2 then
            equip(sets.precast.RA.Flurry2)
        elseif flurry == 1 then
            equip(sets.precast.RA.Flurry1)
        end
    elseif spell.type == 'WeaponSkill' then
        if spell.skill == 'Marksmanship' then
            special_ammo_check()
        end
        -- Replace TP-bonus gear if not needed.
        if spell.english == 'Leaden Salute' or spell.english == 'Aeolian Edge' and player.tp > 2900 then
            equip(sets.FullTP)
        end
        if elemental_ws:contains(spell.name) then
            -- Matching double weather (w/o day conflict).
            if spell.element == world.weather_element and (get_weather_intensity() == 2 and spell.element ~= elements.weak_to[world.day_element]) then
                equip({waist="Hachirin-no-Obi"})
            -- Target distance under 1.7 yalms.
            elseif spell.target.distance < (1.7 + spell.target.model_size) then
                equip({waist="Orpheus's Sash"})
            -- Matching day and weather.
            elseif spell.element == world.day_element and spell.element == world.weather_element then
                equip({waist="Hachirin-no-Obi"})
            -- Target distance under 8 yalms.
            elseif spell.target.distance < (8 + spell.target.model_size) then
                equip({waist="Orpheus's Sash"})
            -- Match day or weather.
            elseif spell.element == world.day_element or spell.element == world.weather_element then
                equip({waist="Hachirin-no-Obi"})
            end
        end
    end
end

function job_post_midcast(spell, action, spellMap, eventArgs)
    if spell.type == 'CorsairShot' then
        if (spell.english ~= 'Light Shot' and spell.english ~= 'Dark Shot') then
            -- Matching double weather (w/o day conflict).
            if spell.element == world.weather_element and (get_weather_intensity() == 2 and spell.element ~= elements.weak_to[world.day_element]) then
                equip({waist="Hachirin-no-Obi"})
            -- Target distance under 1.7 yalms.
            elseif spell.target.distance < (1.7 + spell.target.model_size) then
                equip({waist="Orpheus's Sash"})
            -- Matching day and weather.
            elseif spell.element == world.day_element and spell.element == world.weather_element then
                equip({waist="Hachirin-no-Obi"})
            -- Target distance under 8 yalms.
            elseif spell.target.distance < (8 + spell.target.model_size) then
                equip({waist="Orpheus's Sash"})
            -- Match day or weather.
            elseif spell.element == world.day_element or spell.element == world.weather_element then
                equip({waist="Hachirin-no-Obi"})
            end
            if state.QDMode.value == 'Enhance' then
                equip(sets.midcast.CorsairShot.Enhance)
            elseif state.QDMode.value == 'TH' then
                equip(sets.midcast.CorsairShot)
                equip(sets.TreasureHunter)
            elseif state.QDMode.value == 'STP' then
                equip(sets.midcast.CorsairShot.STP)
            end
        end
    elseif spell.action_type == 'Ranged Attack' then
        if buffactive['Triple Shot'] then
            equip(sets.TripleShot)
            if buffactive['Aftermath: Lv.3'] and player.equipment.ranged == "Armageddon" then
                equip(sets.TripleShotCritical)
                if (spell.target.distance < (7 + spell.target.model_size)) and (spell.target.distance > (5 + spell.target.model_size)) then
                    equip(sets.TrueShot)
                end
            end
        elseif buffactive['Aftermath: Lv.3'] and player.equipment.ranged == "Armageddon" then
            equip(sets.midcast.RA.Critical)
            if (spell.target.distance < (7 + spell.target.model_size)) and (spell.target.distance > (5 + spell.target.model_size)) then
                equip(sets.TrueShot)
            end
        end
    end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
    if (spell.type == 'CorsairRoll' or spell.english == "Double-Up") and not spell.interrupted then
        display_roll_info(spell)
    end
    if spell.english == "Light Shot" then
        send_command('@timers c "Light Shot ['..spell.target.name..']" 60 down abilities/00195.png')
    end
    if player.status ~= 'Engaged' and state.WeaponLock.value == false then
        check_weaponset()
    end
end

function job_buff_change(buff,gain)
-- If we gain or lose any flurry buffs, adjust gear.
    if S{'flurry'}:contains(buff:lower()) then
        if not gain then
            flurry = nil
            --add_to_chat(122, "Flurry status cleared.")
        end
        if not midaction() then
            job_handle_equipping_gear(player.status)
        end
    end

--    if buffactive['Reive Mark'] then
--        if gain then
--            equip(sets.Reive)
--            disable('neck')
--        else
--            enable('neck')
--        end
--    end

    if buff == "doom" then
        if gain then
            equip(sets.buff.Doom)
            --send_command('@input /p Doomed.')
            disable('ring1','ring2','waist')
        else
            enable('ring1','ring2','waist')
            job_handle_equipping_gear(player.status)
        end
    end

end

-- Handle notifications of general user state change.
function job_state_change(stateField, newValue, oldValue)
    if state.WeaponLock.value == true then
        disable('ranged')
    else
        enable('ranged')
    end

    -- if state.WeaponSet.value == 'Slashing' then
    --     send_command('bind ^numpad7 input /ws "Savage Blade" <t>')
    --     send_command('bind ^numpad5 input /ws "Requiescat" <t>')
    --     send_command('bind ^numpad1 input /ws "Circle Blade" <t>')
    --     send_command('bind ^numpad2 input /ws "Burning Blade" <t>')
    -- else
    --     send_command('bind ^numpad7 input /ws "Exenterator" <t>')
    --     send_command('bind ^numpad5 input /ws "Evisceration" <t>')
    --     send_command('bind ^numpad1 input /ws "Aeolian Edge" <t>')
    --     send_command('bind ^numpad2 input /ws "Wasp Sting" <t>')
    -- end

    check_weaponset()
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

-- Called by the 'update' self-command, for common needs.
-- Set eventArgs.handled to true if we don't want automatic equipping of gear.
function job_handle_equipping_gear(playerStatus, eventArgs)
    check_gear()
    update_combat_form()
    determine_haste_group()
    check_moving()
end

function job_update(cmdParams, eventArgs)
    job_handle_equipping_gear(player.status)
end

function update_combat_form()
    if DW == true then
        state.CombatForm:set('DW')
    elseif DW == false then
        state.CombatForm:reset()
    end
end

-- Modify the default melee set after it was constructed.
function customize_melee_set(meleeSet)
    check_weaponset()

    return meleeSet
end

function get_custom_wsmode(spell, action, spellMap)
    local wsmode
    if spell.skill == 'Marksmanship' then
        if state.RangedMode.value == 'Acc' or state.RangedMode.value == 'HighAcc' then
            wsmode = 'Acc'
        end
    else
        if state.OffenseMode.value == 'Acc' or state.OffenseMode.value == 'HighAcc' then
            wsmode = 'Acc'
        end
    end

    return wsmode
end

-- Modify the default idle set after it was constructed.
function customize_idle_set(idleSet)
    -- if state.CP.current == 'on' then
    --     equip(sets.CP)
    --     disable('back')
    -- else
    --     enable('back')
    -- end
    if state.Auto_Kite.value == true then
       idleSet = set_combine(idleSet, sets.Kiting)
    end

    return idleSet
end

-- -- Handle auto-targetting based on local setup.
-- function job_auto_change_target(spell, action, spellMap, eventArgs)
--     if spell.type == 'CorsairShot' then
--         if state.IgnoreTargetting.value == true then
--             state.IgnoreTargetting:reset()
--             eventArgs.handled = true
--         end

--         eventArgs.SelectNPCTargets = state.SelectqdTarget.value
--     end
-- end

-- Set eventArgs.handled to true if we don't want the automatic display to be run.
function display_current_job_state(eventArgs)
    local cf_msg = ''
    if state.CombatForm.has_value then
        cf_msg = ' (' ..state.CombatForm.value.. ')'
    end

    local m_msg = state.OffenseMode.value
    if state.HybridMode.value ~= 'Normal' then
        m_msg = m_msg .. '/' ..state.HybridMode.value
    end

    local ws_msg = state.WeaponskillMode.value

    local qd_msg = '(' ..string.sub(state.QDMode.value,1,1).. ')'

    local e_msg = state.Mainqd.current
    if state.UseAltqd.value == true then
        e_msg = e_msg .. '/'..state.Altqd.current
    end

    local d_msg = 'None'
    if state.DefenseMode.value ~= 'None' then
        d_msg = state.DefenseMode.value .. state[state.DefenseMode.value .. 'DefenseMode'].value
    end

    local i_msg = state.IdleMode.value

    local msg = ''
    if state.Kiting.value then
        msg = msg .. ' Kiting: On |'
    end

    add_to_chat(002, '| ' ..string.char(31,210).. 'Melee' ..cf_msg.. ': ' ..string.char(31,001)..m_msg.. string.char(31,002)..  ' |'
        ..string.char(31,207).. ' WS: ' ..string.char(31,001)..ws_msg.. string.char(31,002)..  ' |'
        ..string.char(31,060).. ' QD' ..qd_msg.. ': '  ..string.char(31,001)..e_msg.. string.char(31,002)..  ' |'
        ..string.char(31,004).. ' Defense: ' ..string.char(31,001)..d_msg.. string.char(31,002)..  ' |'
        ..string.char(31,008).. ' Idle: ' ..string.char(31,001)..i_msg.. string.char(31,002)..  ' |'
        ..string.char(31,002)..msg)

    eventArgs.handled = true
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

--Read incoming packet to differentiate between Haste/Flurry I and II
windower.register_event('action',
    function(act)
        --check if you are a target of spell
        local actionTargets = act.targets
        playerId = windower.ffxi.get_player().id
        isTarget = false
        for _, target in ipairs(actionTargets) do
            if playerId == target.id then
                isTarget = true
            end
        end
        if isTarget == true then
            if act.category == 4 then
                local param = act.param
                if param == 845 and flurry ~= 2 then
                    --add_to_chat(122, 'Flurry Status: Flurry I')
                    flurry = 1
                elseif param == 846 then
                    --add_to_chat(122, 'Flurry Status: Flurry II')
                    flurry = 2
              end
            end
        end
    end)

function determine_haste_group()
    classes.CustomMeleeGroups:clear()
    if DW == true then
        if DW_needed <= 11 then
            classes.CustomMeleeGroups:append('MaxHaste')
        elseif DW_needed > 11 and DW_needed <= 21 then
            classes.CustomMeleeGroups:append('MaxHastePlus')
        elseif DW_needed > 21 and DW_needed <= 27 then
            classes.CustomMeleeGroups:append('HighHaste')
        elseif DW_needed > 27 and DW_needed <= 31 then
            classes.CustomMeleeGroups:append('MidHaste')
        elseif DW_needed > 31 and DW_needed <= 42 then
            classes.CustomMeleeGroups:append('LowHaste')
        elseif DW_needed > 42 then
            classes.CustomMeleeGroups:append('')
        end
    end
end

function job_self_command(cmdParams, eventArgs)
    if cmdParams[1] == 'qd' then
        if cmdParams[2] == 't' then
            state.IgnoreTargetting:set()
        end

        local doqd = ''
        if state.UseAltqd.value == true then
            doqd = state[state.Currentqd.current..'qd'].current
            state.Currentqd:cycle()
        else
            doqd = state.Mainqd.current
        end

        send_command('@input /ja "'..doqd..'" <t>')
    end

    gearinfo(cmdParams, eventArgs)
end

function gearinfo(cmdParams, eventArgs)
    if cmdParams[1] == 'gearinfo' then
        if type(tonumber(cmdParams[2])) == 'number' then
            if tonumber(cmdParams[2]) ~= DW_needed then
            DW_needed = tonumber(cmdParams[2])
            DW = true
            end
        elseif type(cmdParams[2]) == 'string' then
            if cmdParams[2] == 'false' then
                DW_needed = 0
                DW = false
            end
        end
        if type(tonumber(cmdParams[3])) == 'number' then
            if tonumber(cmdParams[3]) ~= Haste then
                Haste = tonumber(cmdParams[3])
            end
        end
        if type(cmdParams[4]) == 'string' then
            if cmdParams[4] == 'true' then
                moving = true
            elseif cmdParams[4] == 'false' then
                moving = false
            end
        end
        if not midaction() then
            job_update()
        end
    end
end

function define_roll_values()
    rolls = {
        ["Corsair's Roll"] =    {lucky=5, unlucky=9, bonus="Experience Points"},
        ["Ninja Roll"] =        {lucky=4, unlucky=8, bonus="Evasion"},
        ["Hunter's Roll"] =     {lucky=4, unlucky=8, bonus="Accuracy"},
        ["Chaos Roll"] =        {lucky=4, unlucky=8, bonus="Attack"},
        ["Magus's Roll"] =      {lucky=2, unlucky=6, bonus="Magic Defense"},
        ["Healer's Roll"] =     {lucky=3, unlucky=7, bonus="Cure Potency Received"},
        ["Drachen Roll"] =      {lucky=4, unlucky=8, bonus="Pet Magic Accuracy/Attack"},
        ["Choral Roll"] =       {lucky=2, unlucky=6, bonus="Spell Interruption Rate"},
        ["Monk's Roll"] =       {lucky=3, unlucky=7, bonus="Subtle Blow"},
        ["Beast Roll"] =        {lucky=4, unlucky=8, bonus="Pet Attack"},
        ["Samurai Roll"] =      {lucky=2, unlucky=6, bonus="Store TP"},
        ["Evoker's Roll"] =     {lucky=5, unlucky=9, bonus="Refresh"},
        ["Rogue's Roll"] =      {lucky=5, unlucky=9, bonus="Critical Hit Rate"},
        ["Warlock's Roll"] =    {lucky=4, unlucky=8, bonus="Magic Accuracy"},
        ["Fighter's Roll"] =    {lucky=5, unlucky=9, bonus="Double Attack Rate"},
        ["Puppet Roll"] =       {lucky=3, unlucky=7, bonus="Pet Magic Attack/Accuracy"},
        ["Gallant's Roll"] =    {lucky=3, unlucky=7, bonus="Defense"},
        ["Wizard's Roll"] =     {lucky=5, unlucky=9, bonus="Magic Attack"},
        ["Dancer's Roll"] =     {lucky=3, unlucky=7, bonus="Regen"},
        ["Scholar's Roll"] =    {lucky=2, unlucky=6, bonus="Conserve MP"},
        ["Naturalist's Roll"] = {lucky=3, unlucky=7, bonus="Enh. Magic Duration"},
        ["Runeist's Roll"] =    {lucky=4, unlucky=8, bonus="Magic Evasion"},
        ["Bolter's Roll"] =     {lucky=3, unlucky=9, bonus="Movement Speed"},
        ["Caster's Roll"] =     {lucky=2, unlucky=7, bonus="Fast Cast"},
        ["Courser's Roll"] =    {lucky=3, unlucky=9, bonus="Snapshot"},
        ["Blitzer's Roll"] =    {lucky=4, unlucky=9, bonus="Attack Delay"},
        ["Tactician's Roll"] =  {lucky=5, unlucky=8, bonus="Regain"},
        ["Allies' Roll"] =      {lucky=3, unlucky=10, bonus="Skillchain Damage"},
        ["Miser's Roll"] =      {lucky=5, unlucky=7, bonus="Save TP"},
        ["Companion's Roll"] =  {lucky=2, unlucky=10, bonus="Pet Regain and Regen"},
        ["Avenger's Roll"] =    {lucky=4, unlucky=8, bonus="Counter Rate"},
    }
end

function display_roll_info(spell)
    rollinfo = rolls[spell.english]
    local rollsize = (state.LuzafRing.value and string.char(129,157)) or ''

    if rollinfo then
        add_to_chat(001, string.char(129,115).. '  ' ..string.char(31,210)..spell.english..string.char(31,001)..
            ' : '..rollinfo.bonus.. ' ' ..string.char(129,116).. ' ' ..string.char(129,195)..
            '  Lucky: ' ..string.char(31,204).. tostring(rollinfo.lucky)..string.char(31,001).. ' /' ..
            ' Unlucky: ' ..string.char(31,167).. tostring(rollinfo.unlucky)..string.char(31,002)..
            '  ' ..rollsize)
    end
end


-- Determine whether we have sufficient ammo for the action being attempted.
function do_bullet_checks(spell, spellMap, eventArgs)
    local bullet_name
    local bullet_min_count = 1

    if spell.type == 'WeaponSkill' then
        if spell.skill == "Marksmanship" then
            if spell.english == 'Wildfire' or spell.english == 'Leaden Salute' then
                -- magical weaponskills
                bullet_name = gear.MAbullet
            else
                -- physical weaponskills
                bullet_name = gear.WSbullet
            end
        else
            -- Ignore non-ranged weaponskills
            return
        end
    elseif spell.type == 'CorsairShot' then
        bullet_name = gear.QDbullet
    elseif spell.action_type == 'Ranged Attack' then
        bullet_name = gear.RAbullet
        if buffactive['Triple Shot'] then
            bullet_min_count = 3
        end
    end

    local available_bullets = player.inventory[bullet_name] or player.wardrobe2[bullet_name]

    -- If no ammo is available, give appropriate warning and end.
    if not available_bullets then
        if spell.type == 'CorsairShot' and player.equipment.ammo ~= 'empty' then
            add_to_chat(104, 'No Quick Draw ammo left.  Using what\'s currently equipped ('..player.equipment.ammo..').')
            return
        elseif spell.type == 'WeaponSkill' and player.equipment.ammo == gear.RAbullet then
            add_to_chat(104, 'No weaponskill ammo left.  Using what\'s currently equipped (standard ranged bullets: '..player.equipment.ammo..').')
            return
        else
            add_to_chat(104, 'No ammo ('..tostring(bullet_name)..') available for that action.')
            eventArgs.cancel = true
            return
        end
    end

    -- Don't allow shooting or weaponskilling with ammo reserved for quick draw.
    if spell.type ~= 'CorsairShot' and bullet_name == gear.QDbullet and available_bullets.count <= bullet_min_count then
        add_to_chat(104, 'No ammo will be left for Quick Draw.  Cancelling.')
        eventArgs.cancel = true
        return
    end

    -- Low ammo warning.
    if spell.type ~= 'CorsairShot' and state.warned.value == false
        and available_bullets.count > 1 and available_bullets.count <= options.ammo_warning_limit then
        local msg = '*****  LOW AMMO WARNING: '..bullet_name..' *****'
        --local border = string.repeat("*", #msg)
        local border = ""
        for i = 1, #msg do
            border = border .. "*"
        end

        add_to_chat(104, border)
        add_to_chat(104, msg)
        add_to_chat(104, border)

        state.warned:set()
    elseif available_bullets.count > options.ammo_warning_limit and state.warned then
        state.warned:reset()
    end

    if player.equipment.range == "Anarchy" then
        -- Equip "Bronze Bullet" in the ammo slot
        equip(gear.TrialBullet)
    end
end

function special_ammo_check()
    -- Stop if Animikii/Hauksbok equipped
    if no_shoot_ammo:contains(player.equipment.ammo) then
        cancel_spell()
        add_to_chat(123, '** Action Canceled: [ '.. player.equipment.ammo .. ' equipped!! ] **')
        return
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

function update_offense_mode()
    if (player.sub_job == 'NIN' and player.sub_job_level > 9) or (player.sub_job == 'DNC' and player.sub_job_level > 19) then
        state.CombatForm:set('DW')
    else
        state.CombatForm:reset()
    end
end

function check_moving()
    if state.DefenseMode.value == 'None'  and state.Kiting.value == false then
        if state.Auto_Kite.value == false and moving then
            state.Auto_Kite:set(true)
        elseif state.Auto_Kite.value == true and moving == false then
            state.Auto_Kite:set(false)
        end
    end
end

function check_gear()
    if no_swap_gear:contains(player.equipment.left_ring) then
        disable("ring1")
    else
        enable("ring1")
    end
    if no_swap_gear:contains(player.equipment.right_ring) then
        disable("ring2")
    else
        enable("ring2")
    end
    if no_swap_gear:contains(player.equipment.waist) then
        disable("waist")
    else
        enable("waist")
    end
end

function check_weaponset()
    --if state.OffenseMode.value == 'LowAcc' or state.OffenseMode.value == 'MidAcc' or state.OffenseMode.value == 'HighAcc' then
    --    equip(sets[state.WeaponSet.current].Acc)
    --else
    equip(sets[state.Gun.current])
    equip(sets[state.WeaponSet.current])
    --end
    if (player.sub_job ~= 'NIN' and player.sub_job ~= 'DNC') then
        equip(sets.DefaultShield)
    elseif player.sub_job == 'NIN' and player.sub_job_level < 10 or player.sub_job == 'DNC' and player.sub_job_level < 20 then
        equip(sets.DefaultShield)
    end
end

windower.register_event('zone change',
    function()
        if no_swap_gear:contains(player.equipment.left_ring) then
            enable("ring1")
            equip(sets.idle)
        end
        if no_swap_gear:contains(player.equipment.right_ring) then
            enable("ring2")
            equip(sets.idle)
        end
        if no_swap_gear:contains(player.equipment.waist) then
            enable("waist")
            equip(sets.idle)
        end
    end
)

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    if player.sub_job == 'DNC' then
        set_macro_page(1, 17)
    elseif player.sub_job == 'NIN' then
        set_macro_page(2, 17)
    elseif player.sub_job == 'WAR' then
        set_macro_page(3, 17)
    else
        set_macro_page(1, 17)
    end
end

function set_lockstyle()
    send_command('wait 2; input /lockstyleset ' .. lockstyleset)
end
