require 'thread'

module Transaction
  class TransactionError < StandardError; end
  class TransactionThreadError < TransactionError; end
end

