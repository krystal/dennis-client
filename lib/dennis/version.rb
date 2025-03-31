# frozen_string_literal: true

module Dennis

  VERSION_FILE_ROOT = File.expand_path('../../VERSION', __dir__)
  if File.file?(VERSION_FILE_ROOT)
    VERSION = File.read(VERSION_FILE_ROOT).strip.sub(/\Av/, '')
  else
    VERSION = '1.2.3'
  end

end
