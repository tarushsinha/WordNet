require_relative "graph.rb"

class Synsets
    def initialize
        @list = {}  
    end

    def load(synsets_file) #TEST HARD
        #new attempt
        local_store = {}

        line_number = 0

        invalid_file = []

        err_flag = false

        File.open(synsets_file).each do |line|
            line_number += 1

            if line != nil #non empty line
                #TEST THIS REGEX HARD
                if !(line =~ /^id: [0-9]* synset: [a-zA-Z_\d\.\-\/']+([,][a-zA-Z_\d\.\-\/']+)*$/)
                    invalid_file << line_number
                    if err_flag != true #if error flag hasn't been tripped yet
                        err_flag = true
                    end
                else #if no error flag, and pattern matches
                    if err_flag != true
                        #parse string to store into set
                        arr = line.split(" ")

                        syns_id = arr[1].to_i
                        noun_arr = arr[3].split(',')

                        #before storing, check if ID exists in hash already
                        if @list.has_key? syns_id
                            invalid_file << line_number
                            err_flag = true
                        elsif local_store.has_key? syns_id
                            invalid_file << line_number
                            err_flag = true
                        else
                            local_store[syns_id] = noun_arr
                        end 
                    end
                end
            else #empty line
                invalid file << line_number
                if err_flag != true #if error flag hasn't been tripped yet
                    err_flag = true
                end
            end
        end

        if err_flag == true
            return invalid_file
        else
            @list.merge!(local_store)
            return nil
        end

        # #hash to keep track of processed lines
        # local_store = {}

        # #var to keep track of line in file
        # line_number = 1

        # #array to keep track of invalid lines in the file
        # invalid_file = []

        # #loop to process the synsets file
        # File.open(synsets_file).each do |line|
        #     #split line by spaces
        #     arr = line.split(" ")

        #     #split the list of nouns by their commas
        #     if (arr[3] != nil)
        #         noun_arr = arr[3].split(',')
        #     else
        #         invalid_file << line_number
        #     end

        #     #error flag for noun validation
        #     err_flag = false;

        #     #synset id from string to Int
        #     if (arr[1] != nil)
        #         syns_id = arr[1].to_i
        #     else
        #         invalid_file << line_number
        #     end

        #     #preliminary formatting conditions
        #     if (arr.length != 4)
        #         puts "Missing one of the 4 terms"
        #         invalid_file << line_number
        #     elsif !(arr[0].eql? "id:")
        #         puts "Incorrect Id line formatting"
        #         invalid_file << line_number
        #     elsif (syns_id < 0)
        #         puts "Negative Id"
        #         invalid_file << line_number
        #     elsif !(arr[2].eql? "synset:")
        #         puts "Incorrect Synset line formatting"
        #         invalid_file << line_number
        #     end

        #     #iterate through every noun and check that it is valid
        #     for word in noun_arr do
        #         if !(/[a-zA-Z_\.-\/\d']/ =~ word) #regex built/tested on rubular
        #             err_flag = true;
        #         end
        #     end

        #     #if error flag was thrown when validating nouns for current line, mark invalid
        #     if (err_flag)
        #         invalid_file << line_number
        #     #if synset id exists in hash, the line is invalid
        #     elsif @list.has_key? syns_id
        #         invalid_file << line_number
        #     end

        #     #add line to local hash
        #     local_store[syns_id] = noun_arr


        #     #increment line number after processing
        #     line_number += 1
        # end

        # #if the invalid file array is empty, means the load processed properly, merge the hashes
        # if (invalid_file.length == 0)
        #     @list.merge(local_store)
        #     return nil
        # else
        #     return invalid_file
        # end



        ## NEED TO REDO HOW INFO IS STORED IN ARRAYS LINE BY LINE, SINCE STORING IS COMPUTED AFTER ##

        #after processing, check if there were any formatting issues with the file
        ## if invalid_file.size > 0
            ##return 
    end

    def addSet(synset_id, nouns)
        #Conditionals for added parameters
        if synset_id < 0
            return false
        elsif nouns.length == 0
            return false           
        elsif @list.has_key? synset_id     
            return false
        end

        #Adding valid parameters to Hash, then returning True
        @list[synset_id] = nouns

        return true
    end

    def lookup(synset_id)
        if @list.has_key? synset_id
            return @list.fetch(synset_id)
        else
            return []       #return empty array
        end
    end

    def findSynsets(to_find)
        if to_find.is_a? String
            arr = []
            #process as string input
            @list.each do |k,v|
                for elem in v
                    if elem.eql?(to_find)
                        arr << k 
                    end
                end
            end
            return arr
        elsif to_find.is_a? Array
            hh = {}
            #process Arr input
            for elem in to_find
                a = elem
                hh[a] = findSynsets(elem)
            end
            return hh
        else
            return nil
        end
    end
