<!-- ========= V U E =============================================================================================
 fichier				: ./mvc/vue/cinepassion38/plan.inc.php
 auteur					: Christophe Goidin (christophe.goidin@ac-grenoble.fr)
 date de création		: juin 2017
 date de modification	:
 rôle					: permet de générer le code xhtml de la partie centrale de la page présentant le plan de notre association
 ================================================================================================================= -->

<div id='content2'>
	<span class='contentTitre'>
		adresse
	</span>
	<span class='contentInfos'>
		Notre association est située à l'adresse suivante : 30 rue Louise Michel 38100 Grenoble. Le plan Google présenté ci-dessous permet de nous situer facilement dans la ville.
	</span>

	<span class='contentTitre'>
		plan
	</span>
	<span class='contentInfos'>
		<?php echo $plan; ?>
		<br/><br/>
		<span class="centrer">
			<a href="<?php echo $lienGoogleMaps; ?>">
				<img alt="maps" title="ouvrir avec google maps" src="./image/divers/plan.png" />
			</a>
		</span>
	</span>
</div><!-- content2 -->