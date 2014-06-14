class FixCoinInformation < ActiveRecord::Migration
  def change
    # Track-o-Bot <= 0.2.1 delivered the wrong coin information
    Result.where(coin: false).update_all(coin: nil)
    Result.where(coin: true).update_all(coin: false)
    Result.where(coin: nil).update_all(coin: true)
  end
end
