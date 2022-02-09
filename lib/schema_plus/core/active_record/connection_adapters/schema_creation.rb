module SchemaPlus
  module Core
    module ActiveRecord
      module ConnectionAdapters
        module SchemaCreation

          def add_column_options!(sql, options)
            sql << " " + SchemaMonkey::Middleware::Sql::ColumnOptions.start(caller: self, connection: self.instance_variable_get('@conn'), sql: "", column: options[:column], options: options.except(:column)) { |env|
              super env.sql, env.options.merge(column: env.column)
            }.sql.lstrip
          end

          def visit_TableDefinition(o)
            SchemaMonkey::Middleware::Sql::Table.start(caller: self, connection: self.instance_variable_get('@conn'), table_definition: o, sql: SqlStruct::Table.new) { |env|
              env.sql.parse! super env.table_definition
            }.sql.assemble
          end
        end
      end
    end
  end
end
