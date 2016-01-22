require 'set'

class Spellchecker

  
  ALPHABET = 'abcdefghijklmnopqrstuvwxyz'

  #constructor.
  #text_file_name is the path to a local file with text to train the model (find actual words and their #frequency)
  #verbose is a flag to show traces of what's going on (useful for large files)
  def initialize(text_file_name)
    #read file text_file_name
    #extract words from string (file contents) using method 'words' below.
    #put in dictionary with their frequency (calling train! method)
    #######File.readlines(text_file_name).each do |contents|
	file = File.new(text_file_name).read
    	file_word_list=words(file)
    	@dictionary =train!(file_word_list)
   ## end # end of the loop 

	
   
  end

  def dictionary
    #getter for instance attribute
    @dictionary
  end
  
  #returns an array of words in the text.
  def words (text)
    return text.downcase.scan(/[a-z]+/) #find all matches of this simple regular expression
  end

  #train model (create dictionary)
  def train!(word_list)
    #create @dictionary, an attribute of type Hash mapping words to their count in the text {word => count}. Default count should be 0 (argument of Hash constructor).
	count= Hash.new(0)
	word_list.each { |f| count[f] +=1 } 
	return count 
  end



  #lookup frequency of a word, a simple lookup in the @dictionary Hash
  def lookup(word)
	return @dictionary[word]
  end
  
  #generate all correction candidates at an edit distance of 1 from the input word.
  def edits1(word)
    len = word.length
    counter = len-2
    deletes    = []
	for the_index in 0..len-1
	the_string = word.dup
	the_string.slice!(the_index)
	deletes.push(the_string)
	end 
    #all strings obtained by deleting a letter (each letter)
	
    transposes = []
	if counter>0
	(0..counter).each do |the_index|
	the_string=word.dup
	the_string[the_index+1]=word[the_index]
	the_string[the_index]=word[the_index+1]
	transposes.push(the_string)
	end #end of the loop
       end ## end of the if 
    #all strings obtained by switching two consecutive letters
    inserts = []
	for the_index in 0..len
	ALPHABET.each_char do |lett|
	the_string = word.dup
	the_string=the_string.insert(the_index,lett)
	inserts.push(the_string)
	end
	end 


 	
    # all strings obtained by inserting letters (all possible letters in all possible positions)
    replaces = []
	for the_index in 0..len-1
		ALPHABET.each_char do |lett|
		the_string = word.dup
		the_string[the_index]=lett
		replaces.push(the_string)
		end
	end 

	 	#(len+1).times {|the_index| ALPHABET.each_byte {|l| inserts << word[0...the_index]+l.chr+word[the_index..-1] } }

	 	#(len+1).times {|the_index| ALPHABET.each_byte {|l| replaces << word[0...the_index]+l.chr+word[the_index..-1] } }

    #all strings obtained by replacing letters (all possible letters in all possible positions)

    return (deletes + transposes + replaces + inserts).to_set.to_a #eliminate duplicates, then convert back to array
  end
  

  # find known (in dictionary) distance-2 edits of target word.
  def known_edits2 (word)
    # get every possible distance - 2 edit of the input word. Return those that are in the dictionary.
	result =[]
	ed1=edits1(word)
	ed1.each do |d|
	result.concat(edits1(d))
	end
	return (result)
	#edits1(word).each {|e1| edits1(e1).each{
	#|e2| result << e2 if @dictionary.has_key?(e2) }}.to_set.to_a
  end
	

  #return subset of the input words (argument is an array) that are known by this dictionary
  def known(words)
    #return words.find_all {true } #find all words for which condition is true,
                                    #you need to figure out this condition
	#the_result = words.find_all {|ww| @dictionary.has_key?(ww)}
	#the_result.empty? ? nil : the_result
	   if words.class == Array
    result = words.delete_if { |word| !@dictionary.has_key?(word) }.uniq
    result.any? ? result : nil
  else
    words if @dictionary.has_key?(words)
  end   

  end


  # if word is known, then
  # returns [word], 
  # else if there are valid distance-1 replacements, 
  # returns distance-1 replacements sorted by descending frequency in the model
  # else if there are valid distance-2 replacements,
  # returns distance-2 replacements sorted by descending frequency in the model
  # else returns nil
  def correct word

	#(known([word]) or known(edits1(word)) or known_edits2(word) or[word])


	passed = known([word])
	
	if passed
		if passed.length == 1
		return passed
		end
	end
	
	passed = known(edits1(word))
	if !passed
		passed = known_edits2(word)
	end

	if passed
		the_secondPass = []
		@dictionary.sort_by {|a_key,a_value| a_value}.reverse.each do |key, value|
			the_string = key.dup
			if passed.include?(the_string) == true
			if the_secondPass.include?(the_string) == false
				the_secondPass.push(the_string)
		       	end
			end
	end
	return the_secondPass
	end
	return nil
  end    
 

end

