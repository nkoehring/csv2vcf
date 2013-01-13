#!/usr/bin/ruby
# coding: utf-8
#
# This script converts contact data from Tine2.0 CSV export into a vcard file.
# As it only handles fields of interest, you may want to extend it to your
# needs.
#
# Uses vpim package: http://vpim.rubyforge.org/
#
# License: WTFPL


require "csv"
require "vpim/vcard"


def value? v
  v.strip.length > 0
end


begin
 csv = CSV.parse($stdin.read)
rescue
  puts "USAGE:"
  puts "csv2vcf.rb < /file/to/import > /file/to/export"
  exit 1
end

headers = csv.shift

NPREFIX = headers.index('n_prefix')
NSUFFIX = headers.index('n_suffix')
NMIDDLE = headers.index('n_middle')
NFAMILY = headers.index('n_family')
NGIVEN = headers.index('n_given')
ORG = headers.index('org_name')
EMAIL = headers.index('email')
EMAILHOME = headers.index('email_home')
URL = headers.index('url')
TELCELL = headers.index('tel_cell')
TELHOME = headers.index('tel_work')
TELWORK = headers.index('tel_home')
JABBER = headers.index('Jabber')

csv.each do |entry|
  vcard = Vpim::Vcard::Maker.make do |card|
    card.add_name do |name|
      name.prefix = entry[NPREFIX] if value? entry[NPREFIX]
      name.additional = entry[NMIDDLE] if value? entry[NMIDDLE]
      name.suffix = entry[NSUFFIX] if value? entry[NSUFFIX]
      name.family = entry[NFAMILY] if value? entry[NFAMILY]
      name.given = entry[NGIVEN] if value? entry[NGIVEN]
    end

    card.add_tel(entry[TELHOME]) {|tel| tel.location = 'home'} if value? entry[TELHOME]
    card.add_tel(entry[TELWORK]) {|tel| tel.location = 'work'} if value? entry[TELWORK]
    card.add_tel(entry[TELCELL]) {|tel| tel.location = 'cell'} if value? entry[TELCELL]

    card.add_email(entry[EMAIL]) if value? entry[EMAIL]
    card.add_email(entry[EMAILHOME]) if value? entry[EMAILHOME]
    card.add_email(entry[EMAILHOME]) if value? entry[EMAILHOME]
    card.add_impp("xmpp:"+entry[JABBER]) if value? entry[JABBER]
  end
  
  puts vcard
  puts
end

