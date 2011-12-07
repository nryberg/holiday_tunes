module Helpers
  helpers do
    def titleize(text)
      count  = 0
      result = []
  
      for w in text.downcase.split
        count += 1
        if count == 1
          # Always capitalize the first word.
          result << w.capitalize
        else
          unless ['a','an','and','by','for','in','is','of','not','on','or','over','the','to','under'].include? w
            result << w.capitalize
          else
            result << w
          end
        end
      end

      return result.join(' ')
    end
    def commify(n)
        n.to_s =~ /([^\.]*)(\..*)?/
        int, dec = $1.reverse, $2 ? $2 : ""
        while int.gsub!(/(,|\.|^)(\d{3})(\d)/, '\1\2,\3')
        end
        int.reverse + dec
    end

    def simple_date_from_number(num)
      t = Time.at(num * 0.001).utc
      t.strftime("%m/%d/%Y")
    end

    def simple_date_time_from_number(num)
      t = Time.at(num * 0.001).utc
      t.strftime("%m/%d/%Y %H:%M")
    end

 end
     
end

