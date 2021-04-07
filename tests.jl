include("resolutionApprochee.jl")
include("resolutionExacte.jl")

function tests(nom_fichier::String)
    data::donnees = lecture_donnees(nom_fichier)
    S::Vector{Vector{Int64}} = []
    vide::Vector{Int64} = []
    S=partitionner(S,vide,2,data)
    ecart = abs(resolutionApprochee(nom_fichier)-resolutionExacte(nom_fichier,false))
    regroupements = regroupement(S, data.distance)
    S= []
    S = initApprochee(S,data)
    g = construitreMatGains(data)
    listeP = paires(data.nbVilles,g)
    tournées = construireTournees(listeP,data,S,collect(1:data.nbVilles))
    tempsMoyenPartitionnement::Float64 = 0
    tempsMoyenExacte::Float64 = 0
    tempsMoyenApprochee::Float64 = 0
    n::Int64 = 10

    for i in 1:n
        tempsMoyenPartitionnement += @elapsed(partitionner)
        tempsMoyenExacte += @elapsed(resolutionExacte(nom_fichier,false))
        tempsMoyenApprochee += @elapsed(resolutionApprochee(nom_fichier))
    end

    minRegroupements::Int64 = data.nbVilles
    maxRegroupements::Int64 = 0
    for regroup in regroupements
        if size(regroup.ens)[1] > maxRegroupements
            maxRegroupements = size(regroup.ens)[1]
        end
        if size(regroup.ens)[1] < minRegroupements
            minRegroupements = size(regroup.ens)[1]
        end
    end

    minTournées::Int64 = data.nbVilles
    maxTournées::Int64 = 0
    for tournée in tournées
        if size(tournée)[1]-2 > maxTournées
            maxTournées = size(tournée)[1]-2
        end
        if size(tournée)[1]-2 < minTournées && size(tournée)[1] > 0
            minTournées = size(tournée)[1]-2
        end
    end
    tempsMoyenPartitionnement = tempsMoyenPartitionnement/n
    tempsMoyenExacte = tempsMoyenExacte/n
    tempsMoyenApprochee = tempsMoyenApprochee/n

    println("=============================================================================================================================")
    println("=============================================================================================================================")
    println("==========================================================Résultats==========================================================")
    println("=============================================================================================================================")
    println("=============================================================================================================================")
    print("Fichier : ")
    println(nom_fichier)
    print("Ecart : ")
    println(ecart)
    print("tempsMoyenPartitionnement : ")
    println(tempsMoyenPartitionnement)
    print("tempsMoyenApprochee : ")
    println(tempsMoyenApprochee)
    print("tempsMoyenExact : ")
    println(tempsMoyenExacte)
    print("Regroupements par méthode exacte : ")
    print("Min : ")
    print(minRegroupements)
    print(" Max : ")
    print(maxRegroupements)
    print(" Nombre : ")
    println(size(regroupements)[1])
    print("Tournees par méthode approchée : ")
    print("Min : ")
    print(minTournées)
    print(" Max : ")
    print(maxTournées)
    print(" Nombre : ")
    println(size(tournées)[1])
    
end