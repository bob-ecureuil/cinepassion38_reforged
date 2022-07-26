<?php
/*
 * ================================================================================================================
 * fichier : class.controleur.inc.php
 * auteur : Christophe Goidin (christophe.goidin@ac-grenoble.fr)
 * date de création : juin 2017
 * date de modification: septembre 2017 : traitement URL
 * : modification des paramètres getNavigation
 * : récupération d'un encart aléatoire
 * rôle : classe regroupant les services communs à TOUS les contrôleurs.
 * ================================================================================================================
 */

/**
 * Classe générique définissant les services communs à TOUS les contrôleurs
 *
 * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
 * @version 1.0
 * @copyright Christophe Goidin - juin 2017
 */
abstract class controleur {
    protected $requete; // La requête HTTP initiale
    protected $module; // Le module après "traitement"
    protected $page; // La page après "traitement"
    protected $action; // L' action après "traitement"
    protected $donnees = array (); // Le tableau où sont stockées les données pour la vue

    /**
     * Permet de définir la requête HTTP entrante, les paramètres module, page et action
     *
     * @param requete $requete
     *        	: la requête HTTP
     * @param string $module
     *        	: le module "utilisé"
     * @param string $page
     *        	: la page du module
     * @param string $action
     *        	: l'action à réaliser sur la page
     * @return void
     * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
     * @version 1.0
     * @copyright Christophe Goidin - juin 2017
     */
    public function setRequete(requete $requete, $module, $page, $action) {
        $this->requete = $requete;
        $this->module = $module;
        $this->page = $page;
        $this->action = $action;
    }

    /**
     * Prepare the encryption, this function set all the information for the encryption.
     *   If the public key is not define, I receive it
     *
     * @author Thomas Graulle
     * @date 28/03/19 23:00:58 :)
     *
     */
    private function prepareTheEncryption() {
        // ======================================================================
        // Modification du PATH car le fichier RSA.php fait référence à d'autres fichiers de la
        // librairie PhpSecLib (Math/BigInteger.php par exemple)
        // ======================================================================
        set_include_path(get_include_path() . PATH_SEPARATOR . 'librairie/Phpseclib'); // recommendation of the web site of the new library
        require_once('./librairie/Phpseclib/Crypt/RSA.php');

        if (empty($_SESSION['rsa'])) {
            $this->dbRsa = new modeleRsa();
            $_SESSION['rsa'] = $this->dbRsa->getPublicKeyRsa(configuration::get("rsaNumKey"));
        }

    }

