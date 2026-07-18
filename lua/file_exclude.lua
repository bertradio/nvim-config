-- file_exclude.lua

-- Extensions for files I normally would not edit in Neovim.
-- Code from ChatGPT
--
-- Usage:
--   local exclude = require('file_exclude')
--   exclude.is_excluded('picture.jpg')
--   exclude.mini_files_filter(fs_entry)
--   exclude.snacks_patterns()

local M = {}

-- Store extensions in lowercase.
-- stylua: ignore 
M.extensions = {
  -- Archives and compressed files                                                   
  ['7z']  = true,
  ['bz2'] = true,
  ['gz']  = true,
  ['rar'] = true,
  ['tar'] = true,
  ['tgz'] = true,
  ['xz']  = true,
  ['zip'] = true,
  ['zst'] = true,

  -- Applications, packages, and installers
  ['appimage'] = true,
  ['deb'] = true,
  ['exe'] = true,
  ['iso'] = true,
  ['msi'] = true,

  -- Microsoft Office
  ['accdb'] = true,
  ['doc']   = true,
  ['docm']  = true,
  ['docx']  = true,
  ['ppt']   = true,
  ['pptm']  = true,
  ['pptx']  = true,
  ['xls']   = true,
  ['xlsb']  = true,
  ['xlsm']  = true,
  ['xlsx']  = true,

  -- LibreOffice / OpenDocument
  ['odb'] = true,
  ['odg'] = true,
  ['odp'] = true,
  ['ods'] = true,
  ['odt'] = true,

  -- PDF and ebooks
  ['azw']  = true,
  ['azw3'] = true,
  ['epub'] = true,
  ['mobi'] = true,
  ['pdf']  = true,

  -- Images
  ['arw']  = true,
  ['avif'] = true,
  ['bmp']  = true,
  ['cr2']  = true,
  ['cr3']  = true,
  ['gif']  = true,
  ['heic'] = true,
  ['heif'] = true,
  ['ico']  = true,
  ['jpeg'] = true,
  ['jpg']  = true,
  ['nef']  = true,
  ['png']  = true,
  ['psd']  = true,
  ['svgz'] = true,
  ['tif']  = true,
  ['tiff'] = true,
  ['webp'] = true,

  -- Audio
  ['aac']  = true,
  ['aiff'] = true,
  ['alac'] = true,
  ['au']   = true,
  ['aup3'] = true,
  ['flac'] = true,
  ['m4a']  = true,
  ['mid']  = true,
  ['midi'] = true,
  ['mp3']  = true,
  ['oga']  = true,
  ['ogg']  = true,
  ['opus'] = true,
  ['wav']  = true,
  ['wma']  = true,

  -- Video
  ['avi']  = true,
  ['flv']  = true,
  ['m4v']  = true,
  ['mkv']  = true,
  ['mov']  = true,
  ['mp4']  = true,
  ['mpeg'] = true,
  ['mpg']  = true,
  ['ogv']  = true,
  ['webm'] = true,
  ['wmv']  = true,

  -- Databases and password databases
  ['db']      = true,
  ['kdbx']    = true,
  ['mdb']     = true,
  ['sqlite']  = true,
  ['sqlite3'] = true,

  -- Fonts
  ['eot']     = true,
  ['otf']     = true,
  ['ttf']     = true,
  ['woff']    = true,
  ['woff2']   = true,

  -- Compiled and binary files
  ['a']     = true,
  ['bin']   = true,
  ['class'] = true,
  ['dll']   = true,
  ['o']     = true,
  ['pyc']   = true,
  ['so']    = true,

  -- Other application-specific files
  ['jex'] = true,
  ['lnk'] = true,
  ['max'] = true,
}

--    ╭────────────────────────────╮
--    │       for mini.files       │
--    ╰────────────────────────────╯

-- Whether excluded files are currently visible in mini.files.
M.show_excluded = false

local function get_extension(path)
  if type(path) ~= 'string' then
    return nil
  end

  local name = vim.fs.basename(path)
  local extension = name:match('%.([^%.]+)$')

  return extension and extension:lower() or nil
end

function M.is_excluded(path)
  local extension = get_extension(path)
  return extension ~= nil and M.extensions[extension] == true
end

function M.mini_files_filter(fs_entry)
  -- Always show directories so navigation is unaffected.
  if fs_entry.fs_type == 'directory' then
    return true
  end

  return M.show_excluded or not M.is_excluded(fs_entry.name)
end

function M.toggle()
  M.show_excluded = not M.show_excluded

  local MiniFiles = require('mini.files')

  -- Update the currently open explorer.
  MiniFiles.refresh({
    content = {
      filter = M.mini_files_filter,
    },
  })

  vim.notify(M.show_excluded and 'Excluded files shown' or 'Excluded files hidden')
end

--    ╭────────────────────────────╮
--    │         for snacks         │
--    ╰────────────────────────────╯

-- Convert an extension such as "jpeg" into:
-- [jJ][pP][eE][gG]

-- Convert an extension such as "jpeg" into:
-- [jJ][pP][eE][gG]
local function case_insensitive_glob(extension)
  return extension:gsub('%a', function(char)
    return string.format('[%s%s]', char:lower(), char:upper())
  end)
end

function M.snacks_patterns()
  local patterns = {}

  for extension in pairs(M.extensions) do
    patterns[#patterns + 1] = '*.' .. case_insensitive_glob(extension)
  end

  table.sort(patterns)
  return patterns
end

return M
