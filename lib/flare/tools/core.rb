# -*- coding: utf-8; -*-
# Author::    kgws  (http://d.hatena.ne.jp/kgws/)
# Copyright:: Copyright (c) 2010- kgws.
# License::   This program is licenced under the same licence as kgws.
#
# $--- flare-tools - [ by Ruby ] $
# vim: foldmethod=marker tabstop=2 shiftwidth=2

module FlareTools
  class Core
    #{{{ Constructor
    def initialize()
      @index_server_hostname = '127.0.0.1'
      @index_server_port = 12120
      @run_flag = true
      @timeout = 10
      @logger = Logger.new
      @option = OptionParser.new
      self.option_on
      self.option_parse
      self.option_param_check
    end
    # }}}
    # {{{ option_on
    def option_on
      @option.on('-h',        '--help',                             "this message show") {puts @option.help; exit 1}
      @option.on('-d',        '--debug',                            "debug mode on") {$DEBUG = true}
      @option.on("-w",        '--warn',                             "turn warnings on for this script") {$-w = true}
    end
    # }}}
    # {{{ option_parse
    def option_parse
      begin
        @option.parse!(ARGV)
      rescue OptionParser::ParseError => err
        puts err.message
        puts @option.to_s
        exit 1
      end
    end
    # }}}
    # {{{ option_param_check
    def option_param_check ; end
    # }}}
    # {{{ str_date
    def str_date(date)
      date = date.to_i
      res = ""
      # sec
      if date >= 60
        date = date / 60
      else
        return "#{date}s"
      end

      # min
      if date >= 60
        date = date / 60
      else
        return date + "m"
      end

      # hour
      if date >= 24
        date = date / 24
      else
        return date + "h"
      end

      # day
      "#{date}d"
    end
    # }}}
    # {{{ command
    def command(host, port, cmd, flag=false, t=10)
      @logger.debug "Enter the command server. server=[#{host}:#{port}] command=[#{cmd.strip}]"
      return true if @run_flag === false && flag === false
      cmd += "\n" unless /\n$/ =~ cmd
      str = ""
      timeout(t) do
        s = TCPSocket.open(host, port)
        s.write cmd
        while x = s.gets
          if x == "OK\r\n" || x == "END\r\n"
            break
          elsif x == "ERROR\r\n"
            self.error "Failed command. server=[#{host}:#{port}] command=[#{cmd.strip}]"
            str = false
            break
          end
          str += x
        end
        s.close
      end
      str
    rescue Errno::ECONNREFUSED
      @logger.error "Connection refused. server=[#{host}:#{port}] command=[#{cmd.strip}]"
      exit 1
    rescue TimeoutError
      @logger.error "Connection timeout. server=[#{host}:#{port}] command=[#{cmd.strip}]"
      exit 1
    end
    # }}}
    # {{{ get_stats
    def get_stats(hostname, port, t=10)
      str = self.command(hostname, port, "stats", true, t)
      self.stats_parse(str)
    end
    # }}}
    # {{{ get_stats_nodes
    def get_stats_nodes(t=10)
      str = self.command(@index_server_hostname, @index_server_port, "stats nodes", true, t)
      self.stats_nodes_parse(str)
    end
    # }}}
    # {{{ get_stats_threads
    def get_stats_threads(t=10)
      str = self.command(@index_server_hostname, @index_server_port, "stats threads", true, t)
      self.stats_threads_parse(str)
    end
    # }}}
    # {{{ set_node_role
    def set_node_role(host, port, state, balance, partition, t=10)
      cmd = "node role %s %s %s %s %s\n" % [host, port, state, balance, partition]
      self.command(@index_server_hostname, @index_server_port, cmd, false, t)
    end
    # }}}
    # {{{ set_nodes_state
    def set_nodes_state(host, port, state="active", t=10)
      cmd = "node state %s %s %s\n" % [host, port, state]
      self.command(@index_server_hostname, @index_server_port, cmd, false, t)
    end
    # }}}
    # {{{ flush_all
    def flush_all(hostname, port, t=10)
      self.command(hostname, port, "flush_all", true, t)
    end
    # }}}
    # {{{ dump
    def dump(partition, partition_size, wait=0, t=10)
      self.command(@index_server_hostname, @index_server_port, cmd, false, t)
    end
    # }}}
    # {{{ stats_parse
    def stats_parse(str)
      res = {}
      str.gsub(/STAT /, '').split("\r\n").each do |x|
        key, val = x.split(" ", 2)
        res[key] = val
      end
      res
    end
    # }}}
    # {{{ stats_nodes_parse
    def stats_nodes_parse(str)
      res = {}
      str.gsub(/STAT /, '').split("\r\n").each do |x|
        ip, port, stat = x.split(":", 3)
        key, val = stat.split(" ")
        res["#{ip}:#{port}"] = {} if res["#{ip}:#{port}"].nil?
        res["#{ip}:#{port}"]['port'] = port
        res["#{ip}:#{port}"][key] = val
      end
      res
    end
    # }}}
    # {{{ stats_threads_parse
    def stats_threads_parse(str)
      threads = {}
      res = {}
      str.gsub(/STAT /, '').split("\r\n").each do |x|
        thread_id, stat = x.split(":", 2)
        key, val = stat.split(" ")
        threads[thread_id] = {} if threads[thread_id].nil?
        threads[thread_id][key] = val
      end
      threads.each do |thread_id, stat|
        res[stat['peer']] = {} if res[stat['peer']].nil?
        res[stat['peer']]['thread_id'] = thread_id
        res[stat['peer']].merge!(stat)
      end
      res
    end
    # }}}
    # {{{ execute
    def execute ; end
    # }}}
  end
end