    /**
     * Met à jour le tableau $donnees avec les données communes à TOUTES les pages du site web
     *
     * @throws Exception
     * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
     * @version 1.1
     * @copyright Christophe Goidin - juin 2017
     */
    protected function setDonnees() {
        // ===============================================================================================================
        // données communes à toutes les pages
        // ===============================================================================================================
        $this->doctype = configuration::get ( "doctypeStrict" );
        $this->titreSiteWeb = configuration::get ( "siteWeb" );
        $this->filAriane = $this->getFilAriane ();
        $this->version = "version : " . configuration::get ( "version" );
        $this->dateDuJour = utf8_encode ( strftime ( "%A %d %B %Y" ) );
        $this->authentification = $this->getAuthentification ();
        $this->formulaireConnexion = fs::getContenuFichier("./formulaire/form.authentificationUser.inc.php");

        // ===============================================================================================================
        // on positionne l'action dans le tableau $donnees afin d'y avoir accès dans la vue
        // ===============================================================================================================
        $this->donnees ['action'] = $this->action;

        // ===============================================================================================================
        // on positionne des données avec une valeur par défaut si elles n'ont pas été définies dans le contrôleur associé à la page en cours
        // ===============================================================================================================
        if (! $this->existe ( "titreHeader" )) {
            $this->titreHeader = "?";
        }
        if (! $this->existe ( "titreMain" )) {
            $this->titreMain = "?";
        }
        if (! $this->existe ( "enteteLien" )) {
            $this->enteteLien = "";
        }
        if (! $this->existe ( 'globalHeaderLink' )) {
            $this->globalHeaderLink = '';
        }

        // ===============================================================================================================
        // Header link global at all the pages
        // ===============================================================================================================
        if (isset ( $texteDefilant )) {
            $this->globalHeaderLink .= $this->getEnteteLien ( 'liscroll' ) . PHP_EOL;
        }
        $this->globalHeaderLink = $this->getEnteteLien ( 'structure.css' ) . PHP_EOL
            . $this->getEnteteLien ( 'menu.css' ) . PHP_EOL
            . $this->getEnteteLien ( 'formulaire.css' ) . PHP_EOL
            . $this->getEnteteLien ( 'jquery' ) . PHP_EOL
            . $this->getEnteteLien('form.js') . PHP_EOL
            . $this->getEnteteLien('includeFile.js') . PHP_EOL
            . $this->getEnteteLien('jsencrypt') . PHP_EOL
            . $this->globalHeaderLink;

        // ===============================================================================================================
        // on positionne les encarts
        // ===============================================================================================================
        if ($this->existe ( "encarts", "partiel" )) { // il existe au moins un élément dans le tableau $donnees dont le nom commence par encarts
            $adresse = configuration::get ( "adrEncarts" );

            // ===============================================================================================================
            // encarts à gauche
            // ===============================================================================================================
            if (array_key_exists ( "encartsGauche", $this->donnees )) { // il existe au moins un élément dans le tableau $donnees dont le nom = encartsGauche
                $this->lesEncartsGauche = new collection ();
                foreach ( $this->donnees ['encartsGauche'] as $fichier ) {
                    $this->lesEncartsGauche->ajouter( new encart ( $adresse . $fichier ) );
                }
                unset ( $this->donnees ['encartsGauche'] );
            }

            // ===============================================================================================================
            // encarts à droite
            // ===============================================================================================================
            if (array_key_exists ( "encartsDroite", $this->donnees )) { // il existe au moins un élément dans le tableau $donnees dont le nom = encartsDroite
                $this->lesEncartsDroite = new collection ();
                foreach ( $this->donnees ['encartsDroite'] as $fichier ) {
                    $this->lesEncartsDroite->ajouter( new encart ( $adresse . $fichier ) );
                }
                unset( $this->donnees ['encartsDroite'] );
            }
        }

        // ===============================================================================================================
        // Encryption part
        // ===============================================================================================================
        $this->prepareTheEncryption();

        // ===============================================================================================================
        // User part
        // ===============================================================================================================
        $this->prepareUser();
        $this->manageUser();

        // ===============================================================================================================
        // Take the variable from configuration file. And define them into js part of the web site.
        // ===============================================================================================================
        $this->arraySpecialChar = configuration::get("arraySpecialChar");
    }

    /**
     * Donne Navigation, definie un bouton a un numéro de navigation Exemple bouton prem au numDebut
     *
     * @param object Navigation :
     *        	Definie les boutons au numéro
     * @author Axel PUGLISI et Thomas G <axel38450@gmail.com>
     * @version 1.0
     * @copyright Axel PUGLISI et Thomas G - novembre 2018
     * definie un bouton a un numéro de navigation Exemple bouton prem au numDebut
     */

    protected function donneNavigation() {
        try {
            $this->navigation = new navigation(
                $this->module,
                $this->page,
                $this->action,
                $this->currentSection,
                $this->nbTotalSection,
                (object)array(
                    'btPrem' => (object) array('action' => $this->firstSection, 'enable' => true, 'activation' => 'link'), // in this part, the fistSection must be define
                    'btPrec' => (object) array('action' => $this->previousSection, 'enable' => true, 'activation' => 'link'), // in this part, the previousSection must be define
                    'btSuiv' => (object) array('action' => $this->nextSection, 'enable' => true, 'activation' => 'link'), // in this part, the nextSection must be define
                    'btDer' => (object) array('action' =>  $this->lastSection, 'enable' => true, 'activation' => 'link'), // in this part, the lastSection must be define
                )
            );
        } catch (Exception $e) {
            // do nothing
        }
    }

