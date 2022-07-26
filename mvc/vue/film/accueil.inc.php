<!-- ========= V U E =============================================================================================
 fichier				: ./mvc/vue/film/accueil.inc.php
 auteur					: Thomas GRAULLE
 date de création		: septempbre 2018
 date de modification	:
 rôle					: permet de générer le code xhtml de la partie centrale de la page d'accueil du module film
<!--  ================================================================================================================= --> -->

<div id='content2'>
	<?php
        if (isset($galerie)) {
            // ===============================================================================================================
            // Show all image to $galerie
            // This div is used by simpleSlideShow library
            // ===============================================================================================================
            ?>
        		<div id="slideshow">
        	<?php
            foreach ($galerie as $image) {
            	$arrayPath = explode('/', $image['affiche']);
                echo '
					<div>
						<a href="./index.php?module=film&amp;page=fiche&amp;section=' . $image['numFilm'] . '">
	                    	<img src="' . $image['affiche'] . '" alt="Image de: ' . end($arrayPath) . '" class="" />
	                    </a>
 					</div>
 				';
            }
            
            ?>
            	</div>
            <?php
            
        }
    ?>
    
    <span class='contentInfos'>
    
        Le module "film" permet d'avoir accès à l'intégralité des fonctionnalités de notre cinémathèque en rapport avec les films. Ces fonctionnalités sont toutes accessibles à partir du menu "film" ou directement à partir de certaines pages. Notre cinémathèque est actuellement composée de <?php echo isset($nbFilm) ? $nbFilm : '0' ?> films répartis dans des genres très variés afin de plaire au plus grand nombre : drame, comédie romantique, horreur, fantastique, animation, ...
        Le module "Film" permet de découvrir l'intégralité des films présents dans notre cinémathèque. Plusieurs fonctionnalités sont accessibles. Vous avez notamment la possibilité de visualiser la liste intégrale des films triés par ordre croissant. Ces films vous sont présentés sous forme d'un tableau incluant un système de navigation afin de permettre un déplacement aisé de page en page.
        
        Une autre page vous présente les informations détaillées de chaque film. De nombreuses informations sont alors présentées sous forme d'onglets afin d'assurer aux visiteurs une navigabilité optimale. Parmi les informations accessibles, on peut citer entre autre : le résumé d'un film, sa date de sortie, sa durée, le nom du réalisateur et des acteurs avec leur rôle respectif, le genre du film, ... Deux possibilités s'offrent à vous afin de visualiser les informations détaillées d'un film : soit en cliquant sur la jaquette d'un film de cette page parmi celles qui défilent aléatoirement, soit en cliquant sur un film à partir de la liste des films.
        Les membres de l'association sont les seuls à avoir la possibilité d'évaluer facilement et de commenter chacun des films présents. Les "simples" visiteurs, quant à eux, ne pourront que visualiser ces informations dispensées par nos différents membres.
        
        Ci-dessus, un aperçu de quelque uns des films présents dans notre cinémathèque. Un simple clic sur une des jaquettes d'un film permet d'accéder à sa fiche descriptive complète.
    </span>
</div><!-- content2 -->