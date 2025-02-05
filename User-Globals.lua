-------------------------------------------------------------------------------------------------------------------
-- Modify the sets table.  Any gear sets that are added to the sets table need to
-- be defined within this function, because sets isn't available until after the
-- include is complete.  It is called at the end of basic initialization in Mote-Include.
-------------------------------------------------------------------------------------------------------------------
function define_global_sets()
    gear.DNC_Sub_Waltz={
        head="Mummu Bonnet +2",
        hands="Slither Gloves +1",
        legs="Dashing Subligar",
        feet={ name="Herculean Boots", augments={'Accuracy+7','"Waltz" potency +9%','AGI+4',}},
        waist="Aristo Belt",
        left_ear="Enchntr. Earring +1",
        left_ring="Asklepian Ring",
        right_ring="Valseur's Ring",
    }
end