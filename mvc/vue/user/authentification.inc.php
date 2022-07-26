<!-- ========= V U E =============================================================================================
 fichier				: ./mvc/vue/user/authentifiacation.inc.php
 auteur					: Thomas Graulle
 date de création		: Avril 2019
 date de modification	:
 rôle					: permet de générer le code xhtml de la partie centrale de la page d'authentification du module user
 ================================================================================================================= -->

<div id='content2'>
    <?php
        if (isset($action)) {
            switch ($action) {
                case 'connexionSuccessful':
                    ?>
                    <img src="./image/divers/ok.png" alt="image connexion réussite">
                    <h5 style="color: green;">Authentification réalisée avec succès</h5>
                    <ul>
                        <li>
                            C'est votre <?php echo ($_SESSION['user']->nbTotalConnexionUser + 1); echo ($_SESSION['user']->nbTotalConnexionUser == 0 ? 'er' : 'ème' ) ?> connexion depuis la créaion de votre compte le <?php echo $_SESSION['user']->dateHeureCreationUser; ?>.
                        </li>
                        <?php
                            if ($_SESSION['user']->dateHeureDerniereConnexionUser !== null) {
                                ?>
                                <li>Votre dernière connexion a eu lieu le <?php echo $_SESSION['user']->dateHeureDerniereConnexionUser; ?>.</li>
                                <?php

                            }

                            if ($_SESSION['user']->nbEchecConnexionUser != 0) {
                                ?>
                                <li>Attention, il y a eu <?php echo $_SESSION['user']->nbEchecConnexionUser; ?> tentative<?php echo ($_SESSION['user']->nbEchecConnexionUser > 1 ? 's' : '' ); ?> incorrecte<?php echo ($_SESSION['user']->nbEchecConnexionUser > 1 ? 's' : '' ); ?> de connexion avec votre login depuis votre dernière connexion.</li>
                                <?php
                            }

                            if ($_SESSION['user']->classicPassword) {
                                ?>
                                <li>Vous n'avez pas encore modifié votre mot de passe. Pour des raison de sécurité, pensez à le faire rapidement. Vous pouvez le modifier
                                    <a " href="./index.php?module=user&amp;page=modification&amp">ici</a>.</li>
                                <?php
                            }
                        ?>
                    </ul>
                    <?php


                    break;

                case 'connexionFailedPage':
                    ?>
                    <img src="./image/divers/ko.png" alt="image erreur de connexion">
                    <h5 style="color: red;">Echec de la tentative d'authentification</h5>
                    <ul>
                        <li>Votre tentative d'authentification est en échec. Votre identifiant et/ou votre mot de passe
                            sont incorrects.
                        </li>
                        <li>Vérifiez les informations saisies et essayez à nouveau.</li>
                    </ul>

                    <?php
                    break;

                case 'deconnexion':

                	?>
                	<img src="./image/user/animaux/pingouin.png" alt="image déconnexion">
                    <h5 style="color: grey;">La connexion est terminée</h5>
                	<ul>
                        <li>Votre connexion à durée <?php echo isset($timeConnexion) ? $timeConnexion : "xx-xx-xx";?> .
                    </ul>
                    
                    <?php 
                    break;


                default:
                    echo 'Une erreur est survenu, veuillez informer l\'administrateur du site';
                    break;
            }
        } else {
            echo 'Une erreur est survenu';
        }

    ?>
</div><!-- content2 -->