module RataInmunda
  class Entry
    include JSON::Serializable

    getter id
    def initialize(@title : String, @url : String, @id : Int32)
    end

    def to_s
      "title: #{@title}, url: #{@url}, id: #{@id}"
    end

    def ==(other : Entry)
      @id == other.id
    end

    def hash
      @id.hash
    end
  end
end
