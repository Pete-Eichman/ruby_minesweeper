require_relative "cell"
require 'pry'

class Minefield
  attr_reader :row_count, :column_count

  def initialize(row_count, column_count, mine_count)
    @column_count = column_count
    @row_count = row_count
    @mine_count = mine_count
    @mine_queue = []
    @field = []

    build_minefield
    place_mines
  end

  def cell_cleared?(row, col)
    @field[row][col].revealed?
  end

  def clear(row, col)
    puts "#{row}, #{col}"
    if @field[row][col].contains_mine?
      @field[row][col].reveal!
    elsif adjacent_mines(row, col) != 0
      @field[row][col].reveal!
    elsif !@field[row][col].contains_mine?
      @mine_queue = []
      done = []
      @mine_queue << [@field[row][col], row, col]

      until @mine_queue.empty?
        @mine_queue.each do |cell|
          check = @mine_queue.pop
          adjacent_check = [[check[1] - 1, check[2]],
                            [check[1] - 1, check[2] - 1],
                            [check[1] - 1, check[2] + 1],
                            [check[1] + 1, check[2]],
                            [check[1] + 1, check[2] - 1],
                            [check[1] + 1, check[2] + 1],
                            [check[1], check[2] - 1],
                            [check[1], check[2] + 1]]
          if adjacent_mines(check[1], check[2]) ==  0 || !@field[check[1]][check[2]].contains_mine?
            @field[check[1]][check[2]].reveal!
          end

          if check[1] - 1 >= 0 && check[2] - 1 >= 0
            if adjacent_mines(check[1], check[2]) == 0 || !@field[check[1]][check[2]].contains_mine?
              @field[check[1]][check[2]].reveal!
            end
            adjacent_check.each do |perm|
              if !@field[perm[0]].nil? && !@field[perm[0]][perm[1]].nil? && !done.include?(@field[perm[0]][perm[1]]) && !@field[perm[0]][perm[1]].contains_mine? && adjacent_mines(perm[0], perm[1]) == 0
                @mine_queue << [@field[perm[0]][perm[1]], perm[0], perm[1]]
              elsif !@field[perm[0]].nil? && !@field[perm[0]][perm[1]].nil? && !done.include?(@field[perm[0]][perm[1]]) && adjacent_mines(perm[0], perm[1]) && !@field[perm[0]][perm[1]].contains_mine?
                @field[perm[0]][perm[1]].reveal!
              end
            end
          end
          done << check[0]
        end
      end
    end
  end

  def mines_detonated?
    @field.each do |row|
      row.each do |col|
        if col.revealed? && col.contains_mine?
          @field.each do |row|
            row.each do |cell|
              if cell.contains_mine?
                cell.reveal!
              end
            end
          end
          return true
        end
      end
    end
    return false
  end

  def all_cells_cleared?
    @field.each do |row|
      row.each do |col|
        if !col.revealed? && !col.contains_mine?
          return false
        end
      end
    end
    return true
  end

  def adjacent_mines(row, col)
    adjacent = 0
    adjacent_check = [[row + 1, col],
                      [row + 1, col + 1],
                      [row + 1, col - 1],
                      [row - 1, col],
                      [row - 1, col + 1],
                      [row - 1, col - 1],
                      [row, col + 1],
                      [row, col - 1]]

    adjacent_check.each do |cell|
      if !@field[cell[0]].nil? && !@field[cell[0]][cell[1]].nil? && @field[cell[0]][cell[1]].contains_mine?
        if cell[0] > -1 && cell[1] > -1
          adjacent += 1
        end
      end
    end
    return adjacent
  end

  def contains_mine?(row, col)
    @field[row][col].contains_mine?
  end

  private

  def build_minefield
    columns = []
    @column_count.times do
      row = []
      @row_count.times do
        row << Cell.new
      end
      columns << row
    end
    @field = columns
  end

  def place_mines
    i = 0
    while i < @mine_count
      row = rand(0..@row_count - 1)
      col = rand(0..@column_count - 1)
      if !@field[row][col].contains_mine?
        @field[row][col].place_mine
        i += 1
      end
    end
  end
end
