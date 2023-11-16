require "google_drive"

# Creates a session. This will prompt the credential via command line for the
# first time and save it to config.json file for later usages.
# See this document to learn how to create config.json:
# https://github.com/gimite/google-drive-ruby/blob/master/doc/authorization.md
session = GoogleDrive::Session.from_config("config.json")

ws = session.spreadsheet_by_key("1wVTOamXSVOKSVofDh_M1P7jW53_SZSZSYguDb_RQpBk").worksheets[0];
ws2 = session.spreadsheet_by_key("1HiaF6ebHoOnGzvEfMw-M1D6AdbSEI_fQ2ABWL0cpT-4").worksheets[0];


class GoogleSheet
include Enumerable
attr_accessor :redovi, :kolone

  def initialize(ws)
    @ws = ws
    @redovi = @ws.rows
    @redovi = @redovi.select{|i| !i.include? "total" and !i.include? "subtotal"}
    @kolone = []
    @redovi.transpose.each do |n|
      s= Kolona.new(n[0],n,n[1..])
      @kolone.push(s)
    end
    @tabelaTransponovana = @ws.rows.transpose
  end

  def returnTabela
    @tabelaTransponovana
  end

  def row(a)
    @redovi[a]
  end

  def each
    yield @redovi
  end

  def [] (a)
    @kolone.each do |n|
      if n.ime == a
        return n.vrednosti
      end
    end
  end

  def prvaKolona
    kolona_sa_imenom('prva kolona')
  end

  def drugaKolona
    kolona_sa_imenom('druga kolona')
  end

  def trecaKolona
    kolona_sa_imenom('treca kolona')
  end


  def kolona_sa_imenom(ime)
    @kolone.each do |kolona|
      return kolona if kolona.ime.downcase == ime.downcase
    end
    nil
  end

  def + (obj)
    return "Nisu zaglavlja jednaka" unless headers_equal?(obj)

    obj_redovi = obj.redovi.dup
    obj_redovi.shift
    @redovi + obj_redovi
  end

  def - (obj)
    return "Nisu zaglavlja jednaka" unless headers_equal?(obj)

    obj.redovi.shift
    @redovi - obj.redovi
  end

def method_missing(key, *args)
  kolona = kolona_sa_imenom(key.to_s)
  return kolona if kolona

  super.method_missing(key, *args)
end

  private
  def headers_equal?(obj)
    @redovi[0] == obj.redovi[0]
  end

end



class Kolona
  include Enumerable
  attr_accessor :vrednosti,:ime

  def initialize(ime, vrednosti, vrednostiKolone)
    @ime = ime
    @vrednosti = vrednosti
    @vrednostiKolone = vrednostiKolone
  end

  def sum
    sum = 0
    @vrednostiKolone.each do |n|
      sum += n.to_i
    end
    sum
  end

  def avg
    numeric_values = @vrednostiKolone.select { |value| value.to_s == value }
    numeric_values.map(&:to_i).sum / numeric_values.length.to_f
  end


  def each
    yield @vrednostiKolone
  end

end

t1 = GoogleSheet.new(ws)
t2 = GoogleSheet.new(ws2)

p("Zadatak 1.")
p t1.returnTabela
puts("\n")


p("Zadatak 2.")
p t1.row(2)
puts"\n"


p("Zadatak 3.")
t1.each {|redovi|
     redovi.each do |n|
        n.each do |s|
           p s
        end
     end}
puts"\n"

p("Zadatak 5.")
t1["druga kolona"][1]= "5"
p t1["druga kolona"]
puts"\n"

p("Zadatak 6.")
t1.prvaKolona
p t1.prvaKolona.sum
p t1.prvaKolona.avg
puts"\n"

p("Zadatak 8.")
t1= t1+t2
p t1
puts"\n"

p("Zadatak 9.")
t1=t1-t2
p t1
puts"\n"
