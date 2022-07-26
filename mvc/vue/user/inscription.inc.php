<!-- ========= V U E =============================================================================================
 fichier				: ./mvc/vue/user/inscription.inc.php
 auteur					: Thomas Graulle
 date de création		: Avril 2019
 date de modification	:
 rôle					: permet de générer le code xhtml de la partie centrale de la page d'authentification du module user
 ================================================================================================================= -->

<div id='content2'>
    <?php
        if (isset($action)) {
            switch ($action) {
                case 'inscriptionSuccessful':
                    ?>

                    <?php


                    break;

                case 'inscriptionFailed':
                    ?>

                    <?php
                    break;

                case 'defaut':
                    echo isset($formulaireInscription)? $formulaireInscription : '';
                	?>

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