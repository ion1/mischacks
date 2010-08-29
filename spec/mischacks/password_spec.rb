# mischacks – Miscellaneous methods that may or may not be useful
# Copyright © 2010 Johan Kiviniemi
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

require File.expand_path(File.dirname(__FILE__)+'/../spec_helper.rb')
require 'mischacks/password'

require 'set'

describe MiscHacks::Password do
  def match expected
    simple_matcher("match #{expected.inspect}") do |given, matcher|
      matcher.failure_message = "expected #{given.inspect} to match #{expected.inspect}"
      matcher.negative_failure_message = "expected #{given.inspect} not to match #{expected.inspect}"
      given.match? expected
    end
  end

  before :all do
    @many = 1000

    @password  = 'foo'
    @salt      = 'bar'
    @encrypted = @password.crypt('$6$%s$' % @salt)
  end

  describe 'SALT_SET' do
    salt_set = MiscHacks::Password::SALT_SET

    it 'should be an array' do
      salt_set.should be_an Array
    end

    it 'should contain 64 unique values' do
      salt_set.length.should == 64
      salt_set.to_set.length.should == 64
    end

    it 'should have characters as values' do
      salt_set.each do |char|
        char.should be_a String
        char.bytesize.should == 1
      end
    end
  end

  describe 'random_salt' do
    it 'should return strings of random length between 9 and 16' do
      range = 9..16
      counts = Array.new(range.max - range.min + 1) { 0 }

      @many.times do
        size = MiscHacks::Password.random_salt.bytesize
        range.should include size
        counts[size - range.min] += 1
      end

      probabilities = counts.map {|c| counts.length * c / @many.to_f }

      probabilities.stddev.should                     be_close 0.0, 0.15
      (probabilities.min - probabilities.mean).should be_close 0.0, 0.30
      (probabilities.max - probabilities.mean).should be_close 0.0, 0.30
    end

    it 'should use SALT_SET with a sane distribution' do
      salt_set = MiscHacks::Password::SALT_SET

      counts = Array.new(salt_set.length) { 0 }
      num_chars = 0
      @many.times do
        MiscHacks::Password.random_salt.each_char do |char|
          MiscHacks::Password::SALT_SET.should include char

          counts[salt_set.index(char)] += 1
          num_chars += 1
        end
      end

      probabilities = counts.map {|c| salt_set.length * c / num_chars.to_f }

      probabilities.stddev.should                     be_close 0.0, 0.15
      (probabilities.min - probabilities.mean).should be_close 0.0, 0.30
      (probabilities.max - probabilities.mean).should be_close 0.0, 0.30
    end
  end

  describe 'new_from_password' do
    it 'should return a new instance with the parameter encrypted with random_salt' do
      MiscHacks::Password.should_receive(:random_salt).once.and_return(@salt)

      pw = MiscHacks::Password.new_from_password @password
      pw.should be_a MiscHacks::Password
    end
  end

  describe 'initialize' do
    it 'should verify the format of the parameter' do
      ['', 'foo', 'foo$$$', '$foo$$', '$$foo$', '$$$foo'].each do |str|
        lambda { MiscHacks::Password.new str }.
          should raise_exception ArgumentError
      end

      ['$foo$foo$foo', @encrypted].each do |str|
        lambda { MiscHacks::Password.new str }.should_not raise_exception
      end
    end
  end

  describe 'match?' do
    it 'should verify whether the cleartext parameter matches the encrypted password' do
      %w{foo bar baz}.each do |password|
        pw = MiscHacks::Password.new_from_password password
        pw.should match password
        pw.should_not match "#{password}x"
        pw.should_not match ''
      end
    end
  end

  describe 'to_s' do
    it 'should return the encrypted password' do
      MiscHacks::Password.new(@encrypted).to_s.should == @encrypted
    end
  end
end
