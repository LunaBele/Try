#!/usr/bin/env lua

--[[
================================================================================
                              MAIN.LUA
================================================================================
Basic Lua script template for custom scripting purposes.

This file provides a foundation for Lua scripting with:
- Basic structure and organization
- Example functions and variables
- Error handling examples
- Modular design for easy expansion

Author: Custom Script Template
Date: August 31, 2025
================================================================================
--]]

-- Global variables section
local SCRIPT_VERSION = "1.0.0"
local DEBUG_MODE = true

--[[
================================================================================
                            UTILITY FUNCTIONS
================================================================================
--]]

-- Function to print debug messages
local function debug_print(message)
    if DEBUG_MODE then
        print("[DEBUG] " .. tostring(message))
    end
end

-- Function to print formatted messages
local function log_message(level, message)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    print(string.format("[%s] %s: %s", timestamp, level, message))
end

-- Function to safely execute code with error handling
local function safe_execute(func, error_message)
    local success, result = pcall(func)
    if not success then
        log_message("ERROR", error_message or "An error occurred")
        log_message("ERROR", "Details: " .. tostring(result))
        return false, result
    end
    return true, result
end

--[[
================================================================================
                            MAIN FUNCTIONS
================================================================================
--]]

-- Initialize function - called at script startup
local function initialize()
    debug_print("Initializing Main.lua script...")
    log_message("INFO", "Script version: " .. SCRIPT_VERSION)
    log_message("INFO", "Lua version: " .. _VERSION)
    
    -- Add your initialization code here
    -- Examples:
    -- - Load configuration files
    -- - Set up connections
    -- - Initialize variables
    
    return true
end

-- Main processing function
local function main_process()
    debug_print("Starting main processing...")
    
    -- Add your main logic here
    -- This is where the core functionality of your script should go
    
    -- Example: Simple calculation
    local result = 42 * 2
    log_message("INFO", "Example calculation result: " .. result)
    
    -- Example: String manipulation
    local greeting = "Hello, Lua scripting!"
    log_message("INFO", "Greeting message: " .. greeting)
    
    -- Example: Table operations
    local sample_table = {
        name = "Sample Script",
        version = SCRIPT_VERSION,
        items = {"item1", "item2", "item3"}
    }
    
    log_message("INFO", "Sample table created with " .. #sample_table.items .. " items")
    
    return true
end

-- Cleanup function - called before script exit
local function cleanup()
    debug_print("Performing cleanup...")
    log_message("INFO", "Script execution completed successfully")
    
    -- Add cleanup code here
    -- Examples:
    -- - Close file handles
    -- - Save state
    -- - Close connections
    
    return true
end

--[[
================================================================================
                            SCRIPT EXECUTION
================================================================================
--]]

-- Main execution block
local function run_script()
    log_message("INFO", "=== Starting Main.lua Script ===")
    
    -- Initialize
    local init_success = safe_execute(initialize, "Failed to initialize script")
    if not init_success then
        return false
    end
    
    -- Main processing
    local process_success = safe_execute(main_process, "Failed during main processing")
    if not process_success then
        return false
    end
    
    -- Cleanup
    local cleanup_success = safe_execute(cleanup, "Failed during cleanup")
    if not cleanup_success then
        return false
    end
    
    log_message("INFO", "=== Script Completed Successfully ===")
    return true
end

--[[
================================================================================
                            ENTRY POINT
================================================================================
--]]

-- Script entry point
if not pcall(run_script) then
    log_message("FATAL", "Script execution failed with critical error")
    os.exit(1)
end

-- Exit with success code
os.exit(0)

--[[
================================================================================
                            CUSTOMIZATION NOTES
================================================================================

To customize this script for your needs:

1. Modify the global variables section to add your configuration
2. Add your functions in the utility functions section
3. Implement your main logic in the main_process() function
4. Add initialization code in the initialize() function
5. Add cleanup code in the cleanup() function
6. Use log_message() for important messages
7. Use debug_print() for debugging information
8. Set DEBUG_MODE to false for production use

Example usage patterns:
- File operations: io.open(), file:read(), file:write(), file:close()
- String operations: string.match(), string.gsub(), string.format()
- Table operations: table.insert(), table.remove(), table.sort()
- Math operations: math.random(), math.floor(), math.ceil()

For command line arguments, use: arg[1], arg[2], etc.
For environment variables, use: os.getenv("VARIABLE_NAME")

================================================================================
--]]
