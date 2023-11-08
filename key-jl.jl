function random_revolver_key( s :: Settings)
	function random_unique_words()
		@label try_again
    	w = random_words(s)
    	if repeats_in(1) @goto try_again end
    	for i in 1:s.num_symbols
    		push!(w, [ i ] )
    	end
    	w
	end
	function possible_prefix_code() 
    	map(i -> rand(1:s.num_symbols,rand(s.min_len:s.max_len)), collect(1:(s.num_words) ))
	end
	function random_prefix_code(tries)
    	for i in 1:tries
        	w = possible_prefix_code()
        	if is_prefix_code(w) return w end
    	end
    	throw("failed to find prefix code")
	end
	
	function random_mode()
    	[ random_unique_words() , random_prefix_code(10000) , Random.randperm(s.num_modes)[1:s.num_words]  ]
	end
	
	map(i -> random_mode(), 1:s.num_modes)
end