require_relative 'application_record'
require File.join(APP_ROOT, 'lib/helper/arel_helper.rb')

class Payment < ApplicationRecord
  self.table_name = 'payments'

  # @param [Hash] args
  #   @option [String] payer
  #   @option [Numeric] amount
  def self.identify_item(args = {})
    case args[:payer]
    when 'seng'
      'macbookpro'
    when 'abadi'
      args[:amount] && args[:amount] > 1000 ? 'rental' : 'carpark'
    end
  end

  def self.last_n_payments(group: true)
    res = ActiveRecord::Base.connection.exec_query(<<~sql).to_hash
      select t1.payer,
             json_group_array(
                           json_object(
                              'paid_at', t1.paid_at,
                              'amount', t1.amount,
                              'item', t1.item
                          )
                 ) as payments
      from (
               select row_number() over (partition by payer order by paid_at desc) as rank,
                      p.payer,
                      p.paid_at,
                      p.amount,
                      p.item
               from payments p
           ) t1
      where t1.rank <= 2
      group by t1.payer;
    sql

    res.each do |grp|
      if grp['payments'].present?
        grp['payments'] = JSON.parse(grp['payments'])
        grp['payments'].each do |pmt|
          pmt['paid_at'] = ArelHelper::DateTimeWithZoneType.new.deserialize(pmt['paid_at'])
        end
      end
    end
    res
  end
end
