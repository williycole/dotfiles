-- project-config.lua
local M = {}

-- Detect project type based on files present
function M.detect_project_type()
  local has_package_json = vim.fn.filereadable('package.json') == 1
  local has_tsconfig = vim.fn.filereadable('tsconfig.json') == 1
  local has_angular_json = vim.fn.filereadable('angular.json') == 1
  
  if has_angular_json then
    return "angular"
  elseif has_tsconfig then
    return "typescript"
  elseif has_package_json then
    return "javascript"
  else
    return "unknown"
  end
end

-- Get project-specific settings
function M.get_project_settings()
  local project_type = M.detect_project_type()
  local settings = {}
  
  if project_type == "angular" then
    settings.useAngularLanguageService = true
    -- Other Angular-specific settings
  elseif project_type == "typescript" then
    -- TypeScript project settings
  end
  
  return settings
end

return M
