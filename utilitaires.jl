include("Projet_Base.jl")

#Sructure pratique
mutable struct regroupeDistance
    ens::Vector{Int64} # Regroupement
    distance::Int64 # Distance minimale à parcours pour traiter toutes les villes du regroupement
    cycle::Vector{Int64} # Cycle
end

# Calcule le poids total des demandes de villes dans un tableau
# Entrée : Un ensemble de villes, et les demandes de chaque ville
# Sortie : Le poids total de demandes de l'ensemble de villes
function poidsTot(tab::Vector{Int64},demande::Vector{Int64})
    retour::Int64 = 0;;
    for client in tab
        if client>1
            retour+=demande[client-1]
        end
    end
    return retour
end

# Renvoie 1 si elt un entier est dans ensemble
function estDansEns(elt::Int64,ensemble::Vector{Int64})
    for e in ensemble
        if e==elt
            return 1
        end
    end
    return 0
end