    /**
     * Teste si la propriété $propriete passée en paramètre existe (totalement ou partiellement) dans le tableau $donnees
     *
     * @param string $propriete
     *        	: le nom de la propriété dont on veut tester l'existence
     * @param string $type
     *        	: "total" (valeur par défaut) pour tester l'existence de la totalité de la propriété $propriete. "partiel" pour s'avoir s'il existe au moins une propriété dont le nom commence par $propriete
     * @return boolean : true si la propriété $propriete existe dans le tableau $donnees ou s'il existe au moins une propriété dans le tableau $donnees dont le nom commence par $propriete. false sinon
     * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
     * @version 1.0
     * @copyright Christophe Goidin - juin 2017
     *            @exemple existe("encarts", "partiel") -> return true si "encartsGauche" ou "encartsDroite" existe dans $donnees
     */
    private function existe($propriete, $type = "total") {
        if ($type == "total") {
            return isset ( $this->donnees [$propriete] );
        } elseif ($type == "partiel") {
            $nb = 0;
            foreach ( $this->donnees as $nomPropriete => $valeurPropriete ) {
                if (strlen ( $nomPropriete ) >= strlen ( $propriete )) {
                    if (substr_compare ( $nomPropriete, $propriete, 0, strlen ( $propriete ) ) == 0) {
                        $nb ++;
                        break;
                    }
                }
            }
            return ($nb != 0);
        } else {
            return false;
        }
    }

    /**
     * Exécute la méthode du contrôleur en fonction de l'action à réaliser.
     * Déclenche une exception en cas de problème.
     *
     * @throws Exception
     * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
     * @version 1.0
     * @copyright Christophe Goidin - juin 2017
     */
    public function executerAction() {
        if (method_exists ( $this, $this->action )) {
            $this->{$this->action} (); // mise en oeuvre du principe de REFLEXION. On exécute ici la méthode dont le nom est donné par la valeur de l'attribut action.
        } else {
            throw new Exception ( "[fichier] : " . __FILE__ . "<br/>[classe] : " . __CLASS__ . "<br/>[méthode] : " . __METHOD__ . "<br/>[message] : l 'action '" . $this->action . "' n'est pas définie dans la classe '" . get_class ( $this ) . "'." );
        }
    }

    /**
     * La méthode abstraite defaut correspond à l'action par défaut.
     * Les classes dérivées sont obligées d'implémenter cette methode.
     *
     * @param
     *        	null
     * @return null
     * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
     * @version 1.0
     * @copyright Christophe Goidin - juin 2017
     */
    public abstract function defaut();

    /**
     * Génère la vue associée au contrôleur courant
     *
     * @param
     *        	null
     * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
     * @version 1.0
     * @copyright Christophe Goidin - juin 2017
     */
    protected function genererVue() {
        $vue = new vue ( $this->module, $this->page );
        $this->nettoyer ( $this->donnees ); // Le tableau $donnees est passé par référence
        $vue->generer ( $this->donnees );
    }

    /**
     * Supprime les caractères \r, \n, \r\n et \t dans toutes les valeurs du tableau passé en paramètre.
     * Le tableau est passé en paramètre par référence et la fonction est récursive
     *
     * @param array $tab
     *        	: Les données à nettoyer fournies sous forme d'un tableau passé par référence
     * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
     * @version 1.0
     * @copyright Christophe Goidin - juin 2017
     */
    private function nettoyer(&$tab) { // passage de paramètre PAR REFERENCE
        foreach ( $tab as $cle => $valeur ) {
            if (! is_array ( $valeur )) {
                if (is_string ( $valeur )) {
                    $tab [$cle] = preg_replace ( "/(\r\n|\n|\r|\t)/", "", $valeur );
                }
            } else {
                $this->nettoyer ( $tab [$cle] ); // appel récursif
            }
        }
    }

    /**
     * Méthode permettant de retourner le fil d'Ariane
     *
     * @return string : Le fil d'Ariane
     * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
     * @version 1.0
     * @copyright Christophe Goidin - juin 2017
     */
    private function getFilAriane() {
        if ($this->module == "home") {
            return "home";
        } else {
            return "<a href='./index.php'>home</a> > <a href='./index.php?module=" . $this->module . "&amp;page=accueil'>" . $this->module . "</a> > " . $this->page;
        }
    }

