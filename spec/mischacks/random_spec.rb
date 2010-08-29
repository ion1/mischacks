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
require 'mischacks/random'

require 'ostruct'

describe MiscHacks::Random do
  before :all do
    @many = 1000
  end

  it 'should define MiscHacks::RANDOM as an instance' do
    MiscHacks::RANDOM.should == MiscHacks::Random.instance
  end

  def self.spec_method meth, params, &block
    params = OpenStruct.new params

    describe meth do
      it "should return #{params.return_type} values" do
        params.args.each do |arg|
          MiscHacks::RANDOM.send(meth, arg).should be_a params.return_type
        end
      end

      it "should return #{params.range_str}" do
        params.args.each do |arg|
          range = params.range_for_arg.call arg
          @many.times do
            range.should include MiscHacks::RANDOM.send(meth, arg)
          end
        end
      end

      it 'should have a sane distribution' do
        params.args.each do |arg|
          quarter = params.quarter_for_arg.call arg

          counts = (0...@many).inject [0, 0, 0] do |c, i|
            n = MiscHacks::RANDOM.send(meth, arg)
            [
              c[0] + if n < quarter   then 1 else 0 end,
              c[1] + if n < quarter*2 then 1 else 0 end,
              c[2] + if n < quarter*3 then 1 else 0 end,
            ]
          end

          counts.each_with_index do |count, i|
            count.should be_close @many*0.25*(i+1), 50
          end
        end

        instance_eval &block if block
      end

      if params.default_arg
        it "should have #{params.default_arg} as the default argument" do
          MiscHacks::RANDOM.method(meth).arity.should == -1

          half = params.default_arg * 0.5

          n = (0...@many).inject 0.0 do |sum, i|
            sum + if MiscHacks::RANDOM.send(meth) < half then 1 else 0 end
          end

          n.should be_close @many*0.5, 50
        end

      else
        it 'should have no default argument' do
          MiscHacks::RANDOM.method(meth).arity.should == 1
        end
      end
    end
  end

  spec_method :exp,
              :return_type     => Integer,
              :range_str       => '0 <= n < 2**size_bits',
              :range_for_arg   => lambda {|arg| 0...2**arg },
              :quarter_for_arg => lambda {|arg| 2**(arg-2) },
              :args            => [2, 42, 99, 2345]

  spec_method :float,
              :return_type     => Float,
              :range_str       => '0.0 <= n < max',
              :range_for_arg   => lambda {|arg| 0.0...arg },
              :quarter_for_arg => lambda {|arg| arg*0.25 },
              :args            => [0.5, 1.5, 99.0, 1234567.8],
              :default_arg     => 1.0

  spec_method :int,
              :return_type     => Integer,
              :range_str       => '0 <= n < max',
              :range_for_arg   => lambda {|arg| 0...arg },
              :quarter_for_arg => lambda {|arg| arg/4 },
              :args            => [1, 2, 42, 99, 1234567].map {|n| n*4 }
end

# vim:set et sw=2 sts=2:
