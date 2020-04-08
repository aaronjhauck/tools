@rem = '-*- Ruby -*-';
@rem = '
@ruby -w %~dpnx0 %*
@goto :endofruby
';

require 'optparse'

class BrowseFiles
    attr_reader :options
    
    def initialize
        @options = Hash.new
        OptionParser.new do |opt|
            opt.on('-p', '--pattern <searchPattern>') { |o| @options[:pat] = o }
        end.parse!
    end
    
    def printHead(input)
        puts "x" * input.length
        puts input
        puts "x" * input.length
    end

    def findLines(file, dname)
        a   = Array.new

        File.open(file).each do |line|
            if ( line =~ /#{@options[:pat]}/i )
                final = line.gsub(/^\s+/, '')
                a.push("#{$.}: #{final}")            
            end
        end

        if ( !a.empty? )
            if (file =~ /^\d+/)
                file = File.basename(file, File.extname(file))
            end
            puts dname
            printHead(" #{a.count} total instances of \"#{@options[:pat]}\" in #{file} ")
            puts a
            puts
        end
    end
    
    def parseDir(obj,dname)
        if ( File.file?(obj))
            findLines(obj,dname)
        end
    end
end

b = BrowseFiles.new

abort("Need a search pattern! Try \"br -h\"") if(!b.options.key?(:pat))

Dir.entries(Dir.pwd).each do |fname| 
    b.parseDir(fname,File.basename(Dir.getwd)) 
end

Dir.glob("**/*/").each do |dname|
    Dir["#{dname}*"].each do |fname|
    b.parseDir(fname,dname.gsub('/',' '))
    end
end

__END__
:endofruby