<?php
/*================================================================================================================
	fichier				: ./framework/class.chaine.inc.php
	auteur				: Thomas GRAULLE
	date de création	: novembre 2018
	date de modification:
	rôle				: le class pour toutes les petites function sur des chaines de caractères
  ================================================================================================================*/

/**
 * Class navigation, this class is for create the navigation. With buttons and number of navigation
 *
 * Created by PhpStorm.
 * User: Thomas GRAULLE
 * Date: 11/11/18
 * Time: 16:54
 */
class navigation
{
	
	private $module;
	private $page;
	private $action;
	private $section;
	private $nbSection;
	private $info;

	CONST BT_ACTIF = 'Actif';
	CONST BT_INACTIF = 'Inactif';
	CONST BT_SURVOL = 'Survol';
	CONST BT_RETOUR = 'Retour';
	CONST BT_EXTENSION = 'png';
	CONST BT_PATH = './framework/image/';

    /**
     * navigation constructor.
     * 
	 * @autor Thomas Graulle 
	 * @date 15/11/18 
	 * 
     * @param string $_module
     * @param string $_page
     * @param string $_action
     * @param int $_section
     * @param int $_nbSection
     * @param $_info, string this is where we send the information for the buttons
     */
	public function __construct($_module, $_page, $_action, $_section, $_nbSection, $_info){
		$this->module = $_module;
		$this->page = $_page;
		$this->action = $_action;
		$this->section = $_section;
		$this->nbSection = $_nbSection;
		$this->info = $_info;
		
		$this->enableButton();
	}

	/**
	 * _get, magique getter
	 *
	 * @param string $key
	 * 
	 * @autor Thomas Graulle 
	 * @date 15/11/18 
	 * 
     * @return mixed
	 */
	public function __get($key) {
		if (isset($this->$key)) {
			return $this->$key;
		} else {
			new Exception( "[fichier] : " . __FILE__ 
					. "<br/>[classe] : " . __CLASS__ 
					. "<br/>[méthode] : " . __METHOD__ 
					. "<br/>[message] : l 'élément dont la clé est " . $key . " est introuvable" 
					);
		}
	}
		
	/**
	 * __set, magique setter 
	 * 
	 * @autor Thomas Graulle 
	 * @date 15/11/18 
	 * 
	 * @param string $key
	 * @param mixed $value
	 */
	public function __set($key, $value) {
		if (isset($this->$key)) {
			$this->$key = $value;
		} else {
			new Exception( "[fichier] : " . __FILE__
					. "<br/>[classe] : " . __CLASS__
					. "<br/>[méthode] : " . __METHOD__
					. "<br/>[message] : l 'élément dont la clé est " . $key . " est introuvable"
					);
		}
	}
	
	/**
     * Get xhtml buttons, this function create the xhtml tag for the buttons of navigation.
     *      This navigation use all the element for create the right parameters of the buttons.
	 * 
	 * @autor Thomas Graulle 
	 * @date 15/11/18 
	 * @update Thomas Graulle 19/12/18
     * @param array|null $links, you can add your parameters in the URL
     *
	 * @return string, return xhtml tag, with button
	 */
	public function getXhtmlBoutons($links = null) {
		$result = '';
		foreach ($this->info as $nameButton => $button) {
            if ($button->enable) { // if button is activated
                $resultTemp = '<a href="' . $this->linkAt($button->action, $links) . '">';

                $resultTemp .=
                    '<img alt="Boutton de navigation" id="' . $nameButton . '" src="'
                    . self::BT_PATH . $nameButton . self::BT_ACTIF . '.' . self::BT_EXTENSION
                    . '" '

                    . ' onmouseover="window.document.getElementById(\'' . $nameButton . '\').src = \''
                    . self::BT_PATH . $nameButton . self::BT_SURVOL . '.' . self::BT_EXTENSION
                    . '\'" '

                    . ' onmouseout ="window.document.getElementById(\'' . $nameButton . '\').src = \''
                    . self::BT_PATH . $nameButton . self::BT_ACTIF . '.' . self::BT_EXTENSION
                    . '\'" '

                    . '/>';

                $resultTemp .= '</a>';
                $result .= $resultTemp;

            } else {
                $result .=
                    '<img alt="Boutton de navigation" id="' . $nameButton . '" src="'
                    . self::BT_PATH . $nameButton . self::BT_INACTIF . '.' . self::BT_EXTENSION
                    . '" '
                    . '/>';
            }
		}
		return $result;
	}


	
	/**
	 * Enable button, show if the button need to be disabled of not
	 * 
	 * @autor Thomas Graulle 
	 * @date 15/11/18 
	 *  
	 */
	public function enableButton() {
        if ($this->section === $this->info->btPrem->action) {
			$this->info->btPrec->enable = false;
			$this->info->btPrem->enable = false;
		}
		if ($this->section === $this->info->btDer->action) {
			$this->info->btSuiv->enable = false;
			$this->info->btDer->enable = false;
		}
	}