    /**
     * Renvoie le bloc relatif à l'authentification des visiteurs
     *
     * @param
     *        	null
     * @return string : les informations relatives au visiteur authentifié ou le formulaire d'authentification (le cas échéant)
     * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
     * @version 1.1
     * @copyright Christophe Goidin - juin 2017
     */
    private function getAuthentification() {
        return "Authentification";
    }

    /**
     * Lit le contenu d'un fichier texte relatif au texte défilant et le renvoie sous forme d'un tableau associatif
     *
     * @param string $fichier
     *        	: le nom du fichier texte à analyser
     * @throws Exception
     * @return array : un tableau composé du titre et du contenu (un tableau de second niveau)
     * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
     * @version 1.2
     * @copyright Christophe Goidin - juin 2017
     */
    protected function getTexteDefilant($fichier) {
        $fichier = configuration::get ( "adrTexteDefilant" ) . $fichier;
        if (($refFichier = fopen ( $fichier, "r" )) !== False) {
            try {
                // Lecture du titre : On ignore les lignes n°1 et n°3 et on lit le contenu de la ligne n°2 à partir du caractère n°12
                fgets ( $refFichier );
                for($i = 1; $i <= 11; $i ++) {
                    fgetc ( $refFichier );
                }
                $titre = fgets ( $refFichier );
                fgets ( $refFichier );

                // Lecture des textes qui doivent défiler
                while ( ! feof ( $refFichier ) ) {
                    $tab = explode ( "#", fgets ( $refFichier ) );
                    $contenu [$tab [0]] = $tab [1];
                }
                fclose ( $refFichier );
                return array (
                    "titre" => $titre,
                    "contenu" => $contenu
                );
            } catch ( Exception $e ) {
                throw new Exception ( "[fichier] : " . __FILE__ . "<br/>[classe] : " . __CLASS__ . "<br/>[méthode] : " . __METHOD__ . "<br/>[message] : le contenu du fichier texte  " . $fichier . " n'est pas cohérent par rapport à la structure attendue." );
            }
        } else {
            throw new Exception ( "[fichier] : " . __FILE__ . "<br/>[classe] : " . __CLASS__ . "<br/>[méthode] : " . __METHOD__ . "<br/>[message] : le fichier texte défilant " . $fichier . " est introuvable" );
        }
    }

    /**
     * Renvoie les lignes du fichier texte passé en paramètre sous forme d'un tableau (utilisé notamment pour les textes de la galerie slidesjs de la page d'accueil du site)
     *
     * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
     * @version 1.1
     * @copyright Christophe Goidin - juin 2017
     *
     * @throws Exception
     * @param string $fichier
     *        	: l'adresse relative du fichier texte à lire
     * @return array : un tableau contenant les lignes du fichier texte
     */
    protected function getContentFile($fichier) {
        if (($refFichier = fopen ( $fichier, "r" )) !== False) {
            $i = 0;
            while ( ! feof ( $refFichier ) ) {
                $result [$i ++] = fgets ( $refFichier );
            }
            fclose ( $refFichier );
            return $result;
        } else {
            throw new Exception ( "[fichier] : " . __FILE__ . "<br/>[classe] : " . __CLASS__ . "<br/>[méthode] : " . __METHOD__ . "<br/>[message] : le fichier texte " . $fichier . " est introuvable." );
        }
    }

