class AddTodoListIdToTodos < ActiveRecord::Migration[7.0]
  def change
    remove_reference(:todos, :user) # dangerous or not successful - use expand, backfill, contract method: add new field, backfill the data, ensure not nil, then remove field.

    add_reference(:todos, :todo_list, null: false, index: true, foreign_key: true)
  end
end
