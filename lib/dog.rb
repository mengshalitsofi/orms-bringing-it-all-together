require_relative "../config/environment.rb"

class Dog
    attr_accessor :name, :breed, :id

    def initialize(params)
        @id = nil
        @name = params[:name]
        @breed = params[:breed]
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
        )
        SQL
      
        DB[:conn].execute(sql)
      end
      
      def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
      end
      
      def save
        if self.id
          self.update
        else
         sql = <<-SQL
          INSERT INTO dogs (name, breed) 
          VALUES (?, ?)
          SQL
          DB[:conn].execute(sql, self.name, self.breed)
          @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
      end

      def self.create(params)
        dog = Dog.new(params)
        if params[:id]
            dog.id = params[:id]
        end

        dog.save
      end

      def self.new_from_db(row)
        self.create(name: row[1], breed:row[2], id:row[0])
      end

      def self.find_by_id(id)
        sql = <<-SQL
          SELECT *
          FROM dogs
          WHERE id = ?
        SQL
      
        DB[:conn].execute(sql, id).map do |row|
          self.new_from_db(row)
        end.first
      end
      
      def self.find_or_create_by(params)
        sql = <<-SQL
          SELECT *
          FROM dogs
          WHERE name = ? AND breed = ?
          LIMIT 1
        SQL
      
        result = DB[:conn].execute(sql, params[:name], params[:breed]).map do |row|
          self.new_from_db(row)
        end

        if result.length == 0
            return self.create(params)
        else
            return result.first
        end
        
      end
      
      def self.find_by_name(name)
        sql = <<-SQL
          SELECT *
          FROM dogs
          WHERE name = ?
          LIMIT 1
        SQL
      
        DB[:conn].execute(sql, name).map do |row|
          self.new_from_db(row)
        end.first
      end
      
      def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
      end
      
end