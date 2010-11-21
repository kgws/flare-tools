# -*- coding: utf-8; -*-
# Author::    kgws  (http://d.hatena.ne.jp/kgws/)
# Copyright:: Copyright (c) 2010- kgws.
# License::   This program is licenced under the same licence as kgws.
#
# $--- flare-stats-nodes - [ by Ruby ] $
# vim: foldmethod=marker tabstop=2 shiftwidth=2
require 'flare/tools'

module FlareTools
class Stats < Core
  # {{{ constractor
  def initialize()
    super
    self.option_parse
  end
  # }}}
  # {{{ opt_parse
  def option_parse
    super
    begin
      @option.parse!(ARGV)
    rescue OptionParser::ParseError => err
      puts err.message
      puts @option.to_s
      exit 1
    end
  end
  # }}}
  # {{{ execute
  def execute
    format = "%21s %6s %6s %9s %7s %6s %6s %3s %7s\n"
    label = format % ["hostname", "state", "role", "partition", "balance", "behind", "uptime", "hit", "version"]
    str = ""
    nodes = self.get_stats_nodes
    threads  = self.get_stats_threads
    nodes.each do |hostname_port,data|
      hostname, port = hostname_port.split(":", 2)
      stats = self.get_stats(hostname, data['port'])
      threads[hostname_port]['behind'] = "-" unless threads[hostname_port].key?('behind')
      str += format % [hostname, data['state'], data['role'], data['partition'], data['balance'], threads[hostname_port]['behind'], stats['uptime'], stats["get_hits"], stats["version"]]
    end
    puts label + str
  end
  # }}}
end
end
