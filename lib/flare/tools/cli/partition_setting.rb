# -*- coding: utf-8; -*-
# Author::    kgws  (http://d.hatena.ne.jp/kgws/)
# Copyright:: Copyright (c) 2010- kgws.
# License::   This program is licenced under the same licence as kgws.
#
# $--- flare-partition-setting - [ by Ruby ] $
# vim: foldmethod=marker tabstop=2 shiftwidth=2
require 'flare/tools'

module FlareTools
class PartitionSetting < Core
  # {{{ constractor
  def initialize()
    super
    @partition = 0
    @run_flag = true
    self.option_parse
  end
  # }}}
  # {{{ opt_parse
  def option_parse
    super
    @option.on("-n",        '--dry-run',                          "dry run") {@run_flag = false}
    @option.on(             '--partition=partition',              "partition") {|v| @partition = v.to_i}
    begin
      @option.parse!(ARGV)
    rescue OptionParser::ParseError => err
      puts err.message
      puts @option.to_s
      exit 1
    end
    self.param_check
  end
  # }}}
  # {{{ pram_check
  def param_check
    flag = false
    if @partition == 0
      self.error "specifies the number of partitions"
      flag = true
    end
    if flag
      exit 1
    end
  end
  # }}}
  # {{{ execute
  def execute
    servers = self.get_stats_nodes.sort

    # partition size check
    unless servers.size % @partition == 0
      self.error "Invalid partition setting. nodes_server=[#{servers.size}] partition=[#{@partition}]"
      exit 1
    end

    server_group_num = servers.size / @partition
    partition_num = 0
    count = 0
    balance = 1
    servers.each do |server, stats|
      count +=1
      if count == 1
        state = 'master'
      else
        state = 'slave'
      end
      self.debug "index_server=[#{@index_server_hostname}:#{@index_server_port}] server=[#{server}:#{stats['port']}] count=[#{count}] partition_num=[#{partition_num}] server_group
_num=[#{server_group_num}]"

      # nodes group setting
      unless self.set_node_role(server, stats['port'], state, balance, partition_num)
        self.error "Can't set. server=[#{server}:#{stats['port']} state=[#{state}]] balance=[#{balance}] partition=[#{partition_num}]"
        exit 1
      end

      # node state active
      if state == 'master'
        unless self.set_nodes_state(server, stats['port'], "active")
          self.error "Unable to activate. server=[#{server}:#{stats['port']}]"
          exit 1
        end
      end

      if server_group_num == count
        count = 0
        partition_num += 1
      end
    end
  end
  # }}}
end
end
