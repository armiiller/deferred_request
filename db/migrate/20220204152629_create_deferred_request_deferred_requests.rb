class CreateDeferredRequestDeferredRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :deferred_request_deferred_requests do |t|
      t.text :request
      t.text :routing
      t.text :result
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
