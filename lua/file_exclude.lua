-- file_exclude.lua

-- Exclusions for mini.files
--
-- Usage:
--   local exclude = require('file_exclude')
--
--   exclude.is_excluded('picture.jpg')
--   exclude.mini_files_filter(fs_entry)
--   exclude.toggle_mini()
--   exclude.fzf_exclude_args()

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
  ['deb']      = true,
  ['exe']      = true,
  ['iso']      = true,
  ['msi']      = true,

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
  ['xcf'] = true,

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
  ['eot']   = true,
  ['otf']   = true,
  ['ttf']   = true,
  ['woff']  = true,
  ['woff2'] = true,

  -- Compiled and binary files
  ['a']     = true,
  ['bin']   = true,
  ['class'] = true,
  ['dll']   = true,
  ['o']     = true,
  ['pyc']   = true,
  ['so']    = true,

  -- Other application-specific files
  ['efx'] = true,
  ['fxm'] = true,
  ['gdsheet'] = true,
  ['gddoc'] = true,
  ['glabels'] = true,
  ['jex'] = true,
  ['lnk'] = true,
  ['max'] = true,
  ['mpesession'] = true,
  ['pub'] = true,
  ['ufo'] = true,
  ['wks'] = true,
  ['wps'] = true,
  ['xmind'] = true,
  }

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

function M.mini_explorer_filter(item)
  return item.fs_type == 'directory' or not M.is_excluded(item.path)
end

return M
