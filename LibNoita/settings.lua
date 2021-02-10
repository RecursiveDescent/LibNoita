dofile("data/scripts/lib/mod_settings.lua");

mods = ModGetActiveModIDs();

y, m, d, h, mn, s = GameGetDateAndTimeLocal();

ModSettingSet("secret", mn + s);

local mod_settings = {
    {
		id = "_",
		ui_name = "If this is empty, start a new game and mods will appear here. Changes will take effect the next time the game starts.",
		not_setting = true
	}
};

function CreateMod()
    return {
        category_id = "group_of_settings",
        ui_name = "",
        
        settings = {
            {
                category_id = "sub_group_of_settings",
                ui_name = "Permissions",
                ui_description = "Modify mod permissions.",

                settings = {
                    
                }
            }
        }
    };
end

function CreatePermissions()
    return {
        {
            id = "io",
            ui_name = "IO Library",
            ui_description = "Whether or not this mod gets access to the full IO library.",
            value_default = false,
            
            scope = MOD_SETTING_SCOPE_NEW_GAME
        },
        {
            id = "os",
            ui_name = "OS Library",
            ui_description = "DO NOT GIVE THIS PERMISSION TO MODS YOU DON'T TRUST!\nMods almost never require this library to function!\nWhether or not this mod gets access to the OS library.",
            value_default = false,
            
            scope = MOD_SETTING_SCOPE_NEW_GAME
        },
        {
            id = "require",
            ui_name = "Full Require Access",
            ui_description = "Gives this mod the ability to use require unrestricted.\nThis is a dangerous permission to grant.",
            value_default = false,
            
            scope = MOD_SETTING_SCOPE_NEW_GAME
        }
    };
end

for i, modid in pairs(mods) do
    local mod = CreateMod();

    mod.ui_name = modid;

    local modperms = CreatePermissions();

    for i, v in pairs(modperms) do
        v.id = modid .. "_" .. v.id .. mn + s;

        print(v.id);

        v.change_fn = function(mod_id, gui, in_main_menu, setting, old_value, new_value)
            ModSettingSet(setting.id, new_value);
        end;

        if not ModSettingGet(v.id) then
            ModSettingSet(v.id, false);
        end
        
        table.insert(mod.settings[1].settings, v);
    end

    table.insert(mod_settings, mod);
end
    

function ModSettingsGuiCount()
	return mod_settings_gui_count("LibNoita", mod_settings)
end

-- This function is called to display the settings UI for this mod. Your mod's settings wont be visible in the mod settings menu if this function isn't defined correctly.
function ModSettingsGui( gui, in_main_menu )
	mod_settings_gui("LibNoita", mod_settings, gui, in_main_menu);
end