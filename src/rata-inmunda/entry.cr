module RataInmunda
  class Entry
    def initialize(@title : String, @url : String, @id : Int32)
    end

    def to_s
      "title: #{@title}, url: #{@url}, id: #{@id}"
    end
  end
end