    /**
     * Get entete lien, return the html tag for the fileName in parameter.
     * After this, we take the name where you search in dev.ini
     * If the function can't find the right file, the function return empty string
     *
     * @author Thomas & Axel
     * @date October 2018
     *
     * @param string $fileName,
     *        	this is the name of file (slidesjs.css) or name of library (jquery)
     * @return string : The html tag(s) or empty string
     */
    protected function getEnteteLien($fileName) {
        $arrayFileName = explode ( '.', $fileName );
        $path = '';
        $result = '';
        $partFileNameArray = array ();
        $partFileNameArrayOther = array();

        // Receive the path
        switch ($arrayFileName [count ( $arrayFileName ) - 1]) {
            case 'js' : // if I have .js extension
                $path = explode ( ';', configuration::get ( 'dirJs' ) );
                $partFileNameArray [] = $fileName;
                break;
            case 'css' :
                $path = explode ( ';', configuration::get ( 'dirCss' ) );
                $partFileNameArray [] = $fileName;
                break;
            default : // If I don't have extension or unknowed extension
                $path = explode ( ';', configuration::get ( 'dirLib' ) );
                $partFileNameArray [] = "$fileName/js/$fileName.js";
                $partFileNameArray [] = "$fileName/css/$fileName.css";
                $partFileNameArrayOther [] = "$fileName/bin/$fileName.js";
                $partFileNameArrayOther [] = "$fileName/bin/$fileName.css";
                break;
        }

        // Include the file
        for ($j = 0; $j < count($partFileNameArray); $j++) {
//		foreach ( $partFileNameArray as $partFileName ) {
            $find = false;
            $i = 0;
            while ( ! $find && $i < count ( $path ) ) {
                $pathFile = $path [$i] . '/' . $partFileNameArray[$j];

                if (file_exists ( $pathFile )) {
                    $find = true;
                    $result .= $this->getTagLink ( $pathFile ); // Add html tag to the result
                } else {
                    $pathFileOther = ( isset($partFileNameArrayOther[$j]) ? $path [$i] . '/' . $partFileNameArrayOther[$j] : false );
                    if (file_exists ( $pathFileOther )) {
                        $find = true;
                        $result .= $this->getTagLink ( $pathFileOther ); // Add html tag to the result
                    }
                }
                $i ++;
            }
        }

        return $result;
    }

    /**
     * Get tag link, return a tag html with pathFile parameters
     *
     * @author Thomas GRAULLE
     *         @date October 2018
     *
     * @param
     *        	$pathFile
     * @return string, Return a tag Html
     *
     */
    protected function getTagLink($pathFile) {
        $result = '';
        switch (pathinfo ( $pathFile, PATHINFO_EXTENSION )) {
            case 'css' :
                $result = "<link rel='stylesheet' type='text/css' href='$pathFile' />";
                break;
            case 'js' :
                $result = "<script type='text/javascript' src='$pathFile'></script>";
                break;
        }
        return $result;
    }

    /**
     * Méthode MAGIQUE permettant de retourner la valeur de l'élément correspondant à la clé $cle dans le tableau $donnees.
     * Cette méthode se déclenche AUTOMATIQUEMENT lorsqu'on essaie de récupérer la valeur d'un attribut INEXISTANT
     *
     * @param string $cle
     *        	: La cle de l'élément
     * @throws Exception
     * @return string : La valeur de l'élément correspondant à la clé $cle dans le tableau $donnees. Déclenche une exception si non trouvé
     * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
     * @version 1.1
     * @copyright Christophe Goidin - mai 2013
     */
    public function __get($cle) {
        if (array_key_exists ( $cle, $this->donnees )) {
            return $this->donnees [$cle];
        } else {
            throw new Exception ( "[fichier] : " . __FILE__ . "<br/>[classe] : " . __CLASS__ . "<br/>[méthode] : " . __METHOD__ . "<br/>[message] : l 'élément dont la clé est " . $cle . " est introuvable" );
        }
    }

    /**
     * Méthode MAGIQUE permettant d'alimenter le tableau $donnees qui se déclenche AUTOMATIQUEMENT lorsqu'on fait référence à un attribut INEXISTANT
     *
     * @param string $cle
     *        	: la clé de l'élément à ajouter au tableau
     * @param string $valeur
     *        	: la valeur de l'élément à ajouter au tableau
     * @return void
     * @author Christophe Goidin <christophe.goidin@ac-grenoble.fr>
     * @version 1.2
     * @copyright Christophe Goidin - mai 2013
     *            @update Thomas GRAULLE October 2018
     */
    public function __set($cle, $valeur) {
        if (substr ( $cle, 0, 7 ) != 'encarts') {
            $this->donnees [$cle] = $valeur;
        } else {
            if (is_array ( $valeur )) {
                $this->donnees [$cle] = $valeur; // This override the value if is not empty
            } else {
                $this->donnees [$cle] [] = $valeur; // If the rencart value is string then I add
            }
        }
    }

