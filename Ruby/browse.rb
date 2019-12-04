def printHead (input)
    puts "x" * 42
    puts input
    puts "x" * 42
end

def fineLines(file)
    loc = ARGV[0]
    a = Array.new

    File.open(file).each do |line|
        if ( line =~ /#{loc}/i )
            a.push("#{$.} : #{line}")            
        end
    end

    if ( !a.empty? )
        printHead("Found #{loc} in #{file}")
        puts a
        puts
    end
end

Dir.entries(Dir.pwd).each do |item|
    if ( File.file?(item) )
        fineLines(item)
    end
end