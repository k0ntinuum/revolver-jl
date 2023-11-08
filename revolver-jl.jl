using Printf
using Random

struct Settings
    num_symbols:: Int
    num_modes :: Int
    num_words :: Int
    min_len :: Int
    max_len :: Int
    in_alph :: String
    out_alph :: String 
    rounds :: Int 
end


    

function random_word(k) 
    rand(1:n,k)
end

function random_words(s :: Settings) 
    map(i -> rand(1:s.num_symbols, rand(s.min_len:s.max_len) ), collect(1:(s.num_words - s.num_symbols) ))
end

function repeats_in(w) 
    count(map(x -> w[x[1]] == w[x[2]], [(i,j) for i=1:length(w) for j=1:length(w) if  i < j])) != 0
end

function prefix(p,q)
    length(q) < length(p) ? false : count(map(i -> p[i] == q[i], 1:length(p))) == length(p)
end

function is_prefix_code(w)
    count(map(x -> prefix(w[x[1]], w[x[2]]), [(i,j) for i=1:length(w) for j=1:length(w) if  i != j])) == 0
end


include("key-jl.jl")


function str_from_vec(v,x,s :: Settings)
    join(map(i -> s.out_alph[i:i] * x,v ))
end

function rgb(r,g,b)
    "\e[38;2;$(r);$(g);$(b)m"
end

function red()
    rgb(255,0,0)
end

function yellow()
    rgb(255,255,0)
end

function white()
    rgb(255,255,255)
end

function gray(h)
    rgb(h,h,h)
end


function print_mode(m,j,s :: Settings)
    for i in 1:s.num_words
        print(white(), @sprintf("%2d  ",j), yellow(), @sprintf("%-5s",str_from_vec(m[1][i],"",s))  )
        print(red(), @sprintf("%-5s",str_from_vec(m[2][i],"",s)) , white(), @sprintf("%2d\n",m[3][i]))
    end
    @printf("\n")
end

function print_key(k, s :: Settings)
    for j in eachindex(k) print_mode(k[j],j, s) end
end

function roll_mode(m, w, a, sett:: Settings)
    for i in 1:length(m[w]) 
        m[w][i] = map(x -> mod1(x+a, sett.num_symbols), m[w][i]) 
    end
end

function next(x, k , m, t) 
    for i in eachindex(k[m][t]) if prefix(k[m][t][i], x) return i end end
end

function encode(p,q,s)
    k = deepcopy(q)
    c = Int64[]
    m = 1
    while length(p) > 0
        j = next(p, k , m, 1)
        append!(c,k[m][2][j])
        p = last(p, length(p) - length(k[m][1][j]))
        x = k[m][1][j][begin] #first symbol of p
        y = k[m][2][j][begin] #first symbol of c
        m = k[m][3][j]
        roll_mode(k[m],mod1(y,2), x,s)
    end
    c
end

function decode(c,q,s)
    k = deepcopy(q)
    p = Int64[]
    m = 1
    while length(c) > 0
        j = next(c, k , m, 2)
        append!(p,k[m][1][j])
        x = k[m][1][j][begin] #first symbol of p
        y = k[m][2][j][begin] #first symbol of c
        c = last(c, length(c) - length(k[m][2][j]))
        m = k[m][3][j]
        roll_mode(k[m], mod1(y,2),x,s)
    end
    p
end

function encrypt(p, q, r,s)
    for i in 1:r
        p = encode(p,q,s)
        p = reverse(p)
    end
    p
end

function decrypt(c, q, r,s)
    for i in 1:r
        c = reverse(c)
        c = decode(c,q,s)
    end
    c
end

function demo()
    #random_revolver_key( num_symbols, num_modes, num_words, min_len, max_len)
    alph = "O|@#"
    num_symbols = 2
    num_modes = 6
    num_words = 4
    min_len = 2
    max_len = 2
    in_alph = alph
    out_alph = alph
    rounds = 2
    s= Settings(num_symbols,num_modes, num_words, min_len, max_len, in_alph, out_alph, rounds)   
    k = random_revolver_key(s)
    print(k[1])
    
    print(white(),"key = \n",gray(160))
    print_key(k, s)
    print("r = ",s.rounds,"\n\n")
    for i in 1:20
        p = rand(1:s.num_symbols,rand(1:10))
        print(white(),"f( ",red(),@sprintf("%-10s",str_from_vec(p,"",s)),white()," ) = "  )
        c = encrypt(p,k,s.rounds,s)
        print(yellow(),@sprintf("%-30s\n", str_from_vec(c,"",s)),white())
        d = decrypt(c,k,s.rounds,s)
        if p != d @printf "ERROR\n\n" end
    end
end