    /**
     * Get random file of folder, this function get the files of the folder in parameter.
     *
     * @author Thomas GRAULLE
     *         @date October 2018
     * @version 2.1
     *
     * @param string $pathOfFolder,
     *        	the path of the folder, for example: './image/film/affiche'.
     * @param array $fileExtension,
     *        	the valid file extension.
     * @param array $listOfException,
     *        	list of file who not need, extension without '.' example: 'jpg' or 'txt'
     * @param int $numberOfFile,
     *        	the number of file return, but the number of file need can't be superior of number of files into the folder - exception.
     *
     * @return array, list of random link, else return empty board
     */
    protected function getRandomFileOfFolder($pathOfFolder, $fileExtension, $listOfException, $numberOfFile) {
        $listOfException [] = '.';
        $listOfException [] = '..';
        $arrayOfFile = array ();

        if (is_dir ( $pathOfFolder )) {
            foreach ( scandir( $pathOfFolder ) as $file ) {
                if (! in_array( $file, $listOfException )) {
                    if (in_array( pathinfo( $file, PATHINFO_EXTENSION ), $fileExtension )) { // If the extension file is in $fileExtension
                        if (( float ) phpversion () >= 7.2) { // utf8_encode is remove in php7, in php7, it's automatically used
                            $arrayOfFile [] = (substr( $pathOfFolder, - 1 ) == "/" ? $pathOfFolder . $file : $pathOfFolder . '/' . $file);
                        } else {
                            $arrayOfFile [] = ( substr( $pathOfFolder, - 1 ) == "/" ? $pathOfFolder . utf8_encode( $file ) : $pathOfFolder . '/' . utf8_encode( $file ));
                        }
                        // I add the complete pathFile into $arrayOfFile
                    }
                }
            }
            $this->getRandomArray ( $arrayOfFile, $numberOfFile );
        }

        return $arrayOfFile;
    }

    /**
     * Get random array, change the array
     *
     * @param array $array
     * @param int $sizeOfNewArray
     * @return void
     */
    protected function getRandomArray(&$array, $sizeOfNewArray = null) {
        $sizeOfNewArray = ($sizeOfNewArray === null || // Look if $sizeOfNewArray is possible
        $sizeOfNewArray > count ( $array ) || $sizeOfNewArray <= 0 ? count ( $array ) : // Else, I take the size of the array
            $sizeOfNewArray);
        $newArray = array ();

        for($i = 0; $i < $sizeOfNewArray; $i ++) {
            $rnd = rand ( 0, count ( $array ) - 1 );
            while ( in_array ( $array [$rnd], $newArray ) ) {
                $rnd = ($rnd >= count ( $array ) - 1 ? 0 : $rnd + 1);
            }
            $newArray [] = $array [$rnd];
        }

        $array = $newArray;
    }

    /**
     *
     *
     * get random encart right, return the encarts in right.
     * Take specific setting define into dev.ini file
     *
     * @author Axel Puglisi and Thomas Graulle
     * @date 19/10/2018
     *
     * @param null $numberOfFile
     * @return array
     */
    protected function getRandomEncartRight($numberOfFile = null) {
        $result = array ();
        $numberOfFile = ($numberOfFile !== null ? $numberOfFile : intval ( configuration::get ( 'nbEncartDroitMax' ) ));
        $result = $this->getRandomEncart ( $numberOfFile );

        return $result;
    }

    /**
     * get random encart left, return the encarts in left.
     * Take specific setting define into dev.ini file
     *
     * @author Axel Puglisi and Thomas Graulle
     * @date 19/10/2018
     *
     * @param null $numberOfFile
     * @return array
     */
    protected function getRandomEncartLeft($numberOfFile = null) {
        $result = array ();
        $numberOfFile = ($numberOfFile !== null ? $numberOfFile : intval ( configuration::get ( 'nbEncartGaucheMax' ) ));
        $result = $this->getRandomEncart ( $numberOfFile );

        return $result;
    }

