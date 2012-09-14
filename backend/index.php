<?php

require_once('JoshAndrew/backend/Predis/lib/Predis/Autoloader.php');
require_once('JoshAndrew/backend/mutexHandler.php');
Predis\Autoloader::register();
$redis = new Predis\Client();
$redis->select(9);

$mysqli = new mysqli("localhost", "admin", "fiddy", "evilgenius");
if ($mysqli->connect_errno) {
  echo "{'error':-2,'message':'Failed to connect to MySQL: (" . $mysqli->connect_errno . ") " . $mysqli->connect_error . "'}";
  exit(-2);
}

$MAX_PLAYERS = 3;

switch ($_REQUEST['method'])
{
  case 'Match':
    $userId = $_REQUEST['user_id'];
    $userName = isset($_REQUEST['user_name']) ? $_REQUEST['user_name'] : 'User '.$userId;
    $mutex = new RedisMutex($redis);
    
    //YOU SHALL NOT PASS!!!
    $mutex->block($userId, 'match');
    
    $currentMatchId = intval($redis->get('current-match-id'));
    $currentMatchPlayers = $redis->lrange('match-players-'.$currentMatchId, 0, -1);
    $hasJudge = false;
    
    foreach($currentMatchPlayers as $player)
    {
      $playerInfo = explode('-', $player);
      if ($userId == $playerInfo[1])
      {
        echo "{'error': -1}";
        exit(1);
      }
      
      if (isset($playerInfo[5]) && $playerInfo[5] == 'judge')
      {
        $hasJudge = true;
      }
    }
    
    $numMatchPlayers = count($currentMatchPlayers);
    $playType = ($numMatchPlayers > $MAX_PLAYERS-2 || rand(0, 1)) && !$hasJudge ? "judge" : "orator";
    $response = array('play_type' => $playType);
    
    if ($numMatchPlayers == $MAX_PLAYERS)
    {
      $currentMatchId++;
      $redis->set('current-match-id', $currentMatchId);
      $numMatchPlayers = 0;
      
      
      $res = $mysqli->query('select text from adlib');
      $numRows = $res->num_rows;
      $adlibRow = rand(0, $numRows-1);
      $res->data_seek($adlibRow);
      $row = $res->fetch_assoc();
      $response['adlib'] = $row['text'];
      error_log('adlib: '.$response['adlib']);
      $redis->set('match-adlib-'.$currentMatchId, $response['adlib']);
    }
    else
    {
      $response['adlib'] = $redis->get('match-adlib-'.$currentMatchId);
    }
    
    if ($playType == "orator")
    {
      $response['hand'] = array('The Trail of Tears', 'Passive-aggressive Post-it notes', 'Synergistic management solutions', 'The Dance of the Sugar Plum Fairy', 
                  'An icepick lobotomy', 'Guys who don\'t call', 'Attitude', 'Breaking out into song and dance.', 'Dental dams', 'The Kool-Aid Man');
    }
    
    $redis->lpush('match-players-'.$currentMatchId, 'userId-'.$userId.'-userName-'.$userName.'-role-'.$playType);
    
    $mutex->unlock($userId, 'match');
    //ok u pas nao
  break;
  default:
    $response = "{'error': -2}";
  break;
}



echo json_encode($response);

?>
