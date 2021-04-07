include("Projet_Base.jl")
include("utilitaires.jl")

# Crée les tournées qui ne contiennent qu'une ville
# Entrée : S vecteur vide, data données du problème
# Sortie : Vecteur S des tournées [1,i,1], i numéro de villes
function initApprochee(S::Vector{Vector{Int64}},data::donnees)
    for i in 1:data.nbVilles
        tabAuxi::Vector{Int64} = [1,i,1]
            push!(S,tabAuxi)
    end
    return S
end

# Construit la matrice de gains en fonction des paires de fusions
# Entrée : Données du problème
# Sortie : Matrice de gains
function construitreMatGains(data::donnees)
    matGains::Matrix{Int64} = zeros((data.nbVilles-2,data.nbVilles-1))
    for i in 1:data.nbVilles-2
        for j in i+1:data.nbVilles-1
            if (data.demande[i]+data.demande[j]<=data.capacite)
                matGains[i,j] = data.distance[i+1,1] + data.distance[1,j+1] - data.distance[i+1,j+1]
            else
                matGains[i,i+1] = -1
            end
        end
    end
    return matGains
end

# Construit l'ensemble des paires possibles et les classe par ordre de gains de fusion
# Entrée : Nombre de villes dont il faut faire les paires, matrice de gains
# Sortie : Listes des paires rangées de manière décroissantes en fonction du gain
function paires(n::Int64,matGains::Matrix{Int64})
    nPairs::Int64 = (n-1)*(n-2)/2
    p = Vector{Pair}()
    index::Int64 = 1
    place::Bool = false
    for i in 2:n-1
        for j in i+1:n
            index = 1
            place = false
            while !place && index<size(p)[1]+1
                if(matGains[i-1,j-1]>matGains[p[index].first-1,p[index].second-1])
                    insert!(p,index,Pair(i,j))
                    place = true
                else
                    index+=1
                end
            end
            if !place
                push!(p,Pair(i,j))
            end
        end
    end
    return p
end

# Réalise une fusion de deux tournées contenant les villes dont on donne la paire et met à jour la liste des paires fusionnables
# Entrée : Tournee1, tournee2 à fusionner, liste des paires, et la paire considérée pour cette fusion
# Sortie : la tournée résultante, et la liste des paires à jour
function fusion(tournee1::Vector{Int64},tournee2::Vector{Int64},listeP::Vector{Pair},p::Pair)
#Copie car modification en place
t1Copie = tournee1
t2Copie = tournee2
    #Le but est d'avoir le premier element de la paire en fin de tournee1, et le second en fin de tournee2.
    if (p.first == t1Copie[2]) #first en début de tournée
        if (p.second == t2Copie[2]) #second en début de tournée
            reverse!(t1Copie)
        else #second en fin de tournée
            reverse(t1Copie)
            reverse!(t2Copie)
        end
    else #first en fin de tournée
        if (p.second != t2Copie[2]) #second en fin de tournée
            reverse!(t2Copie)
        end
    end
    t1Trunc = t1Copie[1:(size(t1Copie)[1]-1)]
    t2Trunc = t2Copie[2:size(t2Copie)[1]]
    tournee = vcat(t1Trunc,t2Trunc)

    #Faire le tri des paires :
    listeP_Filtree::Vector{Pair} = []
    for unePaire in listeP
    #Pas tous deux dans la tournée
        if !((estDansEns(unePaire.first,tournee)==1)&&((estDansEns(unePaire.second,tournee))==1))
            #Le premier elem est dans la tournée,et est accessible
            if estDansEns(unePaire.first,tournee)==1&&(tournee[2]==unePaire.first||tournee[size(tournee)[1]-1]==unePaire.first)
                push!(listeP_Filtree,unePaire)
            #Le second elem est dans la tournée, et est accessible
            elseif  estDansEns(unePaire.second,tournee)==1&&(tournee[2]==unePaire.second||tournee[size(tournee)[1]-1]==unePaire.second)
                push!(listeP_Filtree,unePaire)
            #Aucun des deux n'est dans la tournée
            elseif estDansEns(unePaire.first,tournee)+estDansEns(unePaire.second,tournee)==0
                push!(listeP_Filtree,unePaire)
            end
        end
    end
    return tournee,listeP_Filtree
end


# Construit l'ensemble final des tournées avec des fusions successives
# Entrée : Liste de paires fusionnables, données du problème, ensemble des tournées crées, emplacement des villes dans les tournées
# Sortie : Ensemble final de tournées
function construireTournees(listeP::Vector{Pair},data::donnees,S::Vector{Vector{Int64}},emplacement::Vector{Int64})
    paireConsideree = listeP[1]
    tournee1 = S[emplacement[paireConsideree.first]]
    tournee2 = S[emplacement[paireConsideree.second]]
    if poidsTot(vcat(tournee1,tournee2),data.demande)<=data.capacite
        S[emplacement[paireConsideree.first]],listeP=fusion(tournee1,tournee2,listeP,paireConsideree)
        S[emplacement[paireConsideree.second]]=[]
        ancienEmplacement = emplacement[paireConsideree.second]
        nouveauEmplacement = emplacement[paireConsideree.first]
        for entier in 1:data.nbVilles
            if emplacement[entier]==ancienEmplacement
                emplacement[entier] = nouveauEmplacement
            end
        end
    else
        popfirst!(listeP)
    end
    if (size(listeP)[1] > 0)
        construireTournees(listeP,data,S,emplacement)
    else
        return S
    end
end

# Calcule la longueur distance d'une tournée
# Entrée : Ensemble d'éléments et le distancier
# Sortie : Longueur d'une tournée
function calculLongueur(ens::Vector{Int64},distancier::Matrix{Int64})
    acc::Int64 = 0
    for i in 1:(size(ens)[1]-1)
        acc+=distancier[ens[i],ens[i+1]]
    end
    return acc
end

# Résolution du problème
function resolutionApprochee(nom_fichier::String)
    data::donnees = lecture_donnees(nom_fichier)
    S::Vector{Vector{Int64}} = []
    S = initApprochee(S,data)
    g = construitreMatGains(data)
    listeP = paires(data.nbVilles,g)
    tournées = construireTournees(listeP,data,S,collect(1:data.nbVilles))
    popfirst!(tournées)
    println("On a les tournées :")
    acc::Float64 = 0
    for ens in tournées 
        if size(ens)[1] > 0 
            print(ens)
            print(" de longueur ")
            longueur = calculLongueur(ens,data.distance)
            acc +=longueur
            println(longueur)
        end
    end
    print("Pour une longueur totale de ")
    println(acc)
    return acc
end