    /**
     * get random encart, return the right forms to the encart random
     * For this I use a function that random file into folder
     * If the numberOfFile is incoherent, then number of file is the number into the folder
     *
     * @author Axel Puglisi and Thomas Graulle
     * @date 19/10/2018
     *
     * @param int $numberOfFile
     * @return array,
     */
    protected function getRandomEncart($numberOfFile) {
        $result = array ();
        $fileExtension = explode ( ';', configuration::get ( 'extensionEncartPermitted' ) );
        $pathOfFolder = configuration::get ( 'pathOfEncartFolder' );
        $listOfException = explode ( ';', configuration::get ( 'fileEncartRefused' ) );
        $result = $this->getRandomFileOfFolder ( $pathOfFolder, $fileExtension, $listOfException, $numberOfFile );

        foreach ( $result as $key => $value ) {
            $result [$key] = substr ( $value, 15 );
        }

        return $result;
    }

    /**
     * Get nb section, get the number of section into all the section
     *
     * @author Thomas Graulle
     * @date 11 2018
     *
     * @param int $nbElement
     * @param int $nbElementBySection
     *
     * @return number
     */
    protected function getNbSection($nbElement, $nbElementBySection) {
        return ceil($nbElement / $nbElementBySection);
    }

    /**
     * Get valid section, this function check if the currentSection is valid, if this section exist
     *
     * @author Thomas Graulle
     * @date 11 2018
     *
     * @param int $currentSection
     * @param int $lastSection
     * @param int $defaultSection, the default result, for example if nothing is the result is false then return this value.
     *
     * @return int, return the correct value of section and return 0 if $valueSection is wrong
     */
    protected function getValidSection($currentSection, $lastSection, $defaultSection = 1) {
        $result = $defaultSection;
        $currentSection = (string)$currentSection;

        if ( ctype_digit($currentSection)) { // if the char is number (0,1,2,3...)
            $currentSection = (int)$currentSection;
            if ( $currentSection <= $lastSection && $currentSection >= 0) {
                $result = $currentSection;
            } else {
                if ($currentSection < $lastSection) {
                    $result = $lastSection;
                }
            }
        }
        return (int)$result;
    }

    /**
     * Get content into folder, get all path into folder.
     *   In this function you have the possibility of authorized or not some extension.
     *   Also that you can chose some unwanted image.
     *
     * @author Thomas Graulle
     * @date 15/12/18
     *
     * @param string $pathOfFolder
     * @param string $nameOfFolder
     * @param array $extensionAuthorized
     * @param array $extensionUnauthorized
     * @param array $unauthorizedFile
     * @param int $deepness, the deepness of the research into folder, 2 for get the content of the file and 1 children.
     * @param int $currentDeepness, this param is used for know how deep we are
     *
     * @return array, return all the path of file into the folder and return empty array if noting is authorized
     */
    protected function getContentIntoFolder($pathOfFolder, $nameOfFolder, $extensionAuthorized  = array(), $extensionUnauthorized = array(), $unauthorizedFile = array(), $deepness = 1, $currentDeepness = 0) {
        $result = array();
        $unauthorizedFile [] = '.';
        $unauthorizedFile [] = '..';

        if (file_exists($pathOfFolder . '/' . $nameOfFolder)) {
            $newPathFolder = $pathOfFolder . '/' . ($nameOfFolder === '' ? '' : $nameOfFolder . '/');

            foreach (scandir($newPathFolder) as $pathOfFile) {
                $extensionPath = pathinfo( $newPathFolder . $pathOfFile, PATHINFO_EXTENSION);

                if (is_dir($newPathFolder . $pathOfFile) && $currentDeepness < $deepness && !in_array($pathOfFile, $unauthorizedFile)) {
                    $result = array_merge($this->getContentIntoFolder($pathOfFolder, $pathOfFile, $extensionAuthorized, $extensionUnauthorized, $unauthorizedFile, $deepness, $currentDeepness + 1), $result);
                } elseif (in_array($extensionPath, $extensionAuthorized)
                    && !in_array($extensionPath, $extensionUnauthorized)
                    && !in_array($pathOfFile, $unauthorizedFile)
                ) {
                    $result[] = $newPathFolder . $pathOfFile;

                }
            }
        }

        return $result;
    }

