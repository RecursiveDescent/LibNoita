mods = ModGetActiveModIDs();

-- Sync a secret between the settings and init files so only this mod will know where to find its settings.
-- TODO Make this even more secure/Use a different method of saving settings.
secret = ModSettingGet("secret");

ModSettingRemove("secret");

libraries = {};

preupdate = {};
postupdate = {};
playerspawned = {};
pausepreupdate = {};

function OnWorldPreUpdate()
    for i, ev in pairs(preupdate) do
        ev();
    end
end

function OnWorldPostUpdate()
    for i, ev in pairs(postupdate) do
        ev();
    end
end

function OnPlayerSpawned(player)
    for i, ev in pairs(playerspawned) do
        ev(player);
    end
end

function OnPausePreUpdate()
    for i, ev in pairs(pausepreupdate) do
        ev();
    end
end

function Load(id)
    local dir = "mods/" .. id .. "/";

    pcall(ModMaterialsFileAdd, dir .. "materials.xml");

    local init = loadfile(dir .. "init.lua");

    local sandbox = {};

    local Noita = {};

    -- Registers the currently running mod as a library.
    -- The aliases argument specifies a table full of paths that will load the library instead of the original file.
    function Noita:RegisterLibrary(id, aliases)
        if not libraries[id] then
            libraries[id] = init;

            for i, v in pairs(aliases or {}) do
                libraries[v] = init;
            end

            error("");
        end
    end

    for i, v in pairs(_G) do
        if i:sub(1, 2) ~= "On" then
            sandbox[i] = v;
        end
    end

    sandbox.Noita = Noita;

    if not ModSettingGet(id .. "_io_" .. secret) then
        sandbox.io = nil;
    end

    if not ModSettingGet(id .. "_os_" .. secret) then
        sandbox.os = nil;
    end

    if not ModSettingGet(id .. "_require_" .. secret) then
        sandbox.require = nil; -- Stub("require");
    end
    
    sandbox._ID = id;

    -- dofile wants to run in this scope, we can't allow that.
    sandbox.dofile = function(file)
        if libraries[file] then
            sandbox.require = require;

            setfenv(libraries[file], sandbox)();

            return;
        end

        local f = loadfile(file);

        setfenv(f, sandbox)();
    end

    local loaded = {};

    sandbox.dofile_once = function(file)
        if not loaded[file] then
            sandbox.dofile(file);

            loaded[file] = true;
        end
    end

    local success, err = pcall(setfenv(init, sandbox));

    if success then

        if sandbox.OnWorldPreUpdate then
            table.insert(preupdate, sandbox.OnWorldPreUpdate)
        end

        if sandbox.OnWorldPostUpdate then
            table.insert(postupdate, sandbox.OnWorldPostUpdate);
        end

        if sandbox.OnPausePreUpdate then
            table.insert(pausepreupdate, sandbox.OnPausePreUpdate);
        end

        if sandbox.OnModPreInit then
            sandbox.OnModPreInit();
        end

        if sandbox.OnModPreInit then
            sandbox.OnModPreInit();
        end
    else
        print(id .. " failed to load: " .. err);
    end
end

for i, v in pairs(mods) do
    if v ~= "LibNoita" then
        local code = ModTextFileGetContent("mods/" .. v .. "/init.lua");

        -- Make sure the mod isn't loaded twice.
        ModTextFileSetContent("mods/" .. v .. "/init.lua", "if not _ID then return end\n\n" .. code);

        local success, err = pcall(Load, v);

        if not success then
            print("Failed to load " .. v .. ": " .. err);
        end
    end
end