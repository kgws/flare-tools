# -*- coding: utf-8; -*-
# Author::    kgws  (http://d.hatena.ne.jp/kgws/)
# Copyright:: Copyright (c) 2010- kgws.
# License::   This program is licenced under the same licence as kgws.
#
# $--- flare-tools - [ by Ruby ] $
# vim: foldmethod=marker tabstop=2 shiftwidth=2

module FlareTools
  class Logger
    #{{{ Constructor
    def initialize()
    end
    # }}}
    # {{{ info
    def info(msg)
      puts "[INFO] #{msg}"
    end
    # }}}
    # {{{ error
    def error(msg)
      puts "\033[31m[ERROR]\033[m #{msg}"
    end
    # }}}
    # {{{ debug
    def debug(msg)
      puts "[DEBUG] #{msg}" if $DEBUG
    end
    # }}}
  end
end
