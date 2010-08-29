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

require 'securerandom'
require 'singleton'
require 'thread'

module MiscHacks
  class Random
    include Singleton

    def initialize
      @mutex = Mutex.new
      @pool = 0
      @pool_size = 0
    end

    # 0 ≤ return_value < 2^size_bits
    def exp size_bits
      @mutex.synchronize do
        while @pool_size < size_bits
          # Push 32×8 bits to the pool.
          SecureRandom.random_bytes(32).unpack('Q*').each do |byte|
            @pool = (@pool << 64) | byte
            @pool_size += 64
          end
        end

        # Unshift size_bits bits from the pool.
        @pool_size -= size_bits
        bits   = @pool >> @pool_size
        @pool ^= bits << @pool_size

        bits
      end
    end

    def float n=1
      n*Math.ldexp(exp(Float::MANT_DIG), -Float::MANT_DIG)
    end

    def int n
      float(n).floor
    end
  end

  RANDOM = Random.instance
end

# vim:set et sw=2 sts=2:
