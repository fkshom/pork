
class Pork::Formatter
  def format(data)
    widths = data.transpose.map {|x| x.map(&:strip).map(&:length).max }
    data = data.map{|row|
      row.zip(widths).map{|value, width| 
        if block_given?
          yield [value.strip, width]
        else
          value.strip.ljust(width)
        end
       }
    }
  end
end