    /**
     * Change format date, This function change the format of date
     *
     * @param string $date, date on format 'dmy' => 20-02-2018
     *
     * @return string, return sting at this format: Ymd, 20180212 => 2018/02/20
     */
    protected function changeFormatDate($date) {
        return date('Ymd', strtotime($date));
    }

    /**
     * Uncrypt, this function uncrypt all the information in the array on parameters
     *
     * @author Thomas Graulle
     * @date 04/04/19
     *
     * @param array $arrayValueCrypted, array of value crypted
     * @param string $privateKey
     *
     * @return array $uncryptArray: return the array of value uncrypt
     */
    protected function uncrypt($arrayValueCrypted, $privateKey) {
        // ==========================================
        // Instanciate the encryption and set the private key
        // ==========================================
        $rsa = new Crypt_RSA();
        $rsa->setEncryptionMode(CRYPT_RSA_ENCRYPTION_PKCS1);
        $rsa->loadKey($privateKey);

        $uncryptArray = array();

        foreach ($arrayValueCrypted as $crypted) {
            $uncryptArray[] = $rsa->decrypt(base64_decode($crypted)); // base64_decode is necesary if you encrypt with jsEncode
        }

        return $uncryptArray;
    }

    protected function timeDiff($time1, $time2) {
        $diff = $time1->diff($time2);

        return $diff->format("%i minutes et %s secondes");
    }
    
    /**
     * Hash string with grain sel, this function hash 2 string with the "grain de sel" technique
     * 
     * @author Thomas Graulle
     * @date 12/04/2019
     * 
     * @param string $aPassword
     * @param string $grainDeSel
     * 
     * @return string, return the hashed string
     */
    protected function hashStringWithGrainSel($aPassword, $grainDeSel) {
    	return hash('sha512', 
	    			hash('md5', $grainDeSel . $aPassword) .
	    			$grainDeSel .
	    			hash('md5', $aPassword . $grainDeSel)
    			);
    }

    /**
     * Char in string, this function check if the char is into the string
     *
     * @param array $arraySpecialChar : The array of char
     * @param string $aString : The string to search in
     *
     * @return bool
     */
    public static function charInString($arraySpecialChar, $aString) {
        $result = false;
        foreach ($arraySpecialChar as $char) {
            if (strpos($aString, $char)) {
                $result = true;
                break; // quite for loop
            }
        }

        return $result;
    }

    /**
     * Prepare User, créé session avec la base de données pour le module 'modeleUserconnexion'
     *
     * @author Thomas GRAULLE
     * @date 19/11/2019
     */
    private function prepareUser() {
        $this->dbUserconnexion = new modeleUserconnexion();
    }

    /**
     * User is connected, check if the user is connected
     *
     * @author Thomas GRAULLE
     * @date 19/11/2019
     * @version 3
     *
     * @return bool
     */
    public function userIsConnected() {
        $result = false;
        if ($this->dbUserconnexion->userExist($_SESSION['user']->loginUser, $_SESSION['user']->motDePasseUser)) {
            $result = true;
        }

        return $result;
    }

    /**
     * Manage user, manage the $_SESSION['user']. If is exist but not valid, we destroy the session.
     *
     * @author Thomas GRAULLE
     * @date 19/11/2019
     * @version  3
     */
    private function manageUser() {
        if (isset($_SESSION['user'])) {
            if ($this->userIsConnected()) {
                // Everything is good :)
            } else {

                // ====================================================================================
                // ATTENTION, the user avec session but is not valid. So he is disconnected
                // ====================================================================================
                unset($_SESSION['user']);
            }
        }

    }

} // class




