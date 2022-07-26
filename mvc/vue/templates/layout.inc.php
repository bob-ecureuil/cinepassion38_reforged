<!-- ========= V U E =============================================================================================
 fichier				: ./mvc/vue/templates/layout.inc.php
 auteur					: Christophe Goidin (christophe.goidin@ac-grenoble.fr)
 date de création		: juin 2017
 date de modification	:
 rôle					: le layout permet de générer le code xhtml commun à TOUTES les pages du site
 						  le contenu principal de chaque page est généré par des vues qui dépendent de leurs contrôleurs respectifs
 ================================================================================================================= -->
<?php echo $doctype . PHP_EOL; ?>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="fr" lang="fr">
<head>
	<link rel='icon' type='image/png' href='./image/divers/bobine.png' />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>
        <?php echo $titreSiteWeb . PHP_EOL; ?>
    </title>
    <?php
    if (isset($globalHeaderLink)) {
        echo $globalHeaderLink . PHP_EOL;
    }
//     if (isset($texteDefilant)) {
//         echo $texteDefilant . PHP_EOL;
//     }
    if (isset($enteteLien)) {
        echo $enteteLien . PHP_EOL;
    }
    ?>
</head>
<body>
<div>
    <!-- La flèche permettant de revenir en haut de la page -->
    <img alt='retour en haut de la page' id='retourHautPage'
         src='./image/divers/flecheHautPage.png'
         onmouseover="window.document.getElementById('retourHautPage').src='./image/divers/flecheHautPageSurvol.png'"
         onmouseout="window.document.getElementById('retourHautPage').src='./image/divers/flecheHautPage.png'"
         onclick="$('html, body').animate({scrollTop:$('body').offset().top}, 'slow');" />
</div>
<!-- code permettant de figer le menu en haut de la page lors du défilement avec l'ascenseur vertical
     Affichage dynamique de l'image (flèche) permettant de revenir en haut de la page -->
<script type='text/javascript'>
    $(function () {
        $(window).scroll(function () {
            var vPositionMenuGauche = window.document.getElementById('header').offsetLeft + 11; // +11 car il y a 10 pixels de marge interne gauche + 1 pixel de bordure gauche
            let $menu = $('div#menu ul.nv1');
            let $image = $('img#retourHautPage');

            if ($(window).scrollTop() > 200) { 	// on fait défiler l'ascenseur vertical de plus de 200 pixels vers le bas
                let  $menu = $('div#menu ul.nv1');
                $menu.css('position', 'fixed');
                $menu.css('top', '0px');
                $menu.css('left', vPositionMenuGauche + 'px');
                $image.css('visibility', 'visible');
            }else {
                $menu.css('position', 'relative');
                $menu.css('top', '0px');
                $menu.css('left', '0px');
                $image.css('visibility', 'hidden');
            }
        });
    });
    // Define variable
    var arraySpecialChar = "<?php echo isset($arraySpecialChar) ? $arraySpecialChar : ''; ?>"

    <?php
        if (isset($_SESSION['rsa'])) {
            echo "var rsaPublicKey = `" . $_SESSION["rsa"] . "`;"; // Create the js variable for the public key
        }

    ?>

</script>

<div id='llm'>
    <a onclick='window.open(this.href); return false;' href='http://www.ac-grenoble.fr/lycee/louise.michel'>
        <img alt='' src='./image/partenaire/logoLLM.jpg' />
    </a>
</div>

<div id='lien'>
    <a onclick='window.open(this.href); return false;' href='http://www.allocine.fr'>
        <img alt='allocine' src='./image/partenaire/logoAllocineMini.png' />
    </a>&nbsp;&nbsp;
    <a onclick='window.open(this.href); return false;' href='http://www.empirecinemas.co.uk'>
        <img alt='empire' src='./image/partenaire/logoEmpireMini.png' />
    </a>&nbsp;&nbsp;
    <a onclick='window.open(this.href); return false;' href='http://www.sky.com/tv/channel/skycinema'>
        <img alt='skymovies' src='./image/partenaire/logoSkyMoviesMini.png' />
    </a>
</div>

<div id='header'>
    <img alt='' id='fondHeader' src='./image/divers/fondHeader.jpg' />
    <img alt='' src='./image/divers/cinepassion38Logo.png' id='cinepassion38' />
    <div id='authentification'>
		<?php 
			if (isset($_SESSION['user'])) {
				?>
                <span style="color: <?php echo ($_SESSION['user']->libelleTypeUser === 'administrateur' ? 'yellow' : 'white'); ?>;">
                    <img src="<?php echo $_SESSION['user']->avatarUser; ?>" alt="Image de l'avatar de l'utilisateur" style="height: 75px;">
                    <span>profile: <?php echo $_SESSION['user']->libelleTypeUser; ?></span>
                    <br/>
                    <a href="./index.php?module=user&amp;page=authentification&amp;action=deconnexion"> Déconnexion </a>

                </span>

                
                <?php
			} else {
				echo $formulaireConnexion . PHP_EOL;
			}
		?>
    </div>
    <div id='titre'>
        <?php echo $titreHeader . PHP_EOL; ?>
    </div>
    <div id='filAriane'>
        <?php echo $filAriane . PHP_EOL; ?>
    </div>
    <div id='version'>
        <?php echo $version. PHP_EOL; ?>
    </div>
    <div id='dateDuJour'>
        <?php echo $dateDuJour . PHP_EOL; ?>
    </div>
    <!-- Texte défilant -->
    <?php
    if (isset ( $texteDefilant )) {
        echo "<ul id='texteDefilant'><li>" . $texteDefilant ['titre'] . "</li>";
        foreach ( $texteDefilant ['contenu'] as $cle => $valeur ) {
            echo "<li><span class='titre'>" . $cle . "</span>" . $valeur . "</li>";
        }
        echo "</ul>" . PHP_EOL;
        
        ?>
            <script type='text/javascript'>
            	$(function(){
                	$("ul#texteDefilant").liScroll({travelocity: 0.02});
                });
            </script>
        <?php 
    }
    ?>
