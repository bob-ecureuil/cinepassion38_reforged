<!-- ========= V U E =============================================================================================
 fichier				: ./mvc/vue/film/accueil.inc.php
 auteur					: Thomas GRAULLE
 date de création		: septempbre 2018
 date de modification	:
 rôle					: permet de générer le code xhtml de la partie centrale de la page d'accueil du module film
<!--  ================================================================================================================= --> -->

<div id='content2'>

    
    <span class='contentInfos'>
	    <div id="fiche">
	    		<div id="bar">
	            <div class="elementBar <?php  echo ($action === 'nbFilmAnnee' ? 'enable' : 'disable') ;?>"><a href="<?php echo "index.php?module=film&amp;page=statistique&amp;action=nbFilmAnnee&amp;section=$currentSection" ?>"><span>nb films / année</span></a></div>
	            <div class="elementBar <?php  echo ($action === 'nbFilmGenre' ? 'enable' : 'disable') ;?>"><a href="<?php echo "index.php?module=film&amp;page=statistique&amp;action=nbFilmGenre&amp" ?>"><span>nb films / genre</span></a></div>
	        </div>
			<div id="dataFiche">
				<span>
					La cinémathèque est composée de <?php echo(isset($phrase) ? $phrase : ':)');?>
				</span>
				<?php 
					if (isset($affichage) && $affichage != null) {
						switch ($action) {
							case 'nbFilmGenre': // classic case
                                ?>
									<div class="">
								<?php
                                while ($statistique = $statistiquesCollection->getUnElement()) {
                                    echo $statistique->getXhtmlStatistique();
                                }
                                ?>
                                        <br/><hr/>
									</div>
								<?php

                                break;
							
							case 'nbFilmAnnee':
								?>
									<div class="">
								<?php 
								while ($statistique = $statistiquesCollection->getUnElement()) {
									echo $statistique->getXhtmlStatistique();
								}
								?>
                                        <br/><hr/>
									</div>
<!--                            Show the navigation bar-->
									<div id="navigation"><?php echo isset($getXhtmlBoutons) ? $getXhtmlBoutons : '' ; ?></div>
									<div id="navigation"><?php echo isset($getXhtmlNumbers) ? $getXhtmlNumbers : '' ; ?></div>
								<?php 
								
								break;
								
						}
					}
				?>
				
	        </div>
	    </div>
    </span>
</div><!-- content2 -->