    /**
     * Get xhtml numbers, this function create the xhtml tag for the numbers of the navigation.
	 * 
	 * @autor Thomas Graulle 
	 * @date 15/11/18 
	 * 
     * @return string, xhtml tag of the number
     */
	public function oldgetXhtmlNumbers() {
        $nbBetween2Numbers = intval(configuration::get('nbBetween2Numbers')) + 1;
        $first = '';
        $previous = '';
        $next = '';
        $last = '';
        $current = '';
        

        $first .= ($this->section === 1 ? '' : '<a class="numberNag" href="' . $this->linkAt(1) . '">1</a>');

        $i = $this->section - 1;
        while ($i > 1 && $i > $this->section - $nbBetween2Numbers) {
            $previous = '<a class="numberNag" href="' . $this->linkAt($i) . '">' . $i . '</a>' . $previous;
            $i--;
        }
        if ($this->section - $nbBetween2Numbers > 1 ) {
            $previous = '<span>...</span>' . $previous;
        }

        $current .= '<a class="currentNumberSection" href="' . $this->linkAt($this->section) . '">' . $this->section . '</a>';

        $i = $this->section + 1;
        while ($i < $this->section + $nbBetween2Numbers && $i < $this->nbSection) {
            $next .= '<a class="numberNag" href="' . $this->linkAt($i) . '">' . $i . '</a>';
            $i++;
        }
        if ($this->section + $nbBetween2Numbers < $this->nbSection ) {
            $next .= '<span>...</span>';
        }

        $last .= ($this->section === $this->nbSection ? '' : '<a class="numberNag" href="' . $this->linkAt($this->nbSection) . '">' . $this->nbSection . '</a>');

        return $first . $previous . $current . $next . $last;
    }
    
    
    /**
     * Get xhtml numbers, this function create the xhtml tag for the numbers of the navigation.
	 * 
	 * @autor Thomas Graulle 
	 * @date 29/11/18 
	 * @version 2.0
	 * 
	 * @param int $nbBetween2Numbers
	 * @param int $styleNavigation
	 * @param int $nbDozen
	 * 
     * @return string, xhtml tag of the number
     */
    public function getXhtmlNumbers($nbBetween2Numbers = 1, $styleNavigation = 1, $nbDozen = 2) {
        $resultat = '';
        $nbBetween2Numbers += 1;
        
        switch ($styleNavigation) {
        	case 1:
        		for ($i = 1; $i <= $this->nbSection; $i++) {
        			if ($i == $this->section) {
        				$resultat .=  '<a class="currentNumberSection" href="' . $this->linkAt($i) . '">' . $i . '</a>';
        			} elseif ($i === 1 ||  $i === $this->nbSection || ($i > ($this->section - $nbBetween2Numbers) && $i < $this->section)
        					|| ($i < ($this->section + $nbBetween2Numbers) && $i > $this->section)
        					) {
        						$resultat .=  '<a href="' . $this->linkAt($i) . '">' . $i . '</a>';
        			} elseif ($i === ($this->section + $nbBetween2Numbers) || $i === ($this->section - $nbBetween2Numbers)) {
        				$resultat .= '<span> ... </span>';
        			}
        		}
        		
        		break;
        		
        	case 2:
        		$upperDozen = $this->upperDozen($this->section, $this->nbSection, $nbDozen);
        		$lowerDozen = $this->lowerDozen($this->section, 1, $nbDozen);

        		for ($i = 1; $i <= $this->nbSection; $i++) {
        			if ($i == $this->section) {
        				$resultat .=  '<a class="currentNumberSection" href="' . $this->linkAt($i) . '">' . $i . '</a>';
        			} elseif ($i === 1 
        					||  $i === $this->nbSection 
        					|| ($i > ($this->section - $nbBetween2Numbers) && $i < $this->section)
        					|| ($i < ($this->section + $nbBetween2Numbers) && $i > $this->section)
        					|| in_array($i, $lowerDozen)
        					|| in_array($i, $upperDozen)
        			) {
        				$resultat .=  '<a href="' . $this->linkAt($i) . '">' . $i . '</a>';
        				
        			} elseif ($i === ($this->section + $nbBetween2Numbers) 
        					|| $i === ($this->section - $nbBetween2Numbers)
        					|| $i === (end($lowerDozen) - 1)
        					|| $i === (end($upperDozen) + 1)
        			) {
        				$resultat .= '<span> ... </span>';
        				
        			}
        		}
        		break;
        }

         
         return $resultat;
    }
    
    /**
     * Lower dozen, this function get the lower dozen of the number at the limite
     * 
	 * @autor Thomas Graulle 
	 * @date 29/11/18 
     * 
     * @param int $current
     * @param int $limitMin
     * @param int $num
     * 
     * @return array, return all the dozen 
     */
    private function lowerDozen($current, $limitMin, $num = 1) {
    	$result = array();
    	$j = $current - 1;
    	
		while ($num != 0 && $j > $limitMin) {
			if ($j % 10 === 0) {
				$result[] = $j;
				$num--;
			}
			$j--;
		}
    	
    	return $result;
    }
    
    /**
     * Upper dozen, this function get the upper dozen of the number at the limite
     * 
	 * @autor Thomas Graulle 
	 * @date 29/11/18 
     * 
     * @param int $current
     * @param int $limitMax
     * @param int $num
     *
     * @return array, return all the dozen
     */
    private function upperDozen($current, $limitMax, $num = 1) {
    	$result = array();
    	$j = $current + 1;
    	 
    	while ($num != 0 && $j < $limitMax) {
    		if ($j % 10 === 0) {
    			$result[] = $j;
    			$num--;
    		}
    		$j++;
    	}
    	 
    	return $result;
    }
    
    /**
     * Link at, this function get the link of the page with section in parameters.
	 * 
	 * @autor Thomas Graulle 
	 * @date 16/11/18 
	 * 
     * @param int $idSection
     * @param array|null $links, you can add your parameters in the URL
     *
     * @return string, link of the new section
     */
    private function linkAt($idSection, $links = null) {
	    $result = "index.php?module=$this->module&amp;page=$this->page&amp;section=$idSection";

        if ($links != null) {
            foreach ($links as $keyLink => $valueLink) {
                $result .= "&amp;$keyLink=$valueLink";
            }
        }

	    return $result;
    }

}