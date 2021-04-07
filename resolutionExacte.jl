include("Projet_Base.jl")
include("utilitaires.jl")


#===============Méthode exacte===============#

# Crée l'ensemble des sous ensembles de villes que l'on peut servir en une tournée
# Entrée : Un ensemble vide (Ou des regroupements déjà fait si on veut), un tableau vide(pour la récursion),
#          la ville de départ (exclure 1 pour l'entrepot), les données sur les villes
# Sortie : Ensemble de l'ensemble de villes que l'on peut servir en une seule tournée
function partitionner(S::Vector{Vector{Int64}},tab::Vector{Int64},i::Int64,data::donnees)
    for elt in collect(Int64, i:data.nbVilles)
        if (poidsTot(tab,data.demande)+data.demande[elt-1]<=data.capacite)
            tabAuxi::Vector{Int64} = vcat(tab,[elt])
            push!(S,tabAuxi)
            partitionner(S,tabAuxi,elt+1,data)
        end
    end
    return S
end

# Retourne un tableau des regroupements avec la longueur du plus petit tour 
# Entrée : Ensemble de l'ensemble de villes que l'on peut servir en une seule tournée, le distancier entre ces villes (+ entrepôt)
# Sortie : L'ensemble en entrée + la longueur du plus petit tour de chaque tournée et le cycle qui correspond à cette longueur
function regroupement(S::Vector{Vector{Int64}},distancier::Matrix{Int64})
    retour::Vector{regroupeDistance} = []
    for ens in S
        d::Matrix{Int64} = distancier[vcat([1],ens),vcat([1],ens)]
        cycle::Vector{Int64}, longueur::Int64 = solveTSPExact(d)
        push!(retour,regroupeDistance(ens,longueur,convertirPrintCycles(ens,cycle)))
    end
    return retour
end

# Un print plus joli pour la structure regroupement/distance
function printregroupDistance(toPrint::regroupeDistance)
    print(toPrint.ens)
    print(" : ")
    print(toPrint.distance)
    println()
end

# Puisque TSP ne renvoie pas les bons numéros (toutes les villes à -1), cette fonction les remet comme il faut !
function convertirPrintCycles(ens::Vector{Int64},cycle::Vector{Int64})
    vraiCycle::Vector{Int64} = []
    ensEtEnt::Vector{Int64} = vcat([1],ens)
    for i in cycle
        push!(vraiCycle,ensEtEnt[i])
    end
    return vraiCycle
end

# Fonction de résolution du PL, classique
function resolutionExacte_implicite(solverSelected::DataType, data::donnees, S::Vector{Vector{Int64}},ensembles::Vector{regroupeDistance})
    m::Model = Model(solverSelected)
    nbvar::Int64 = length(S)
    @variable(m, x[1:nbvar], binary=true)
    @objective(m, Min, sum(ensembles[j].distance*x[j] for j in 1:nbvar))
    @constraint(m, contrainte[i in 2:data.nbVilles], sum(estDansEns(i,ensembles[j].ens)*x[j] for j in 1:nbvar) == 1)
    return m
end

# Setup du PL et affichage des résultats
#Modeaffichage à true = c'est plus long mais plus joli :) Les tests de temps se font sans.
function resolutionExacte(nom_fichier::String,modeAffichage::Bool)
    data::donnees = lecture_donnees(nom_fichier)
    S::Vector{Vector{Int64}} = []
    vide::Vector{Int64} = []
    S=partitionner(S,vide,2,data)
    ensembles = regroupement(S, data.distance)
    m::Model = resolutionExacte_implicite(GLPK.Optimizer,data,S,ensembles)

    optimize!(m)

    status = termination_status(m)

    if status == MOI.OPTIMAL
        
        if(modeAffichage)
            selections = value.(m[:x])
            print("On a selectionné ")
            print(floor(Int64,sum(value.(m[:x])[i] for i in 1:length(S))))
            println(" tournées :")
        for i in 1:length(S)
            if selections[i] > 0
                print(vcat(ensembles[i].cycle,[ensembles[i].cycle[1]]))
                print(" de longueur ")
                println(ensembles[i].distance)
            end
        end
        else
            selections = value.(m[:x])
            for i in 1:length(S)
                if selections[i] > 0
                    print(vcat(ensembles[i].cycle,[ensembles[i].cycle[1]]))
                end
            end
        end
        println("Pour une longueur totale de ", objective_value(m))
        println()
        return objective_value(m)
    elseif status == MOI.INFEASIBLE
        println("Problème impossible !")
    elseif status == MOI.INFEASIBLE_OR_UNBOUNDED
        println("Problème non-borné !")
    end
end

#===============Fin Méthode exacte===============#






