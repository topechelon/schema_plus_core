module SchemaPlus
  module Core
    module ActiveRecord
      module ConnectionAdapters
        module AbstractAdapter

          def add_column(table_name, name, type, options = {})
            options = options.deep_dup
            SchemaMonkey::Middleware::Migration::Column.start(caller: self, operation: :add, table_name: table_name, column_name: name, type: type, implements_reference: options.delete(:_implements_reference), options: options) do |env|
              super env.table_name, env.column_name, env.type, env.options
            end
          end

          def add_index_options(table_name, column_names, options={})
            SchemaMonkey::Middleware::Sql::IndexComponents.start(connection: self, table_name: table_name, column_names: Array.wrap(column_names), options: options.deep_dup, sql: SqlStruct::IndexComponents.new) { |env|
              env.sql.name, env.sql.type, env.sql.columns, env.sql.options, env.sql.algorithm, env.sql.using = super env.table_name, env.column_names, env.options
            }.sql.to_hash.values
          end

          def add_reference(table_name, name, options = {})
            SchemaMonkey::Middleware::Migration::Column.start(caller: self, operation: :add, table_name: table_name, column_name: "#{name}_id", type: :reference, options: options.deep_dup) do |env|
              super env.table_name, env.column_name.sub(/_id$/, ''), env.options.merge(_implements_reference: true)
            end
          end

          def create_table(table_name, options={}, &block)
            SchemaMonkey::Middleware::Migration::CreateTable.start(connection: self, table_name: table_name, options: options.deep_dup, block: block) do |env|
              super env.table_name, env.options, &env.block
            end
          end

          def drop_table(table_name, options={})
            SchemaMonkey::Middleware::Migration::DropTable.start(connection: self, table_name: table_name, options: options.dup) do |env|
              super env.table_name, env.options
            end
          end
        end
      end
    end
  end
end
