<!-- ========= V U E =============================================================================================
 fichier				: ./mvc/vue/film/fiche.inc.php
 auteur					: Thomas GRAULLE
 date de création		: october 2018
 date de modification	:
 rôle					: permet de générer le code xhtml de la partie centrale de la page d'accueil du module fiche film
<!--  ================================================================================================================= --> -->

<div id='content2'>
    <div id="fiche">
    	<div id="affiche">
            <?php
                if ($imagesFilm != false) {
                    $i = 0;
                    $nbImage = count($imagesFilm);

                    while ($i < $nbImage) {

                        ?>
                        <a href="<?php echo $imagesFilm[$i]; ?>" rel="lightbox[roadtrip]" title="<?php echo "Image du film $titreFilm" ?>">
                        <?php

                        if ($i === 0) {
                            ?>
                            <img src="<?php echo $affiche; ?>" alt="Affiche du film"/>
                            <?php
                        }

                        ?>
                        </a>
                        <?php

                        $i++;
                    }
                } else {

                    ?>
                    <img src="<?php echo $affiche; ?>" alt="Affiche du film"/>
                    <?php
                }
            ?>
	      	<div id="navigation"><?php echo isset($getXhtmlBoutons) ? $getXhtmlBoutons : '' ; ?></div>
	     </div>
		<div id="contentFiche">
	        <div id="bar">
	            <div class="elementBar <?php  echo ($action === 'informations' ? 'enable' : 'disable') ;?>"><a href="<?php echo "index.php?module=film&amp;page=fiche&amp;action=informations&amp;section=$currentMovie" ?>"><span>informations</span></a></div>
	            <div class="elementBar <?php  echo ($action === 'histoire' ? 'enable' : 'disable') ;?>"><a href="<?php echo "index.php?module=film&amp;page=fiche&amp;action=histoire&amp;section=$currentMovie" ?>"><span>histoire</span></a></div>
	            <div class="elementBar <?php  echo ($action === 'acteurs' ? 'enable' : 'disable') ;?>"><a href="<?php echo "index.php?module=film&amp;page=fiche&amp;action=acteurs&amp;section=$currentMovie" ?>"><span>acteurs</span></a></div>
	            <div class="elementBar <?php  echo ($action === 'notations' ? 'enable' : 'disable') ;?>"><a href="<?php echo "index.php?module=film&amp;page=fiche&amp;action=notations&amp;section=$currentMovie" ?>"><span>notations</span></a></div>
	            <div class="elementBar <?php  echo ($action === 'commentaires' ? 'enable' : 'disable') ;?>"><a href="<?php echo "index.php?module=film&amp;page=fiche&amp;action=commentaires&amp;section=$currentMovie" ?>"><span>commentaires</span></a></div>
	        </div>
	        <div id="dataFiche">
	            <?php
	                if (isset($data) && $data != null) {
	                    switch ($action) {
	                        case ''; // classic case
	                            break;
	
	                        case 'informations':
	                            echo "Le film \"$titre\"" 
	                            . " est le " 
                                . $nEmeFilmReal 
                                . " dans notre cinématique du réalisateur " 
                                . $informations->nationaliteRealisateur 
                                . " " 
                                .  $informations->nomPrenomRealisateur 
                                . ". C'est un film " . $informations->genreFilm 
                                . " " 
                        		.  $informations->nationaliteFilm 
                                . " d'une durée de " 
                                . $informations->dureeFilm 
                        	    . " qui est sortie dans les salles de cinema en France le " 
                	    	    . $informations->dateSortieFilm;
                                break;
	
	                        case 'histoire':
	                            echo $synopsis;
	                            break;
	
	                        case 'acteurs':
	                            if (isset($acteurs) && !$acteurs->estVide()) {
	                                 while ($acteur = $acteurs->getUnElement()) {
                                         ?>
                                         <div class="acteurs">
                                             <div class="photo"><img class="<?php
                                                 echo file_exists("$pathOfImageActor/$acteur->prenom $acteur->nom.jpg")
                                                     ? 'ZoomEffect '
                                                     : ' '
                                                 ;
                                                 ?>" src="<?php
                                                 echo file_exists("$pathOfImageActor/$acteur->prenom $acteur->nom.jpg")
                                                     ? "$pathOfImageActor/$acteur->prenom $acteur->nom.jpg"
                                                     : $withoutImage
                                                 ;
                                                 ?>" alt="Photo de profile de la personnalité" /></div>
                                             <span class="descriptionPerso">
                                                 <?php echo "$acteur->prenom $acteur->nom"; ?>
                                                 <?php echo "$acteur->age ans"; ?>
                                                 <?php echo 'né' ;
                                                    echo $acteur->sexe = 'F' ? 'e ' : ' ' ;
                                                    echo 'le ';
                                                    echo $acteur->dateNaissance . ' ';
                                                ?>
                                                 <?php echo "à ";
                                                     if ($acteur->ville != null) {
                                                         echo $acteur->ville;
                                                         if ($acteur->pays != null) {
                                                            echo ' '. $acteur->pays;
                                                         }

                                                     } else {
                                                             echo '...';
                                                         }
                                                 ?>
                                             </span><br/>
                                             <span class="descriptionFilm"><?php
                                                echo "Dans ce film \"$titreFilm\" $acteur->prenom $acteur->nom joue le rôle de $acteur->role. ";
                                                echo $acteur->sexe == 'F' ? 'Elle ' : 'Il ';
                                                echo "était alors agé";
                                                echo $acteur->sexe == 'F' ? 'e ' : ' ' ;
                                                echo "de $acteur->ageSortie ans lors de la sortie de film en France.";
                                                echo "";
                                             ?></span>
                                         </div>
                                         <?php
                                     }
                                } else {
	                                echo "Il n'y a pas d'acteur implémenté pour ce film"; // for delete black
                                }

	                            break;
	
	                        case 'notation':
	                            break;
	
	                        case 'commentaires':
	                            break;
	
	                        default:
	                            break;
	                    }
	
	                } else {
	            ?>
	            <div id="inProgress" class="center">
	                <img alt="workInProgress" src="./image/divers/enTravaux.png" />
	            </div>
	            <?php
	                }
	            ?>
	        </div>	
        </div>
    </div>

</div><!-- content2 -->