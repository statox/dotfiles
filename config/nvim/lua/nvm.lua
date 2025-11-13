----------------------------------------------------
-- A Node Version Manager integration for Neovim
--
-- This plugin will make the expected Node.js
-- available in Neovim.
--
-- It will add nvm installation dir to the PATH.
--
-- I particularly need it to make nvm-managed node
-- available to lsp servers
--
-- Source:
-- https://github.com/pipoprods/nvm.nvim/blob/main/lua/nvm/init.lua
-- Original license:  GPL-3.0 license
-- https://github.com/pipoprods/nvm.nvim/blob/b93b534/LICENSE
----------------------------------------------------

local M = {}

local nvmrc = ".nvmrc"
local alias_path = os.getenv("HOME") .. "/.nvm/alias"
local default_node = alias_path .. "/default"
local nvm_path = os.getenv("HOME") .. "/.nvm/versions/node/"

-- Check if file exists
local function file_exists(name)
    local f = io.open(name, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

-- resolve a named version (hopefully to a number)
local function resolve(version)
    version = string.gsub(version, "^%s*(.-)%s*$", "%1")  -- sanitise version
    file = io.open(alias_path .. '/' .. version, "rb") -- r read mode and b binary mode
    if not file then
        return nil
    end
    content = file:read("*a") -- *a or *all reads the whole file
    file:close()

    return content
end

-- Get node version from nvmrc file
-- Sanitize it to begin with a 'v'
local function _get_version()
    local file = io.open(nvmrc, "rb") -- r read mode and b binary mode
    if not file then
        file = io.open(default_node, "rb") -- r read mode and b binary mode
        if not file then
            return nil
        end
    end
    local version = file:read("*a") -- *a or *all reads the whole file
    file:close()

    -- version has no number => it is an alias, let's resolve it
    while not string.match(version, "[0-9]") do
        version = resolve(version)
    end

    -- normalise version (eg ensure it's prefixed with "v")
    if string.sub(version, 1, 1) ~= "v" then
        version = "v" .. version
    end
    return (string.gsub(version, "^%s*(.-)%s*$", "%1"))  -- sanitise version
end

local function get_version()
    local ok, result = pcall(_get_version)

    if not ok then
        -- result contains the error message
        print("Error:", result)
        print("Something went wrong when getting nvm node version in _get_version()")
        print("You probably need to setup nvm, or check the nvm.lua file in your neovim config")
        return
    end

    return result
end

-- Get path to Node.js version
local function get_path(version)
    return nvm_path .. version .. "/bin/"
end

-- Check if a Node.js version is installed
local function check_installed(version)
    return file_exists(get_path(version) .. "node")
end

-- Activate a Node.js version
local function activate()
    local version = get_version()
    if version ~= nil then
        if not check_installed(version) then
            vim.notify("Required Node.js " .. version .. " is not installed, please install it", "error")
        else
            -- vim.notify("Using Node.js " .. version)
            vim.env.PATH = get_path(version) .. ":" .. vim.env.PATH
        end
    end
end

-- Deactivate a Node.js version
local function deactivate()
    local version = get_version()
    vim.env.PATH = string.gsub(vim.env.PATH, get_path(version) .. ":", "")
end

-- Callback when entering a directory or vim
local function enter()
    if file_exists(nvmrc) or file_exists(default_node) then
        activate()
    end
end

-- Callback when entering a directory or vim
local function leave()
    if file_exists(nvmrc) or file_exists(default_node) then
        deactivate()
    end
end

function M.setup()
    vim.api.nvim_create_autocmd("DirChangedPre", {
        callback = leave,
    })
    vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = leave,
    })
    vim.api.nvim_create_autocmd("DirChanged", {
        callback = enter,
    })
    vim.api.nvim_create_autocmd("VimEnter", {
        callback = enter,
    })
end

M.setup()
return M
