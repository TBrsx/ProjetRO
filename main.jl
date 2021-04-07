include("resolutionApprochee.jl")
include("resolutionExacte.jl")

function bouclePrincipale(nom_fichier::String,boucler::Bool)
    while(boucler == true)
        data::donnees = lecture_donnees(nom_fichier)
        option::Int64 = 6
        print("Fichier considéré : ")
        println(nom_fichier)
        println("Que dois-je faire ? (Entrer le numéro correspondant :)")
        println("0. Résolution exacte avec affichage minimal et test de coût")
        println("1. Résolution approchée et test de coût")
        println("2. Résoltuion exacte affichage normal")
        println("3. Résolution approchée")
        println("4. Exacte affichage normal ET approchée")
        println("5. Changer le fichier")
        println("6. Quitter")
        parser = readline()
        option = parse(Int64,parser)
        println("________________________________________")
        println()
        #Julia n'a pas de case/switch ! Honteux !
        if option == 0
            @time(resolutionExacte(nom_fichier,false))
            println()
            println("Appuyer sur entrée pour continuer...")
            readline()
        elseif option == 1 
            @time(resolutionApprochee(nom_fichier))
            println()
            println("Appuyer sur entrée pour continuer...")
            readline()
        elseif option == 2
            resolutionExacte(nom_fichier,true)
            println()
            println("Appuyer sur entrée pour continuer...")
            readline()
        elseif option == 3
            resolutionApprochee(nom_fichier)
            println()
            println("Appuyer sur entrée pour continuer...")
            readline()
        elseif option == 4
            println("Exacte :")
            resolutionExacte(nom_fichier,true)
            println()
            println("Approchée : ")
            resolutionApprochee(nom_fichier)
            println()
            println("Appuyer sur entrée pour continuer...")
            readline()
            elseif option == 5
            println("path / nom du fichier ?")
            nom_fichier = readline()
        elseif option == 6
            boucler = false
        end
    end
end

function solveCovid19(nom_fichier::String)
    println(" ======================================================Début du programme ======================================================")
    bouclePrincipale(nom_fichier,true)
    println(" ======================================================Fin du programme ======================================================")
end