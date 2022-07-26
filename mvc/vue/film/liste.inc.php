<!-- ========= V U E =============================================================================================
 fichier				: ./mvc/vue/film/accueil.inc.php
 auteur					: Thomas GRAULLE
 date de création		: septempbre 2018
 date de modification	:
 rôle					: permet de générer le code xhtml de la partie centrale de la page d'accueil du module film
<!--  ================================================================================================================= --> -->

<div id='content2'>
   
 <?php 
 if (isset($nbFilm) && isset($listeFilms) && isset($currentSection) && isset($nbTotalSection) && isset($nbElementBySection) && isset($getXhtmlNumbers) && isset($getXhtmlBoutons)) {
     $firstFilmShowed = ($nbElementBySection * $currentSection) + 1;
     $lastFilmShowed = ($nbElementBySection) * ($currentSection + 1);
     ?>
     <div id="listeTable">
     	<table id="table">
     		<tr> 
     			<th class="noBorderRight"> Les <?php echo $nbFilm; ?> films de notre cinéma </th>
     			<th class="noBorderRight noBorderLeft"> section n° <?php echo $currentSection; ?>/<?php echo $nbTotalSection; ?> </th>
     			<th colspan="2" class="noBorderLeft"> films n°<?php echo $firstFilmShowed; ?> à <?php echo $lastFilmShowed; ?> </th>
     		</tr>
     		<tr>
     			<th>Titre </th>
     			<th>Genre</th>
     			<th>Année</th>
     			<th>Durée</th>
     		</tr>
     <?php
        while ($film = $listeFilms->getUnElement()) {
         	?>
			<tr onclick="document.location='./index.php?module=film&amp;page=fiche&amp;section=<?php echo $film->num;?>'" >
                <td> <?php echo $film->titre ?> </td>
                <td> <?php echo $film->libelleGenre ?> </td>
                <td> <?php echo $film->anneeSortie ?> </td>
                <td> <?php echo $film->duree ?> </td>
			</tr>
             <?php
                
		}
        ?>
    	</table>
    </div>
    <div id="navigation">
    	<div id="button" <?php echo intval(configuration::get('navigationPosition')) === 2 ? ' class="displayInline" ' : 'displayBlock' ; ?> > <!-- check if the navigation css must be show inline or block -->
    		<?php echo $getXhtmlBoutons; ?>
    	</div>
       <div id="number" <?php echo intval(configuration::get('navigationPosition')) === 2 ? ' class="displayInline" ' : 'displayBlock' ; ?> >
            <?php echo $getXhtmlNumbers; ?>
        </div>
    </div>
<?php
     } else {
     ?>
     <h1>Erreur lors de la génération de cette page</h1>
    <?php
 }
 ?>
</div><!-- content2 -->

        