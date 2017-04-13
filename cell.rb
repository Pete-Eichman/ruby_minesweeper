# A class that represents an individual cell in the minefield.

class Cell

  def initialize
    @mine = false
    @revealed = false
  end

  def place_mine
    @mine = true
  end

  def contains_mine?
    @mine
  end

  def reveal!
    @revealed = true
  end

  def revealed?
    @revealed
  end
end