end

class Hypernyms
    def initialize
        @graph = Graph.new
    end

    def load(hypernyms_file)
        local_store = {}

        line_number = 0

        invalid_file = []

        err_flag = false

        File.open(hypernyms_file).each do |line|
            line_number += 1

            if line != nil #non empty line
                #TEST THIS REGEX HARD
                if !(line =~ /^from: [0-9]+ to: [0-9]+([,][0-9]+)*$/)
                    invalid_file << line_number
                    if err_flag != true #if error flag hasn't been tripped yet
                        err_flag = true
                    end
                else #if no error flag, and pattern matches
                    if err_flag != true
                        #parse string to store into set
                        arr = line.split(" ")

                        syns_id = arr[1].to_i
                        hypernym_ids = arr[3].split(',')

                        #before storing, check if ID exists in hash already
                        local_store[syns_id] = hypernym_ids
                    end
                end
            else #empty line
                invalid file << line_number
                if err_flag != true #if error flag hasn't been tripped yet
                    err_flag = true
                end
            end
        end

        if err_flag == true
            return invalid_file
        else
            local_store.each do |k,v|
                for elem in v
                    addHypernym(k, elem.to_i)
                end
            end
            return nil
        end
    end

    def addHypernym(source, destination)
        if source < 0 || destination < 0
            return false
        elsif source == destination
            return false
        else
            if !@graph.hasVertex?(source)
                @graph.addVertex(source)
            end
            if !@graph.hasVertex?(destination)
                @graph.addVertex(destination)
            end
            if @graph.hasEdge?(source, destination)
                return true
            else
                @graph.addEdge(source, destination)
                return true
            end
        end
    end

    def lca(id1, id2)
        if !@graph.hasVertex?(id1)
            return nil
        end
        if !@graph.hasVertex?(id2)
            return nil
        end

        #return arr
        arr = []
        #compVar
        lca_compVar = -1

        arr_id1 = @graph.bfs(id1)
        arr_id2 = @graph.bfs(id2)

        arr_id1.each do |vert1,dist1|
            arr_id2.each do |vert2,dist2|
                if (vert1 == vert2)
                    dist = dist1+dist2
                    if (lca_compVar == -1 || lca_compVar >= dist)
                        if lca_compVar == dist
                            lca_compVar = dist
                            arr << vert1
                        else
                            lca_compVar = dist
                            #clear arr
                            arr = []
                            arr << vert1
                        end
                    end
                end
            end
        end
        return arr
    end
end

