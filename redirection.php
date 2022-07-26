<?php
/**
 * Created by PhpStorm.
 * User: msi-predator
 * Date: 28/03/19
 * Time: 22:06
 */

session_start();
if (isset($_SESSION['page'])) {
    echo $_SESSION['page'];
} else {
    header('Location:./index.php');
    exit;
}