<!-- ========= V U E =============================================================================================
 fichier				: ./mvc/vue/user/modification.inc.php
 auteur					: Thomas Graulle
 date de création		: Mars 2019
 date de modification	:
 rôle					: permet de générer le code xhtml de la partie centrale de la page d'accueil du module cinepassion38
 ================================================================================================================= -->
    
<div id='content2'>
	<?php 
		switch ($action) {
			case 'defaut':
				echo $formulaire;
				break;
		}
	?>

</div><!-- content2 -->