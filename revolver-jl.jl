using Printf
using Random

random_word(k) = rand(1:n,k)

random_words(k,l,L) = map(i -> rand(1:length(alph),rand(l:L)), collect(1:k))

prefix(p,q) = length(q) < length(p) ? false : count(map(i -> p[i] == q[i], 1:length(p))) == length(p)

is_prefix_code(w) = count(map(x -> prefix(w[x[1]], w[x[2]]), [(i,j) for i=1:length(w) for j=1:length(w) if  i != j])) == 0
no_repeats(w) = count(map(x -> w[x[1]] == w[x[2]], [(i,j) for i=1:length(w) for j=1:length(w) if  i < j])) == 0

function random_prefix_code(k,l,L,t)
    for i in 1:t
        w = random_words(k,l,L)
        if is_prefix_code(w) return w end
    end
    throw("failed to find prefix code")
end

function random_unique_words(k,L)
    w = random_words(k-length(alph), 2, L)
    while !no_repeats(w) w = random_words(k-length(alph), 2, L) end
    map(i -> push!(w, [i]), 1:length(alph))
    w
end

random_mode(m, M) = [random_unique_words(num_w,L), random_prefix_code(num_w,l,L,10000),rand(1:M,num_w) ]

random_key(M) = map(i -> random_mode(i,M), 1:M)


str_from_vec(v)  = join(map(i -> alph[i:i], v))

rgb(r,g,b) =  "\e[38;2;$(r);$(g);$(b)m"

red() = rgb(255,0,0);
yellow() = rgb(255,255,0);
white() = rgb(255,255,255);
gray(h) = rgb(h,h,h)


function print_mode(m,j)
    for i in 1:length(alph)+e
        print(white(), @sprintf("%2d  ",j), yellow(), @sprintf("%-5s",str_from_vec(m[1][i]))  )
        print(red(), @sprintf("%-5s",str_from_vec(m[2][i])) , white(), @sprintf("%2d\n",m[3][i]))
    end
    @printf("\n")
end

print_key(k) = for j in eachindex(k) print_mode(k[j],j) end
roll_mode(m, w, a) = for i in 1:num_w m[w][i] = map(x -> mod1(x+a, length(alph)), m[w][i]) end
next(x, k , m, s) = for i in eachindex(k[m][s]) if prefix(k[m][s][i], x) return i end end

function encode(p,q)
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
        roll_mode(k[m],mod1(y,2), x)
    end
    c
end
function decode(c,q)
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
        roll_mode(k[m], mod1(y,2),x)
    end
    p
end

function encrypt(p, q, r)
    for i in 1:r
        p = encode(p,k)
        p = reverse(p)
    end
    p
end

function decrypt(c, q, r)
    for i in 1:r
        c = reverse(c)
        c = decode(c,k)
    end
    c
end

function demo()
    print(white(),"key = \n",gray(160))
    print_key(k)
    print("r = ",r,"\n\n")
    for i in 1:20
        p = rand(1:length(alph),rand(1:10))
        print(white(),"f( ",red(),@sprintf("%-10s",str_from_vec(p)),white()," ) = "  )
        c = encrypt(p,k,r)
        print(yellow(),@sprintf("%-30s\n", str_from_vec(c)),white())
        d = decrypt(c,k,r)
        if p != d @printf "ERROR\n\n" end
    end
end

#alph = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

# alph = "abcdefghijklmnopqrstuvwxyz"
# alph = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
alph ="0|"
e = 1 # words beyond length of alph
num_w = length(alph) + e
n = 6
l = 1
L = 2
r = 4
k = random_key(n)
