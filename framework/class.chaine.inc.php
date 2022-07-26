<?php
/*================================================================================================================
	fichier				: ./framework/class.chaine.inc.php
	auteur				: Thomas GRAULLE
	date de création	: october 2018
	date de modification:
	rôle				: le class pour toutes les petites function sur des chaines de caractères
  ================================================================================================================*/

/**
 * Class chaine,
 *
 * Created by PhpStorm.
 * User: Thomas GRAULLE
 * Date: 19/10/18
 * Time: 21:09
 */
class chaine
{

    /**
     * Split by upper case, split the string and return array of sting
     *
     * @date 19/10/18
     * @author Thomas GRAULLE
     *
     * @param string $string
     * @return array, return array of string
     */
    public static function splitByUpperCase($string) {
        $result = array();
        $i = 0;
        $string = str_split($string); // convert $string in array, new I can use foreach on this
        $result[$i] = "";
        
        foreach ($string as $char) {
            if (ctype_upper($char)) { // i++ if the $char is upperCase
                $i++;
                $result[$i] = "";
            }
            $result[$i] .= $char; // Concat with the rest of strings
        }

        return $result;
    }

}