</div>
<!-- header -->

<div id='menu'>
    <ul class='nv1'>
        <li id='accueil'><a href='./index.php?module=home&amp;page=accueil'>&nbsp;</a></li>
        <li class='plus'>cinepassion38
            <ul class='nv2'>
                <li><a href='./index.php?module=cinepassion38&amp;page=accueil'>accueil</a></li>
                <li><a href='./index.php?module=cinepassion38&amp;page=partenaire'>nos partenaires</a></li>
                <li><a href='./index.php?module=cinepassion38&amp;page=plan'>plan</a></li>
            </ul>
        </li>
        <li class="plus">film
            <ul class="nv2">
                <li><a href="./index.php?module=film&amp;page=accueil">accueil</a></li>
                <li><a href="./index.php?module=film&amp;page=liste">liste</a></li>
				<li><a href="./index.php?module=film&amp;page=statistique">statistique</a></li>
            </ul>
        </li>
          <li class="plus">user
            <ul class="nv2">
                <li><a href="./index.php?module=user&amp;page=accueil">accueil</a></li>
               	<?php 
					if (isset($_SESSION['user'])) {
					?>
					<li><a href="./index.php?module=user&amp;page=authentification&amp;action=deconnexion">Deconnexion</a></li>
					<li><a href="./index.php?module=user&amp;page=modification&amp;action=defaut">Modification du mot passe</a></li>
					<?php 
					}
				?>	
            </ul>
        </li>
    </ul>
</div>
<!-- menu -->

<div id='main'>
		<span id="titreMain">
			<?php echo $titreMain . PHP_EOL; ?>
		</span>
    <?php
    echo (! isset ( $content1 ) ? "" : $content1 . "<hr class='marge' />");
    if (isset ( $lesEncartsGauche )) {
        echo "<div id='encartsGauche'>";
        while ( ! $lesEncartsGauche->estVide () ) {
            $unEncart = $lesEncartsGauche->getUnElement ();
            echo $unEncart->getXhtml ();
        }
        echo "</div><!-- encartsGauche -->\n";
    }
    if (isset ( $lesEncartsDroite )) {
        echo "<div id='encartsDroite'>";
        while ( ! $lesEncartsDroite->estVide () ) {
            echo $lesEncartsDroite->getUnElement ()->getXhtml ();
        }
        echo "</div><!-- encartsDroite -->\n";
    }
    echo $content2;
    ?>
    <hr />
</div>
<!-- main -->


<div id='planSite'>
    <div class='blocGauche'>
		<span class='centrer'></span>
        l' association
        <ul>
            <li><a href='./index.php?module=cinepassion38&amp;page=accueil'>accueil</a></li>
            <li><a href='./index.php?module=cinepassion38&amp;page=partenaire'>nos partenaires</a></li>
            <li><a href='./index.php?module=cinepassion38&amp;page=plan'>plan</a></li>
        </ul>
    </div>
    <div class='blocGauche'>
        <span class='centrer'></span>
		film
		<ul>
			<li><a href="./index.php?module=film&amp;page=accueil">accueil</a></li>
			<li><a href="./index.php?module=film&amp;page=liste">liste</a></li>
			<li><a href="./index.php?module=film&amp;page=statistique">statistique</a></li>
		</ul>
    </div>
    
        <div class='blocDroite'>
        <span class='centrer'>...</span>
    </div>
    
    <div class='blocGauche'>
        <span class='centrer'></span>
        User
		<li><a href='./index.php?module=user8&amp;page=accueil'>accueil</a></li>
        
    </div>

    <hr />
</div>

    <hr />
</div>
<!-- planSite -->

<div id='footer'>
    <img alt='' id='fondFooter' src='./image/divers/fondFooter.jpg' />
    <img alt='' id='cinepassion38LogoMini' src='./image/divers/cinepassion38LogoMini.png'  />
    <div id='w3c'>
        <img alt='' src='./image/divers/w3cXhtml1.0.png' />&nbsp;&nbsp;&nbsp;&nbsp;
        <img alt='' src='./image/divers/w3cCss.png' />
    </div>
</div><!-- footer -->

<div id='copyright'>
    cinepassion38 - l 'association grenobloise pour la promotion du cinéma<br/>@Copyright 2018 Genesys - Tous droits réservés
</div>
</body>
</html>