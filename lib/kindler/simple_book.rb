#encoding: utf-8
require 'rubygems'
require "open-uri"
require "nokogiri"
require "cgi"
require "erb"

module Kindler
  class SimpleBook
    attr_accessor :title,:author,:style
  end
end
