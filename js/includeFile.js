/* ======================================================================================================
 * feuille de style		: includeFile.js
 * objectif(s)			: gère le js pour l'inclusion de fichier
 * auteur				: Thomas GRAULLE
 * date de création		: 5/03/19
 * date de création		: avril 2019
 * date de modification : date	-> comment faire -- qui à fait
 * ======================================================================================================
 */

var include = function(url, callback){

    /* on crée une balise<script type="text/javascript"></script> */
    var script = document.createElement('script');
    script.type = 'text/javascript';

    /* On fait pointer la balise sur le script qu'on veut charger
       avec en prime un timestamp pour éviter les problèmes de cache
    */

    script.src = url + '?' + (new Date().getTime());

    /* On dit d'exécuter cette fonction une fois que le script est chargé */
    if (callback) {
        script.onreadystatechange = callback;
        script.onload = script.onreadystatechange;
    }

    /* On rajoute la balise script dans le head, ce qui démarre le téléchargement */
    document.getElementsByTagName('head')[0].appendChild(script);
};

// include('js/testO.js', function() {
//     console.log(this);
//     titi();
// });