class CommandParser
    def initialize
        @synsets = Synsets.new
        @hypernyms = Hypernyms.new
    end

    def parse(command)
        #use regex to grab first command
        command =~ /^\s*([a-z]+)/
        input = $1

        hsh = {}

        if input.eql? "load"
            #load process
            hsh[:recognized_command] = :load
            flag = false

            s_ids = []
            hypHash = {}

            if !(command =~ /^\s*[a-z]+\s+([\w\/\-\.]+)\s+([\w\/\-\.]+)$/)
                hsh[:result] = :error
            else
                #assuming valid command, validate hypernyms
                command =~ /^\s*[a-z]+\s+([\w\/\-\.]+)\s+([\w\/\-\.]+)$/

                str = $1
                str1 = $2
                File.open(str1).each do |hline|
                    if hline != nil #non empty line
                        #TEST THIS REGEX HARD
                        if !(hline =~ /^from: [0-9]+ to: [0-9]+([,][0-9]+)*$/)
                            if flag != true #if error flag hasn't been tripped yet
                                flag = true
                            end
                        else #if no error flag, and pattern matches
                            if flag != true
                                #parse string to store into set
                                arr = hline.split(" ")

                                syns_id = arr[1].to_i
                                hypernym_ids = arr[3].split(',')

                                hypHash[syns_id] = hypernym_ids
                            end
                        end
                    else #empty line
                        if flag != true #if error flag hasn't been tripped yet
                            flag = true
                        end
                    end
                end

                #Check synsets against synset file/object
                File.open(str).each do |line|

                    if line != nil #non empty line
                        #TEST THIS REGEX HARD
                        if !(line =~ /^id: [0-9]* synset: [a-zA-Z_\d\.\-\/']+([,][a-zA-Z_\d\.\-\/']+)*$/)
                            if flag != true #if error flag hasn't been tripped yet
                                flag = true
                            end
                        else #if no error flag, and pattern matches
                            if flag != true
                                #parse string to store into set
                                arr = line.split(" ")

                                syns_id = arr[1].to_i

                                s_ids << syns_id 
                            end
                        end
                        else #empty line
                            if flag != true #if error flag hasn't been tripped yet
                                flag = true
                            end
                        end
                    end
                end

                if (flag == true)
                    hsh[:result] = :false
                else
                    compArr1 = hypHash.keys
                    compArr2 = hypHash.values

                    found = false;

                    for elem in s_ids
                        # if !((compArr1.include?(elem)) || (compArr2.include?(elem)))
                        #     # || (@synsets.instance_variable_get(:@list).has_key? elem))
                        #     flag = true
                        #     puts "value"
                        #     puts elem
                        #     puts flag
                        # end
                        for e1 in compArr1
                            if e1.eql? elem
                                found = true;
                            end
                        end
                        for e2 in compArr2
                            if e2.eql? elem
                                found = true
                            end
                        end
                        if @synsets.instance_variable_get(:@list).has_key? elem
                            found = true
                        end
                        if found !=true
                            flag = true
                        end
                    end

                    if (flag == true)
                        hsh[:result] = false
                    else
                        command =~ /^\s*[a-z]+\s+([\w\/\-\.]+)\s+([\w\/\-\.]+)$/
                        str = $1
                        str1 = $2
                        if @synsets.load(str) != nil && @hypernyms.load(str1) != nil
                            hsh[:result] = false
                        else
                            hsh[:result] = true 
                    end
                end
            end
        elsif input.eql? "lookup"
            #lookup process
            hsh[:recognized_command] = :lookup

            if (command =~ /^\s*[a-z]+\s*(\d+)$/)
                int = $1.to_i
                hsh[:result] = @synsets.lookup(int)
            else
                hsh[:result] = :error
            end
        elsif input.eql? "find"
            #find process
            hsh[:recognized_command] = :find

            if (command =~ /^\s*[a-z]+\s+([a-zA-Z_\d\.\-\/']+)$/)
                noun = $1.to_s
                hsh[:result] = @synsets.findSynsets(noun)
            else
                hsh[:result] = :error
            end
        elsif input.eql? "findmany"
            #findmany process
            hsh[:recognized_command] = :findmany

            if (command =~ /^\s*[a-z]+\s+([a-zA-Z_\d\.\-\/']+[,][a-zA-Z_\d\.\-\/']+)*$/)
                arr = $1.split
                a = @synsets.findSynsets(arr)
                hsh[:result] = @synsets.findSynsets(arr)
            else
                hsh[:result] = :error
            end
        elsif input.eql? "lca"
            #lca process
            hsh[:recognized_command] = :lca

            if (command =~ /^\s*[a-z]+\s+([0-9]+)\s+([0-9]+)$/)
                #do something
                id1 = $1.to_i
                id2 = $2.to_i

                hsh[:result] = @synsets.lca(id1, id2)
            else
                hsh[result] = :error
            end
        else
            hsh[:recognized_command] = :invalid
        end

        return hsh 
    end
end
